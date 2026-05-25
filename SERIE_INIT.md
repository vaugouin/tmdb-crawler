# TV Series Init Strategy

## Goal

Backfill the seasons and episodes for **stable / ended TV series** that the live `tv/changes` loop never visits, by processing a bounded batch of obviously-incomplete series per crawler pass and letting the work spread naturally over multiple days.

This complements [SERIE_UPDATE.md](SERIE_UPDATE.md): that doc covers the *delta* refresh driven by TMDb's changes feed; this one covers the *one-time bootstrap* for series that are stable enough never to surface on `tv/changes` again.

---

## Why this is needed

The `tv/changes` discovery loop in [tmdb-crawler.py](tmdb-crawler.py) only operates on series that TMDb reports as touched in the last poll window. Ended series with no active community editing **never** appear there, so their `T_WC_TMDB_SEASON` and `T_WC_TMDB_EPISODE` rows can stay empty or partial forever even though the selective orchestrator would handle them correctly if invoked.

The init process closes that loop by enumerating incomplete series from the DB itself and feeding them to the existing orchestrator at a controlled rate.

---

## Identification query

A series is "obviously incomplete" if either:

1. it has fewer local season rows than TMDb claims it should have, or
2. at least one of its season rows is missing any of the four `TIM_*_COMPLETED` timestamps.

```sql
SELECT ID_SERIE FROM (
    -- (a) zero or fewer seasons loaded than TMDb says
    SELECT s.ID_SERIE
    FROM T_WC_TMDB_SERIE s
    LEFT JOIN (
        SELECT ID_SERIE, COUNT(*) AS local_seasons
        FROM T_WC_TMDB_SEASON
        WHERE SEASON_NUMBER > 0
        GROUP BY ID_SERIE
    ) lc ON lc.ID_SERIE = s.ID_SERIE
    WHERE s.DELETED = 0
      AND s.NUMBER_OF_SEASONS > 0
      AND (lc.local_seasons IS NULL OR lc.local_seasons < s.NUMBER_OF_SEASONS)

    UNION

    -- (b) any local season missing a completion timestamp
    SELECT DISTINCT s.ID_SERIE
    FROM T_WC_TMDB_SERIE s
    JOIN T_WC_TMDB_SEASON se ON se.ID_SERIE = s.ID_SERIE
    WHERE s.DELETED = 0
      AND (se.TIM_CREDITS_COMPLETED IS NULL
        OR se.TIM_TRANSLATIONS_COMPLETED IS NULL
        OR se.TIM_IMAGES_COMPLETED IS NULL
        OR se.TIM_VIDEOS_COMPLETED IS NULL)
) candidates
ORDER BY ID_SERIE
LIMIT :batch_size;
```

`ORDER BY ID_SERIE` gives deterministic pagination across runs; once a series is fully loaded the next pass naturally skips it.

> **Note on episode-level gaps.** We deliberately do **not** scan `T_WC_TMDB_EPISODE` here. The selective orchestrator already covers missing/incomplete episodes once their parent season is refreshed, and querying every episode row would explode the audit cost. If a series passes the season audit, the orchestrator's T4 episode rules handle the remainder.

---

## Per-series action

For each series ID returned by the query, call:

```python
tf.f_tmdbserieselectiveseasonsepisodestosql(lngid)
```

The orchestrator already covers both shapes of work this process needs:

- **Cold series (no seasons loaded)** — `TIM_LAST_CHANGES_CHECK` is NULL, T1 is skipped, T2 fetches `/tv/{id}`, T3 selects every TMDb season under the *"missing locally"* rule, T4 selects every episode under the *"completion incomplete"* rule. Effectively a full bootstrap, only without the unconditional fan-out of `f_tmdbserieallseasonsepisodestosql`.
- **Warm-but-partial series** — same orchestrator, but only the missing/incomplete children get refreshed.

No separate code path is needed. We reuse the orchestrator as-is.

---

## Batch size & scheduling

