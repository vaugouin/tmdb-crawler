# TV Seasons & Episodes — Loader

This PR extends the crawler to load TMDb season and episode data into MariaDB.
Before it, only the series-level row (`T_WC_TMDB_SERIE`) was populated; per-season
and per-episode metadata, credits and media were missing.

## 1. Database evolution

Ten new tables are added to `doc/sql/TMDb-tables.sql`. They follow the existing
`T_WC_TMDB_SERIE_*` and `T_WC_TMDB_PERSON_SERIE` conventions (same audit columns:
`DELETED`, `DISPLAY_ORDER`, `ID_CREATOR`, `DAT_CREAT`, `ID_OWNER`, `TIM_UPDATED`,
`ID_USER_UPDATED`).

| Table | PK | Purpose |
| --- | --- | --- |
| `T_WC_TMDB_SEASON` | `ID_SEASON` (TMDb id) | Per-season metadata: `SEASON_NUMBER`, `TITLE`, `OVERVIEW`, `DAT_AIR` (+ `AIR_YEAR`/`MONTH`/`DAY`), `POSTER_PATH`, `EPISODE_COUNT`, `VOTE_AVERAGE`, external IDs (`ID_IMDB`, `ID_WIKIDATA`, `ID_TVDB`), `TIM_*_COMPLETED` flags |
| `T_WC_TMDB_SEASON_IMAGE` | `ID_ROW` (auto) | Posters / backdrops returned by `/tv/{id}/season/{n}/images` |
| `T_WC_TMDB_SEASON_VIDEO` | `ID_ROW` (auto) | Trailers / clips per language |
| `T_WC_TMDB_SEASON_LANG` | `ID_ROW` (auto) | Per-language `TITLE` and `OVERVIEW` |
| `T_WC_TMDB_PERSON_SEASON` | `ID_TMDB_PERSON_SEASON` (auto) | Cast / crew, modeled on `T_WC_TMDB_PERSON_SERIE`. Adds `ID_SEASON`, `SEASON_NUMBER`, and `TOTAL_EPISODE_COUNT` (populated from `aggregate_credits`) |
| `T_WC_TMDB_EPISODE` | `ID_EPISODE` (TMDb id) | Per-episode metadata: `EPISODE_NUMBER`, `TITLE`, `OVERVIEW`, `DAT_AIR`, `RUNTIME`, `PRODUCTION_CODE`, `EPISODE_TYPE`, `STILL_PATH`, vote, external IDs, completion flags |
| `T_WC_TMDB_EPISODE_IMAGE` | `ID_ROW` (auto) | Episode stills (`/.../episode/{m}/images`) |
| `T_WC_TMDB_EPISODE_VIDEO` | `ID_ROW` (auto) | Episode-level videos per language |
| `T_WC_TMDB_EPISODE_LANG` | `ID_ROW` (auto) | Per-language `TITLE` and `OVERVIEW` |
| `T_WC_TMDB_PERSON_EPISODE` | `ID_TMDB_PERSON_EPISODE` (auto) | Cast, crew and guest stars; `CREDIT_TYPE` ∈ `{cast, crew, guest}`. Modeled on `T_WC_TMDB_PERSON_SERIE`, with `ID_SEASON`, `ID_EPISODE`, `SEASON_NUMBER`, `EPISODE_NUMBER` |

### Migration

Re-running `TMDb-tables.sql` against an existing database is **not** idempotent
(it uses `CREATE TABLE`, not `IF NOT EXISTS`). To upgrade in place, extract the
new statements only:

```sql
-- Take everything between the two markers in doc/sql/TMDb-tables.sql:
--   "-- TV Seasons & Episodes"  (start)
--   the closing "/*!40101 SET CHARACTER_SET_CLIENT ..." (end)
-- and execute that block on the existing database.
```

A fresh install runs `TMDb-tables.sql` end-to-end as documented in the README.

## 2. Update pipeline

All new functions live in `tmdb_functions.py` and follow the existing
`f_tmdb<entity><action>tosql(...)` naming.

### Per-season functions

