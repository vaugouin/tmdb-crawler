# AGENTS.md - Agent Guide for TMDb Crawler

This file gives you the agentic context you need to work on this codebase safely. For project overview, features, install / deploy steps and human-facing security / performance / troubleshooting material, read @README.md — that file is canonical and not duplicated here.

This is the single canonical guide for autonomous coding agents in this repository. Assistant-specific files such as @CLAUDE.md, and any future tool-specific guide such as `GEMINI.md`, should only point here and should not duplicate repository instructions.

Deeper specs live in their own files:
- @doc/sql/*.sql — reference DDL for the database schema; treat these files as read-only unless the user explicitly asks you to edit schema documentation

- For any project update, keep documentation aligned:
  - Update `README.md` for user-facing behavior, configuration, setup, deployment, troubleshooting, or verification changes.
  - Update this file only when agent workflow or safety context changes.

---

## Related repositories (project ecosystem)

`tmdb-crawler` is one stage of **Agent BBB**, a multi-repository movie/TV database system owned by GitHub user `vaugouin`. All sibling repos live under `%USERPROFILE%/Code/<repo>` and at `github.com/vaugouin/<repo>`; they are interdependent stages of one pipeline that converges on a shared MySQL/MariaDB database (`T_WC_*` tables) and a ChromaDB vector store. The canonical roster of sibling repositories is kept in `%USERPROFILE%/Nestor/projets/t2s-backlog/topics/related-repositories.txt` (documentation repo `Nestor`, outside `Code/`).

Pipeline stages:
- **Infrastructure** — `python` (shared crawler base image), `chromadb` (vector service), `reverseproxy` (NGINX TLS ingress), `chromadb-security-test` (firewall validation).
- **Acquisition** — `tmdb-crawler`, `imdb-crawler`, `sparql-crawler`, `sparql-movies-persons`, `wikidata-crawler`, `wikipedia-crawler`, `selenium-tmdb`, `download-images`, `sqlite-plex-to-tmdb`, `movieparadise`.
- **Preprocessing → `T_WC_T2S_*`** — `tmdb-movie-preprocess`, `tmdb-person-preprocess`, `keywords-processing`.
- **Semantic index & name resolution** — `embedding-update`, `embedding-query`, `rapidfuzz_query`.
- **Serving** — `fastapi-text2sql` (NL→SQL API + MCP server), `voice-agent`, `tmdb-front` (PHP web front-end).
- **Evaluation** — `eval-text2sql`, `extract-movie-questions`.
- **Maintenance & tooling** — `plex-duplicates`, `subtitle-translate`, `powershell`, `playwright-test`.
- **Monitoring & observability** — `data-monitoring`.

**This repository's role:** Acquisition stage and the primary data source. Synchronises movies, TV series, persons, collections, keywords, networks, and production companies from the TMDb API into the `T_WC_TMDB_*` tables that the rest of the pipeline builds on. Its keyword output feeds `keywords-processing`; its entity tables feed `tmdb-movie-preprocess` and `tmdb-person-preprocess`.

---

## Where things live (file → role)

Edit at the right layer; the architecture is intentionally split.

## Code conventions

- **Hungarian notation** for variables (legacy style):
  - `str` — strings (`strtablename`, `strapiversion`)
  - `lng` — integers (`lngpage`, `lngrowsperpage`)
  - `dbl` — floats (`dblavailableram`)
  - `arr` — lists / arrays
  - `int` — boolean-like flags (`intcleanupenabled`, `intentity`)
- **Function naming**: public pipeline entry points use `f_` (`f_text2sql`, `f_entity_extraction`, `f_resolve_complex_question`, `f_answer_single_value`, `f_hello_world`); private helpers use `_` (`_call_chat_llm`, `_normalize_llm_model`).
- **Docstrings**: Google-style on public functions.
- **Error handling**: broad try/except with console logging; surface failures via the `error` response field and the `messages` trace. Database execution errors are not returned directly to clients — they go through the complex-question retry path when enabled.
- **JSON serialization**: use `logs.decimal_serializer()` for `Decimal` and `datetime`.

---

## Database Schema Sources

Full DDL lives under [doc/sql/](doc/sql/); do not duplicate table definitions here. Treat these files as reference-only unless the user explicitly asks for schema-doc edits.

- [doc/sql/IMDb-tables.sql](doc/sql/T2S-tables.sql) — source IMDb tables.
- [doc/sql/T2S-tables.sql](doc/sql/T2S-tables.sql) — canonical Text2SQL read-model tables used by prompts, API detail endpoints, cache, and evaluation tables.
- [doc/sql/TMDb-tables.sql](doc/sql/TMDb-tables.sql) — upstream/source TMDb tables and reference tables.
- [doc/sql/Wikidata-tables.sql](doc/sql/Wikidata-tables.sql) — Wikidata staging and canonical tables.
- [doc/sql/Wikipedia-tables.sql](doc/sql/Wikipedia-tables.sql) — Wikipedia tables.

---

## Tracking / monitoring queries

Curated, hand-written operational queries live in [doc/sql/](doc/sql/) (for example,
`doc/sql/monitoring.sql`), alongside the auto-generated DDL dumps in that folder.

**Regular task — ship a tracking query with every new feature.** Whenever a change
adds or starts populating a column, table, or pipeline output (a new external id, a
new entity, a new completion flag, …), add a matching tracking query to
`doc/sql/monitoring.sql` in the same change. The query should let an operator
**verify the feature is working and measure coverage/progress** — typically a
`COUNT(col)` fill rate vs `COUNT(*)`, or a per-`DAT_CREAT` collection-rate view.
Prefer indexed columns so the query stays cheap, and add a one-line comment stating
what it tracks, the backlog ref, and how to read a NULL/zero (often "upstream has no
value", not a crawler miss). This is not optional polish — it is part of "done".

Backlog refs: TMDB-CRAWLER-004 (origin of the monitoring file), TMDB-CRAWLER-005
(`ID_TVDB` coverage across series/seasons/episodes).

---

## Entity fetch outcomes (TMDB-CRAWLER-027)

Every `f_tmdb<entity>tosql()` and `f_tmdb<entity>tosqleverything()` returns one of
`INT_TMDB_FETCH_OK` / `INT_TMDB_FETCH_GONE` / `INT_TMDB_FETCH_ERROR`, never `None`.
**Check the return value at any new call site**: a `GONE` (TMDb `status_code 34`)
must stop the chain, not just the current call — that is what keeps a deleted id
from costing ten doomed API calls per run.

Dead ids are recorded in `T_WC_TMDB_ID_NOT_FOUND`, which the crawler **creates on
startup** (`f_tmdbidnotfoundensuretable()`), so no manual migration is needed on the
VPS; the canonical DDL is mirrored in `doc/sql/TMDb-tables.sql`. Any new process
query that feeds the API from a DB list must append `f_notfoundfilter(<entity type>,
<id column>)` before its `ORDER BY`, otherwise dead ids come back on every run. Entity
type strings are `movie`, `person`, `serie`, `collection`, `company`, `network`,
`list`.

---

## Additive release/watch snapshots (TMDB-CRAWLER-020 / -030)

`T_WC_TMDB_MOVIE.DAT_RELEASE` remains owned by the established Movie Details path
in `f_tmdbmovietosql()`. Never derive or overwrite it from `/release_dates`.
Country-specific release events and movie/series watch providers are independent,
authoritative snapshots. Build and validate every row in memory first, then replace
one title's rows and completion marker in a single transaction. A complete empty
`results` collection clears the old snapshot; a network/API error, rate limit,
malformed payload, incomplete country/provider entry, or database exception must
leave the old snapshot intact. Watch-provider consumers must retain the TMDb link,
show crawl freshness, and attribute JustWatch; these rows are not cinema showtimes.

The provider catalogue is a separate entity-bearing snapshot. Process 19 fetches
`/watch/providers/movie` and `/watch/providers/tv`; `T_WC_TMDB_WATCH_PROVIDER`
owns stable identity (`ID_PROVIDER`, name, logo), while catalogue membership and
country priority live in `T_WC_TMDB_WATCH_PROVIDER_CATALOG` and
`T_WC_TMDB_WATCH_PROVIDER_REGION`; `T_WC_TMDB_WATCH_PROVIDER_CATALOG_STATE`
records the successful snapshot time and expected row counts for each catalogue.
The per-work movie/series tables remain the qualified associations and own
country, monetization mode, TMDb link, response order and observation time. Never
copy a country priority or work availability onto provider identity. Validate a
whole catalogue before replacing that catalogue's membership/regions; an
unexpectedly empty global catalogue is an error, unlike a valid empty per-work
availability snapshot.

---

## SQL Object Naming Conventions

- SQL table and column names are uppercase snake case, except legacy imported TMDb genre columns such as `id` and `name`.
- Persistent tables use `T_WC_*`.
- Text2SQL read-model tables use `T_WC_T2S_*`.
- TMDb source/reference tables use `T_WC_TMDB_*`.
- Wikidata tables use `T_WC_WIKIDATA_*`; staging tables use `STG_T_WC_WIKIDATA_*`.
- Wikipedia tables use `T_WC_WIKIPEDIA_*`.
- Join tables usually follow `T_WC_T2S_{PARENT}_{CHILD}`, for example `T_WC_T2S_MOVIE_GENRE`, `T_WC_T2S_PERSON_MOVIE`.
- Primary keys are usually `ID_{ENTITY}` for entity tables, `ID_ROW` for generic/join rows, or a table-specific surrogate such as `ID_T2S_PERSON_MOVIE`.
- Foreign keys reuse the referenced primary-key name, for example `ID_MOVIE`, `ID_PERSON`, `ID_GENRE`.
- Date columns use `DAT_*`; datetime/timestamp columns use `TIM_*`.
- Boolean-like flags use `IS_*` or legacy integer flags such as `DELETED`.
- Ordering uses `DISPLAY_ORDER`.
- Aggregate counters use `*_COUNT`.
- Media paths use `*_PATH`.
- Language-specific labels/titles often use suffixes such as `_FR`; generic language rows use `LANG`.
- RapidFuzz/generated search columns use `*_NORM` and `*_KEY`; popularity tie-breakers commonly use `POPULARITY`.
- Index names are mixed legacy style. Preserve existing style: simple `KEY COLUMN_NAME`, `IDX_*` for indexes, `UK_*` for unique keys, `FK_*` for foreign keys, and `ft_*` for FULLTEXT indexes.

---

## Encoding

Keep Markdown, prompt files, JSON config, and logs UTF-8. These files contain non-ASCII names and multilingual examples. Avoid editor or terminal operations that rewrite them with mojibake.

---

## Build & deployment (Docker)

This crawler is built and run as a Docker container via the repo's root `Dockerfile`. The image is based on `python:3.10.5-slim-buster`, installs `requirements.txt`, copies the repo into `/app`, and runs `python ./tmdb-crawler.py` as its `CMD`. Pass database/API credentials at runtime (e.g. `docker run --env-file ...`); do not bake secrets into the image.

---

**Last Updated**: 2026-08-19
**Current Version**: 1.0.0 

## Backlog (Nestor second-brain)

The prioritized, agent-ready implementation backlog for this repo lives in the **Nestor**
knowledge repo (a separate repo, not cloned alongside this one):

- This repo: `C:\Users\vaugo\Nestor\projets\t2s-backlog\repos\tmdb-crawler.md`
- Cross-repo dashboard: `C:\Users\vaugo\Nestor\projets\t2s-backlog\index.md`

Consult it before implementing: tasks are `TMDB-CRAWLER-NNN` with status (done / in-progress /
todo), priority, and quick-wins. NOTE: these are local paths on Philippe's PC and do not
resolve on the VPS or on cloud agents (claude.ai/code).

## SQL files live in `doc/sql/`

Stack-wide convention, set 2026-08-20. Every **read-only** `.sql` of this repo, audit
queries, monitoring queries, exports, reference DDL dumps, lives in `doc/sql/`, never
at the root and never in a `doc/queries/` of its own.

Two deliberate exceptions, and they are the reason the rule is worded around reading
rather than around file type. A `.sql` **executed by code** stays where the code expects
it, because moving it breaks a run silently. And a `.sql` that **writes** (migration,
seed, `DELETE` cleanup) stays put too: it belongs to a procedure, not to documentation.
When in doubt, ask whether running the file twice by accident would change the database.
If yes, it is not a `doc/sql/` file.