- **`INT_INIT_SERIES_BATCH_SIZE`** — a new module-level constant in `tmdb_functions.py`, default `25`. Caps the number of series processed per crawler pass.
- **Where it runs** — a new block in `tmdb-crawler.py`, executed **after** the existing `tv/changes` loop on each crawler invocation. Order matters: process fresh deltas first (cheap when the orchestrator's T1 says "nothing changed"), then spend remaining capacity on backfill.
- **Self-resuming** — no state to persist. Each pass selects the next `LIMIT N` from the natural ordering; once a series falls out of the audit query (fully loaded), it doesn't come back.
- **Natural distribution across days** — if the crawler runs hourly with `BATCH_SIZE=25`, that's 600 series/day. Tune to your TMDb rate-limit headroom.

---

## Integration contract

### New function in `tmdb_functions.py`

```python
def f_tmdbserieinitincomplete(intbatchsize=INT_INIT_SERIES_BATCH_SIZE):
    """
    One pass of the 'init series' backfill: pick up to intbatchsize
    obviously-incomplete series from T_WC_TMDB_SERIE and run the selective
    orchestrator on each.

    Self-resuming: the audit query reflects current DB state, so successive
    calls naturally march through the population. Returns the number of
    series actually processed (so the crawler can log progress).
    """
```

Implementation outline:

1. Run the audit query above with the configured `LIMIT`.
2. For each `ID_SERIE`:
   - Print a `init series: processing {id} ({n}/{total})` line.
   - Wrap the call in `try/except pymysql.MySQLError as e: cp.f_handlemysqlerror(...)` to match the existing crawler error pattern.
   - Call `f_tmdbserietosqleverything(lngid)` then `f_tmdbserieselectiveseasonsepisodestosql(lngid)` — same two-step the changes loop uses, since the series row itself may also be stale.
3. Return the count.

### New block in `tmdb-crawler.py`

After the existing `tv/changes` loop body completes its `for` iteration over change types, before the loop closes out, add:

```python
# Init pass: backfill obviously-incomplete series that tv/changes never visits.
intinitprocessed = tf.f_tmdbserieinitincomplete()
print(f"init series: processed {intinitprocessed} this pass")
```

The exact insertion point is right before the crawler's per-pass cleanup block (sleep / next-iteration logic). One call per crawler pass.

---

## What this strategy intentionally avoids

- **Full re-fan-out via `f_tmdbserieallseasonsepisodestosql`** — that function ignores existing local state and re-fetches every season/episode unconditionally. The orchestrator skips work it doesn't need, so for partial series we save a lot of calls.
- **Querying `T_WC_TMDB_EPISODE` in the audit** — too expensive at population scale. Episode-level gaps are repaired transitively by the orchestrator once their season is picked up.
- **State tables** — no need for `T_WC_TMDB_SERIE_INIT_QUEUE` or similar. The audit query *is* the queue.
- **Prioritization gymnastics** — `ORDER BY ID_SERIE` is enough. Popularity/recency ordering can be added later if backfill speed becomes a complaint.

---

## API-cost ceiling per pass

For `BATCH_SIZE = 25`, the upper bound on TMDb calls is:

| Cohort | Per-series cost | Notes |
| --- | --- | --- |
| Cold (no seasons) | `~6 + N + E` | T2 (~6 calls via `f_tmdbserietosqleverything` + T2's own `/tv/{id}`) + N season calls + E episode calls. For a 10-season / 100-episode show: ~116 calls. |
| Partial | `~6 + missing_N + missing_E` | Same shape, but only the gaps. |
| Already complete | `~6 + 1 (T2 short-circuit)` | The audit query shouldn't surface these; if it does, the orchestrator's rules drop everything. |

So a 25-series pass against cold ended shows could burn a few thousand calls. Adjust `BATCH_SIZE` against your daily TMDb quota.

---

## Verification

1. **Audit query baseline** — run the SELECT above manually with no `LIMIT` and record the row count. That's the total work remaining.
2. **First pass** — call `f_tmdbserieinitincomplete(intbatchsize=5)` interactively against a few known-incomplete IDs. Check that after the run:
   - `T_WC_TMDB_SEASON` rows appear for every season TMDb reports.
   - The season-level `TIM_*_COMPLETED` columns are stamped.
   - `T_WC_TMDB_EPISODE` rows appear with their own `TIM_*_COMPLETED` filled in.
3. **Re-run the audit** — the processed IDs should drop out of the query results.
4. **Crawler integration** — start `tmdb-crawler.py` and observe the `init series: processed N this pass` log line at the end of each pass. Confirm N matches `min(BATCH_SIZE, remaining_count)`.
5. **Idempotency** — running multiple passes back-to-back should march steadily through the population without re-processing finished series.
6. **Failure isolation** — kill TMDb network mid-pass; confirm a single failing series doesn't abort the batch (the per-series `try/except` keeps the loop alive).

---

## Future improvements

- Configurable batch size via `T_WC_SERVER_VARIABLE` instead of a Python constant.
- Optional popularity-weighted ordering (e.g. `ORDER BY s.POPULARITY DESC, s.ID_SERIE`) so users see well-known shows backfill first.
- Cooldown on repeat failures: skip series whose last attempt was within the last hour. Avoids burning calls on a series TMDb consistently 404s on.
- Standalone CLI entry point (`python -m tmdb_functions init --batch 100`) for operator-driven larger backfill runs outside the crawler loop.
