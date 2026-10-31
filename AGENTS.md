# AGENTS.md - Agent Guide for TMDb Crawler

Rules an agent needs to work on this codebase safely. Overview, setup, process catalogue, deployment and monitoring live in @README.md, which is canonical: update it for any user-facing change (behaviour, configuration, deployment, verification), and update this file only when agent workflow or safety context changes. `CLAUDE.md` and any other tool-specific file only point here.

## Related repositories (project ecosystem)

`tmdb-crawler` is the acquisition stage and primary data source of **Agent BBB** (sibling repos under `%USERPROFILE%/Code/<repo>` and `github.com/vaugouin/<repo>`, converging on a shared MariaDB with `T_WC_*` tables). Canonical roster of siblings: `%USERPROFILE%/Nestor/projets/t2s-backlog/topics/related-repositories.txt`.

It fills the `T_WC_TMDB_*` tables (movies, series, persons, collections, keywords, networks, companies) from the TMDb API. Downstream: `keywords-processing` (keywords), `tmdb-movie-preprocess` and `tmdb-person-preprocess` (entity tables), `selenium-tmdb` (writes Wikidata QIDs onto TMDb that processes 23/29/30 pick up).

## Code conventions

- **Hungarian notation** for variables (legacy): `str`, `lng` (integers), `dbl` (floats), `arr` (lists), `int` (boolean-like flags).
- Function names: `f_` prefix (`f_tmdbmovietosql`, `f_notfoundfilter`); private helpers `_`.
- Keep Markdown, JSON and logs UTF-8: they carry non-ASCII names; avoid operations that rewrite them with mojibake.

## SQL files live in `doc/sql/`

Stack-wide convention (2026-08-20). Every **read-only** `.sql` (audit, monitoring, exports, reference DDL) lives in `doc/sql/`, never at the root nor in a `doc/queries/`. Exceptions: a `.sql` **executed by code** stays where the code expects it (moving it breaks a run silently), and a `.sql` that **writes** (migration, seed, cleanup) stays with its procedure. Test: if running it twice by accident would change the database, it is not a `doc/sql/` file.

The DDL files in `doc/sql/` (`IMDb-`, `T2S-`, `TMDb-`, `Wikidata-`, `Wikipedia-tables.sql`) are the schema reference: do not duplicate table definitions elsewhere, and edit them only when asked.

## Tracking / monitoring queries

**Ship a tracking query with every feature** that adds or starts populating a column, table or pipeline output: add it to [doc/sql/monitoring.sql](doc/sql/monitoring.sql) in the same change. It must let an operator verify the feature works and measure coverage (typically `COUNT(col)` vs `COUNT(*)`, or a per-`DAT_CREAT` rate), stay cheap (indexed columns), and carry a one-line comment: what it tracks, the backlog ref, how to read a NULL/zero (often "upstream has no value", not a crawler miss). This is part of "done" (TMDB-CRAWLER-004).

## Entity fetch outcomes (TMDB-CRAWLER-027)

Every `f_tmdb<entity>tosql()` / `f_tmdb<entity>tosqleverything()` returns `INT_TMDB_FETCH_OK` / `_GONE` / `_ERROR`, never `None`. **Check it at every new call site**: a `GONE` (TMDb `status_code 34`) must stop the whole chain, not just the current call.

Dead ids go to `T_WC_TMDB_ID_NOT_FOUND`, created by the crawler on startup (no VPS migration; DDL mirrored in `doc/sql/TMDb-tables.sql`). Any new process query feeding the API from a DB list must append `f_notfoundfilter(<entity type>, <id column>)` before its `ORDER BY`, or dead ids come back every run. Entity types: `movie`, `person`, `serie`, `collection`, `company`, `network`, `list`. Ledger behaviour: README § Deleted TMDb ids.

## Resume after an interruption

Mechanism: README § Resume after an interruption. The run order is built from the four scope dicts declared before `f_runprocessscope` (`arrprocessscopenew`, `arrtmdbchanges`, `arrmissingimages`, `arrprocessscoperefresh`). When adding a process:

- Put it in one of those dicts. A loop of its own must call `f_resumeskip(intindex)` then `f_resumemark(intindex)` at the top of each iteration, or a resume lands in the wrong place.
- Add it to `arrprocessorderedbyid` only if its query is ordered by id ascending. Never for a query ordered by popularity or `TIM_UPDATED`: skipping "ids up to the last one" would drop unprocessed rows.
- Every row must be safe to process twice: the row running at the stop is replayed.

## Additive release/watch snapshots (TMDB-CRAWLER-020 / -030)

Behaviour: README § Release-date, provider-entity and work-provider snapshots. Rules:

