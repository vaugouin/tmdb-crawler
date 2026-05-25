# TV Series Update Strategy

## Goal

Keep TV series, seasons and episodes reasonably up to date while minimizing TMDb API calls.

The core principle: **don't guess what changed — ask TMDb.** Use the per-resource `/tv/{id}/changes` endpoint as the primary decision signal. Fall back to local heuristics only when the changes feed can't answer (gap > 14 days, brand-new import, or non-tracked fields).

---

## Current behavior (before this strategy)

The `tv/changes` discovery loop in [tmdb-crawler.py:584-599](tmdb-crawler.py#L584-L599) refreshes only the series row itself; it **never updates seasons or episodes**. The full-tree refresh exists only as a manual call via `f_tmdbserieallseasonsepisodestosql` ([tmdb_functions.py:3507-3554](tmdb_functions.py#L3507-L3554)), which calls one TMDb endpoint per season and one per episode (~410 calls for *Game of Thrones*).

The gap to close: make the changes loop **selectively** update seasons and episodes for the things that actually changed, without falling into per-show fan-outs.

---

## Strategy: four-tier refresh

When the global `tv/changes` poll reports that a series has changed:

| Tier | Cost | When | What it does |
| --- | --- | --- | --- |
| **T0 — Discover** | 1 paginated call (`/tv/changes`, already wired at [tmdb-crawler.py:524](tmdb-crawler.py#L524)) | Periodic crawl | Produce list of series IDs touched since last poll. |
| **T1 — Diagnose** | 1 call per series: `GET /tv/{id}/changes?start_date=<TIM_LAST_CHANGES_CHECK>` | Each series ID from T0 | Returns the list of *changed keys* (`name`, `seasons`, `episodes`, `images`, `videos`, `credits`, …). Map keys → which loaders to invoke. |
| **T2 — Series + plan** | 1 call: `GET /tv/{id}?append_to_response=credits,alternative_titles,external_ids` | When T1 reports any change, OR T1 gap > 14 days, OR `TIM_LAST_CHANGES_CHECK` is NULL | Refresh series row, parse activity signals, snapshot `seasons[]` in memory. |
| **T3 — Seasons** | 1 call per *selected* season: `GET /tv/{id}/season/{n}?append_to_response=credits,aggregate_credits,external_ids` | For each season selected by T2 rules | `f_tmdbseasontosqleverything`. **Already covers basic episode rows + crew + guest stars** via the embedded `episodes[]`. |
| **T4 — Episodes** | 1 call per *selected* episode | For each episode selected by T3 rules + T1 hints | `f_tmdbepisodetosqleverything`. Adds main cast credits, FR translation, stills, EN/FR videos. |

Stop-conditions are explicit at each tier — a stable ended series often stops at T2 with no children touched.

---

## T1: mapping changed keys to actions

`GET /tv/{id}/changes` returns entries shaped like `{"key": "episodes", "items": [{"action": "updated", "value": {"season_number": 8, "episode_number": 3}, ...}]}`.

| Changed key | Action |
| --- | --- |
| `name`, `original_name`, `overview`, `tagline`, `homepage`, `status`, `type` | T2 only — series row refresh covers it. |
| `images`, `videos`, `translations` | Invalidate the matching series-level `TIM_*_COMPLETED`, re-run only that loader. No seasons. |
| `credits` | Invalidate `TIM_CREDITS_COMPLETED`, re-run credits only. No seasons. |
| `seasons` | T3 needed. Use T2's `seasons[]` snapshot to pick which. |
| `episodes` | T4 needed. Items include `season_number` / `episode_number` — drill into exactly those. |
| `images` / `videos` items at season/episode level | T3 or T4 for just those targets. |

When T1 returns an empty list, stop after refreshing nothing (the global `tv/changes` flag can sometimes fire on metadata that doesn't surface in the per-resource feed — that's fine).

---

## T2 → T3 season-selection rules

Used when T1 reports `seasons` (or no T1 info available). A season is selected if **any** of:

1. **Missing locally.** Season appears in TMDb `seasons[]` but `f_tmdbseasongetid(serie, season_number)` returns 0.
2. **Episode count drift.** TMDb `seasons[].episode_count` ≠ local `T_WC_TMDB_SEASON.EPISODE_COUNT`.
3. **Season incomplete.** Any of `TIM_CREDITS_COMPLETED`, `TIM_TRANSLATIONS_COMPLETED`, `TIM_IMAGES_COMPLETED`, `TIM_VIDEOS_COMPLETED` is NULL.
4. **Recent season.** `DAT_AIR` within configurable recent-season window (default 120 days).
5. **Active-series latest season.** Season is the most recent and the series is "active" — see [activity signals](#activity-signals).

> Existence checks are **DB lookups**, never per-season HTTP probes. Compare the in-memory `/tv/{id}` `seasons[]` snapshot to the local rows.

## T3 → T4 episode-selection rules

For each season refreshed in T3, an episode is selected if **any** of:

1. **T1 named it.** Episode appears in T1's `episodes` items for this season.
2. **Episode incomplete.** Any `TIM_*_COMPLETED` on `T_WC_TMDB_EPISODE` is NULL.
3. **Recent episode.** `DAT_AIR` within configurable recent-episode window (default 45 days).
4. **Active season.** Episode belongs to the latest season of an active series.

Older stable episodes are never touched.

---

## Activity signals

To decide whether a series is "active" without re-fetching `/tv/{id}` on every periodic check, persist the signals on the series row. The schema in [doc/sql/TMDb-tables.sql](doc/sql/TMDb-tables.sql) has been extended with:

| Column | Type | Purpose |
| --- | --- | --- |
| `IN_PRODUCTION` | `int(1)` | TMDb `in_production` boolean → 0/1. |
| `NEXT_EPISODE_DAT_AIR` | `date` | TMDb `next_episode_to_air.air_date`. NULL once the series stops. |
| `NEXT_EPISODE_SEASON_NUMBER` | `int(5)` | Locator for the upcoming episode. |
| `NEXT_EPISODE_NUMBER` | `int(5)` | Locator for the upcoming episode. |
| `LAST_EPISODE_DAT_AIR` | `date` | TMDb `last_episode_to_air.air_date`. |
| `LAST_EPISODE_SEASON_NUMBER` | `int(5)` | Locator for the most recently aired episode. |
| `LAST_EPISODE_NUMBER` | `int(5)` | Locator for the most recently aired episode. |
| `TIM_LAST_CHANGES_CHECK` | `datetime` | What we send as `start_date` to `/tv/{id}/changes` next time. Updated at the end of every selective refresh. |

**A series is "active" if any of:**
- `IN_PRODUCTION = 1`, or
- `NEXT_EPISODE_DAT_AIR` is not NULL, or
- `LAST_EPISODE_DAT_AIR` ≥ today − `tmdb.refresh.active_series_lookback_days` (default 90).

`STATUS` (`Returning Series`, `Ended`, `Canceled`, `In Production`, `Planned`, `Pilot`) is informational only — TMDb leaves `Returning Series` set long after a show has actually stopped, so it can't be trusted alone.

### Migration for existing databases

`TMDb-tables.sql` is not idempotent. To upgrade in place:

```sql
ALTER TABLE T_WC_TMDB_SERIE
    ADD COLUMN IN_PRODUCTION int(1) DEFAULT NULL,
    ADD COLUMN NEXT_EPISODE_DAT_AIR date DEFAULT NULL,
    ADD COLUMN NEXT_EPISODE_SEASON_NUMBER int(5) DEFAULT NULL,
    ADD COLUMN NEXT_EPISODE_NUMBER int(5) DEFAULT NULL,
    ADD COLUMN LAST_EPISODE_DAT_AIR date DEFAULT NULL,
    ADD COLUMN LAST_EPISODE_SEASON_NUMBER int(5) DEFAULT NULL,
    ADD COLUMN LAST_EPISODE_NUMBER int(5) DEFAULT NULL,
    ADD COLUMN TIM_LAST_CHANGES_CHECK datetime DEFAULT NULL,
    ADD KEY IN_PRODUCTION (IN_PRODUCTION),
    ADD KEY NEXT_EPISODE_DAT_AIR (NEXT_EPISODE_DAT_AIR),
    ADD KEY LAST_EPISODE_DAT_AIR (LAST_EPISODE_DAT_AIR),
    ADD KEY TIM_LAST_CHANGES_CHECK (TIM_LAST_CHANGES_CHECK);
```

> Note: `TIM_SEASONS_COMPLETED` and `TIM_EPISODES_COMPLETED` are **already present** on `T_WC_TMDB_SERIE` ([TMDb-tables.sql:2085-2086](doc/sql/TMDb-tables.sql#L2085-L2086)) — no ALTER needed for those.

### Tunable windows

Add to `T_WC_SERVER_VARIABLE`:

| Key | Default | Used in |
| --- | --- | --- |
| `tmdb.refresh.recent_season_days` | 120 | Season rule 4 |
| `tmdb.refresh.recent_episode_days` | 45 | Episode rule 3 |
| `tmdb.refresh.active_series_lookback_days` | 90 | Activity signal definition |

---

## Already-tracked completion columns (reuse)

These columns already exist and are the basis for the "incomplete → refresh" rules. No schema change needed for them.

**`T_WC_TMDB_SERIE`**: `TIM_CREDITS_COMPLETED`, `TIM_KEYWORDS_COMPLETED`, `TIM_WIKIDATA_COMPLETED`, `TIM_WIKIPEDIA_COMPLETED`, `TIM_IMAGES_COMPLETED`, `TIM_VIDEOS_COMPLETED`, `TIM_SEASONS_COMPLETED`, `TIM_EPISODES_COMPLETED`.

**`T_WC_TMDB_SEASON`** ([TMDb-tables.sql:1906-1909](doc/sql/TMDb-tables.sql#L1906-L1909)): `TIM_CREDITS_COMPLETED`, `TIM_TRANSLATIONS_COMPLETED`, `TIM_IMAGES_COMPLETED`, `TIM_VIDEOS_COMPLETED`, plus `EPISODE_COUNT` and `DAT_AIR`.

**`T_WC_TMDB_EPISODE`** ([TMDb-tables.sql:288-291](doc/sql/TMDb-tables.sql#L288-L291)): `TIM_CREDITS_COMPLETED`, `TIM_TRANSLATIONS_COMPLETED`, `TIM_IMAGES_COMPLETED`, `TIM_VIDEOS_COMPLETED`, plus `DAT_AIR`.

---

## Code contract (to be implemented)

### Parser extension — `f_tmdbserietosql`

`f_tmdbserietosql` ([tmdb_functions.py:1604](tmdb_functions.py#L1604)) must additionally parse and persist:

- `in_production` → `IN_PRODUCTION`
- `next_episode_to_air.{air_date, season_number, episode_number}` → `NEXT_EPISODE_*`
- `last_episode_to_air.{air_date, season_number, episode_number}` → `LAST_EPISODE_*`

Use the existing `_f_tmdbparseairdate` helper for the dates.

### New function — `f_tmdbseriechangesget`

```python
def f_tmdbseriechangesget(lngserieid, strstartdate):
    """
    Call GET /tv/{id}/changes?start_date=YYYY-MM-DD.
    Returns the parsed `changes[]` list (each item is {key, items[]})
    or None on HTTP/JSON failure.
    """
```

`strstartdate = None` (or older than 14 days from today) → caller must skip T1 and go straight to T2 with full rules.

### New orchestrator — `f_tmdbserieselectiveseasonsepisodestosql`

```python
def f_tmdbserieselectiveseasonsepisodestosql(lngserieid):
    """
    Selective season+episode refresh driven by /tv/{id}/changes.
    Implements the four-tier strategy described in SERIE_UPDATE.md.
    Called from the tv/changes loop after f_tmdbserietosqleverything.

    Updates TIM_LAST_CHANGES_CHECK on success.
    Updates TIM_SEASONS_COMPLETED if every selected season completed.
    Updates TIM_EPISODES_COMPLETED if every selected episode completed.
    """
```

### Wiring — `tmdb-crawler.py:584-599`

After `f_tmdbserietosqleverything(lngid)` in the `tv/changes` per-series block, call `f_tmdbserieselectiveseasonsepisodestosql(lngid)`.

### Bootstrap path is unchanged

`f_tmdbserieallseasonsepisodestosql` ([tmdb_functions.py:3507-3554](tmdb_functions.py#L3507-L3554)) stays as the **bootstrap-only / operator-backfill** entrypoint. It is not called from the changes loop.

---

## Policy by content type

| Content type | Discovery | Series refresh | Seasons | Episodes |
| --- | --- | --- | --- | --- |
| **New import** | Manual / operator | Full | All (`f_tmdbserieallseasonsepisodestosql`) | All |
| **Series in `tv/changes`** | Global poll → T0 | T2 only if T1 says so | T3 only for selected | T4 only for selected |
| **Stable ended series** | Same | Usually no T2 (T1 returns empty) | None | None |
| **Active ongoing series** | Same | T2 every change | Last season + any incomplete | Recent + active-season episodes |

---

## Practical examples

### Example 1 — old ended series, small metadata edit

- T0 reports series 1399 (GoT) changed.
- T1: `/tv/1399/changes` returns `[{"key": "overview", ...}]`.
- T2: refresh `/tv/1399`. Done.
- T3 / T4: skipped.
- **Total: 2 TMDb calls.**

### Example 2 — new season added

- T0 reports the series changed.
- T1 returns `[{"key": "seasons", ...}, {"key": "episodes", ...}]`.
- T2: `/tv/{id}` snapshot — local DB is missing season N.
- T3: refresh only season N (one call, brings in basic episode rows for free).
- T4: refresh the episodes T1 named.
- **Total: ~3-5 calls** instead of ~50 for a 50-episode show.

### Example 3 — running season gains a new episode

- T1 returns `[{"key": "episodes", "items": [{value: {season_number: 8, episode_number: 3}}]}]`.
- T2: refresh `/tv/{id}` — `seasons[8].episode_count` is now higher than local.
- T3: refresh season 8.
- T4: refresh episode (8, 3).
- **Total: 4 calls.**

### Example 4 — periodic check on an active show with nothing changed

- T0 doesn't report it. Done.
- **Total: 0 series-specific calls.**

---

## What this strategy intentionally avoids

- Reloading all seasons on every series change.
- Reloading all episodes of all seasons.
- Re-fetching `/tv/{id}` repeatedly to re-read activity signals — they are persisted.
- HTTP existence probes per season (`f_tmdbseasonexist` should remain only for the bootstrap path).
- Calling episode endpoints for old completed episodes that are already stable.

---

## Final rule summary

### Series
- Always refresh on `tv/changes` discovery.
- Use `/tv/{id}/changes` to determine what to do next; never blanket-refresh children.
- Persist activity signals and `TIM_LAST_CHANGES_CHECK` on every selective refresh.

### Seasons
Refresh only if missing locally, `episode_count` drift, any completion timestamp NULL, recent `DAT_AIR`, or it's the latest season of an active series.

### Episodes
Refresh only if named by T1, any completion timestamp NULL, recent `DAT_AIR`, or it belongs to the active season.

---

## Expected result

- Stable ended series: 0-2 TMDb calls per discovery event.
- Active ongoing series: 3-6 calls per discovery event (vs. hundreds today on manual full refresh).
- Bootstrap path unchanged for new imports.
- Decisions are local: ongoing-series periodic checks can run from DB alone without any TMDb call.

---

## Future improvements

- Add `TIM_EPISODES_COMPLETED` on `T_WC_TMDB_SEASON` for season-level completion summary.
- Logging that records which rule selected each season/episode (debug aid for tuning the windows).
- A periodic "watch-list" job that re-runs T2+T3+T4 for active series even without a global `tv/changes` event, bounded by the configured windows.
- Ignore special seasons (`season_number = 0`) optionally per business rule.