| Function | TMDb endpoint | Tables written |
| --- | --- | --- |
| `f_tmdbseasontosql(serie, season)` | `GET /tv/{serie}/season/{season}?append_to_response=credits,aggregate_credits,external_ids` | `T_WC_TMDB_SEASON`, `T_WC_TMDB_PERSON_SEASON`, `T_WC_TMDB_EPISODE` (basic + crew + guest stars from the embedded `episodes[]`), `T_WC_TMDB_PERSON_EPISODE` |
| `f_tmdbseasonlangtosql(serie, season, lang)` | `GET /tv/{serie}/season/{season}?language={lang}` | `T_WC_TMDB_SEASON_LANG` |
| `f_tmdbseasonimagestosql(serie, season)` | `GET /tv/{serie}/season/{season}/images` | `T_WC_TMDB_SEASON_IMAGE` |
| `f_tmdbseasonvideotosql(serie, season, lang)` | `GET /tv/{serie}/season/{season}/videos?language={lang}` | `T_WC_TMDB_SEASON_VIDEO` |
| `f_tmdbseasonexist(serie, season)` | `GET /tv/{serie}/season/{season}` | — (returns `False` only on TMDb status `34`) |
| `f_tmdbseasondelete(season_id)` | — | Cascade delete: episodes (via `f_tmdbepisodedelete`), then `_LANG`, `_IMAGE`, `_VIDEO`, `PERSON_SEASON`, `SEASON` |
| `f_tmdbseasonsetcreditscompleted(season_id)` | — | Stamps `TIM_CREDITS_COMPLETED` |
| `f_tmdbseasonsettranslationscompleted(season_id)` | — | Stamps `TIM_TRANSLATIONS_COMPLETED` |
| `f_tmdbseasontosqleverything(serie, season)` | — | Composes the six calls above (FR translation + EN/FR videos) |

Credits storage prefers `aggregate_credits` over `credits` whenever the
endpoint returns it: each role / job becomes a separate row, identified by its
own `credit_id`, with `TOTAL_EPISODE_COUNT` set from TMDb's `episode_count`.

### Per-episode functions

| Function | TMDb endpoint | Tables written |
| --- | --- | --- |
| `f_tmdbepisodetosql(serie, season, episode)` | `GET /tv/{serie}/season/{season}/episode/{episode}?append_to_response=credits,external_ids` | `T_WC_TMDB_EPISODE`, `T_WC_TMDB_PERSON_EPISODE` (cast + crew + guest stars, authoritative — purges stale rows) |
| `f_tmdbepisodelangtosql(...)` | `GET .../episode/{episode}?language={lang}` | `T_WC_TMDB_EPISODE_LANG` |
| `f_tmdbepisodeimagestosql(...)` | `GET .../episode/{episode}/images` | `T_WC_TMDB_EPISODE_IMAGE` |
| `f_tmdbepisodevideotosql(...)` | `GET .../episode/{episode}/videos?language={lang}` | `T_WC_TMDB_EPISODE_VIDEO` |
| `f_tmdbepisodeexist(...)` | `GET .../episode/{episode}` | — |
| `f_tmdbepisodedelete(episode_id)` | — | Cascade delete of `_LANG`, `_IMAGE`, `_VIDEO`, `PERSON_EPISODE`, `EPISODE` |
| `f_tmdbepisodesetcreditscompleted(episode_id)` | — | Stamps `TIM_CREDITS_COMPLETED` |
| `f_tmdbepisodesettranslationscompleted(episode_id)` | — | Stamps `TIM_TRANSLATIONS_COMPLETED` |
| `f_tmdbepisodetosqleverything(serie, season, episode)` | — | Composes the six calls above |

If the parent season row is missing when an episode call runs, the season is
bootstrapped via `f_tmdbseasontosql`.

### Orchestration

```python
f_tmdbserieallseasonsepisodestosql(serie_id, intloadepisodes=1)
```