- `T_WC_TMDB_MOVIE.DAT_RELEASE` belongs to the Movie Details path in `f_tmdbmovietosql()`. Never derive or overwrite it from `/release_dates`.
- Build and validate every row in memory, then replace one title's rows and its completion marker in a single transaction. A complete empty `results` clears the old snapshot; any network/API error, rate limit, malformed or incomplete payload, or DB exception leaves it intact.
- Provider catalogue (process 19): validate a whole catalogue before replacing its membership/regions; an empty global catalogue is an error (unlike a valid empty per-work snapshot). Never copy a country priority or work availability onto provider identity (`T_WC_TMDB_WATCH_PROVIDER`).
- Watch-provider consumers must keep the TMDb link, show crawl freshness and attribute JustWatch; these rows are not cinema showtimes.

## SQL Object Naming Conventions

- Tables and columns uppercase snake case (except legacy TMDb genre columns `id`, `name`). Prefixes: `T_WC_*` persistent, `T_WC_T2S_*` Text2SQL read model, `T_WC_TMDB_*`, `T_WC_WIKIDATA_*` (staging `STG_T_WC_WIKIDATA_*`), `T_WC_WIKIPEDIA_*`. Join tables `T_WC_T2S_{PARENT}_{CHILD}`.
- Keys: `ID_{ENTITY}` for entities, `ID_ROW` for generic/join rows (or a surrogate like `ID_T2S_PERSON_MOVIE`); foreign keys reuse the referenced key name.
- Columns: `DAT_*` dates, `TIM_*` datetimes, `IS_*` or legacy `DELETED` flags, `DISPLAY_ORDER`, `*_COUNT`, `*_PATH`, `_FR`-style language suffixes (generic rows use `LANG`), `*_NORM` / `*_KEY` for RapidFuzz columns, `POPULARITY` as tie-breaker.
- Indexes: preserve the mixed legacy style (`KEY COLUMN_NAME`, `IDX_*`, `UK_*`, `FK_*`, `ft_*` for FULLTEXT).

## Build & deployment (Docker)

See README § Usage and the `Dockerfile`. Pass credentials at runtime (`--env-file`), never bake secrets into the image.

## Clock (2026-10-19, DEPLOYMENT-015)

Naive `DATETIME` / `DATE` columns hold naive Europe/Paris time. Compute them in Python with `datetime.now(cp.paris_tz)` (`paris_tz` inside `tmdb_functions.py`; pytz, so the image needs no `tzdata`), never with a bare `datetime.now()` (UTC in the container) nor with the server clock `NOW()` / `CURDATE()`, in a write or in a comparison (TMDB-CRAWLER-034). A human-read date is Europe/Paris with its offset, never a fixed `+02:00`. `tmdb_functions.py` is byte-identical in sparql-crawler and wikidata-crawler: carry any fix to both copies and compare the hashes.

---

**Last Updated**: 2026-10-31
**Current Version**: 1.0.9 

## Backlog (Nestor second-brain)

Tasks `TMDB-CRAWLER-NNN` (status, priority, quick wins) live in the Nestor repo; consult before implementing: `C:\Users\vaugo\Nestor\projets\t2s-backlog\repos\tmdb-crawler.md` (dashboard: `...\t2s-backlog\index.md`). These paths exist only on Philippe's PC, not on the VPS or cloud agents.

## The `*_V1` Wikidata tables are frozen: never read a fact from them

The SPARQL crawlers that filled `T_WC_WIKIDATA_MOVIE_V1`, `_SERIE_V1`, `_PERSON_V1` and siblings are **stopped** (`WIKIDATA-CRAWLER-015`). Only `wikipedia-crawler` still writes them, and only the image columns, so **a recent `TIM_UPDATED` on a V1 table is not evidence that its facts are current**.

Read Wikidata facts from V2: the entity in `T_WC_WIKIDATA_<TYPE>`, external ids as **statements** (`P345` IMDb, `P4947` / `P4983` / `P4985` TMDb movie / series / person) through `T_WC_WIKIDATA_STATEMENT` and `T_WC_WIKIDATA_EXTERNAL_ID_VALUE`. Worked examples: `f_wikidataidfixsql` in `tmdb-crawler.py`, `selenium-tmdb/preprocess/wikidata-id-*.sql`.

The failure is quiet: a V1 read returns the plausible-looking subset V1 happened to know. Process 23 ran daily on V1 while its target population grew a hundredfold unseen (fixed 2026-09-14). Two traps when porting:

- `<>` against a nullable column swallows the `IS NULL` case; test what you mean ("our copy is unusable") instead.
- V2 joins multiply rows (several `P345` per entity, shared IMDb ids). `SELECT DISTINCT` on the id alone when only the id is wanted; otherwise a scalar subquery (see `selenium-tmdb/preprocess/wikidata-id-movie-fix.sql`).