1. `GET /tv/{serie_id}` to read `seasons[].season_number`.
2. For each season → `f_tmdbseasontosqleverything` (this already loads every
   episode's basic data + crew + guest stars via the embedded `episodes[]`).
3. If `intloadepisodes=1` (default), iterate the episodes stored in DB and call
   `f_tmdbepisodetosqleverything` for each — this adds main cast credits, FR
   translation, stills and EN/FR videos.

It is **not** wired into `f_tmdbserietosqleverything`, because the per-episode
fan-out multiplies API calls dramatically. Trigger it explicitly.

### Internal helpers

- `_f_tmdbparseairdate(str)` — splits `YYYY-MM-DD` into `(date, year, month, day)`
- `f_tmdbseasongetid(serie, season)` / `f_tmdbepisodegetid(serie, season, episode)` —
  DB lookups used by image/video/lang functions to find the TMDb numeric id
  without extra API calls
- `_f_tmdbepisoderowtosql`, `_f_tmdbepisodecreditstosql`,
  `_f_tmdbseasoncreditstosql` — internal upsert helpers; the credit helpers
  delete obsolete rows when called authoritatively

### Manual usage example (Game of Thrones, id 1399)

```python
import citizenphil as cp
import tmdb_functions as tf

lngid = 1399
tf.f_tmdbserietosqleverything(lngid)               # series row + FK target
tf.f_tmdbserieallseasonsepisodestosql(lngid)       # ~410 API calls for GoT
```

Lighter alternatives:

```python
tf.f_tmdbserieallseasonsepisodestosql(lngid, intloadepisodes=0)   # season-level only
tf.f_tmdbseasontosqleverything(lngid, 1)                          # one season
tf.f_tmdbepisodetosqleverything(lngid, 1, 1)                      # one episode
```

## 3. Tests

The crawler is library-style code with no existing test suite, so this PR
ships with manual validation steps rather than automated tests.

### Static checks

```bash
python3 -c "import ast; ast.parse(open('tmdb_functions.py').read())"
```

Should print nothing (success). Already verified during development.

### Import smoke test (no DB required)

```bash
python3 -c "
import os, sys, types
os.environ.setdefault('TMDB_API_DOMAIN_URL','https://example.invalid')
os.environ.setdefault('TMDB_API_TOKEN','x')
os.environ.setdefault('DB_NAMESPACE','')
cp = types.ModuleType('citizenphil')
cp.f_sqlupdatearray = lambda *a, **k: None
cp.f_stringtosql    = lambda s: s
cp.f_getconnection  = lambda: None
sys.modules['citizenphil'] = cp
import tmdb_functions as t
for fn in ['f_tmdbseasontosql','f_tmdbseasontosqleverything',
           'f_tmdbepisodetosql','f_tmdbepisodetosqleverything',
           'f_tmdbserieallseasonsepisodestosql']:
    assert hasattr(t, fn), fn
print('OK')
"
```

Verifies the module imports and all public entry points exist.

### End-to-end test against TMDb + MariaDB

Prerequisites: a working `.env` (TMDb token + DB credentials) and the new
DDL applied (see migration note above).

1. Pick a small, stable series (e.g. *The Mandalorian* — id `82856`, 3 seasons,
   ~24 episodes) to keep the test fast:

   ```python
   import citizenphil as cp
   import tmdb_functions as tf
   lngid = 82856
   tf.f_tmdbserietosqleverything(lngid)
   tf.f_tmdbserieallseasonsepisodestosql(lngid)
   ```

2. Validate counts in MariaDB:

   ```sql
   SELECT COUNT(*) AS seasons   FROM T_WC_TMDB_SEASON   WHERE ID_SERIE = 82856;
   SELECT COUNT(*) AS episodes  FROM T_WC_TMDB_EPISODE  WHERE ID_SERIE = 82856;
   SELECT CREDIT_TYPE, COUNT(*) FROM T_WC_TMDB_PERSON_EPISODE
     WHERE ID_SERIE = 82856 GROUP BY CREDIT_TYPE;
   ```

   Expect `CREDIT_TYPE` to include all three of `cast`, `crew`, `guest`.

3. Validate completion timestamps were stamped:

   ```sql
   SELECT SEASON_NUMBER, TIM_CREDITS_COMPLETED, TIM_IMAGES_COMPLETED,
          TIM_VIDEOS_COMPLETED, TIM_TRANSLATIONS_COMPLETED
     FROM T_WC_TMDB_SEASON
    WHERE ID_SERIE = 82856 ORDER BY SEASON_NUMBER;
   ```

4. Idempotency: re-run step 1. Counts should not change; `TIM_UPDATED` should
   move forward; obsolete-row purge logic in
   `_f_tmdbepisodecreditstosql(purge=True)` and `_f_tmdbseasoncreditstosql`
   should leave row counts steady.

### Spot-checks worth running

- A series with **specials** (season 0) — confirms the `season_number=0` path.
- A series with **multiple roles per actor** (e.g. *Westworld*, id `63247`) —
  confirms `aggregate_credits` produces one `T_WC_TMDB_PERSON_SEASON` row per
  role/credit_id, with distinct `CAST_CHARACTER` and `TOTAL_EPISODE_COUNT`.
- An episode with **guest stars** — confirms `CREDIT_TYPE='guest'` rows in
  `T_WC_TMDB_PERSON_EPISODE`.
- `f_tmdbseasondelete(season_id)` then re-run: confirms cascade and successful
  re-import.
