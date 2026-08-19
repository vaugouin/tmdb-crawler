-- =============================================================================
-- tmdb-crawler — monitoring / useful queries
-- Curated, hand-written operational queries (NOT auto-generated dumps; those
-- live in ../sql/). Backlog ref: TMDB-CRAWLER-004.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Collection progress per day
-- How many rows were created each day, most recent first. DAT_CREAT is indexed
-- on all three tables, so these are cheap.
-- -----------------------------------------------------------------------------

-- Episodes collected per day
SELECT COUNT(*) AS COMPTE, DAT_CREAT
FROM T_WC_TMDB_EPISODE
GROUP BY DAT_CREAT
ORDER BY DAT_CREAT DESC;

-- Seasons collected per day
SELECT COUNT(*) AS COMPTE, DAT_CREAT
FROM T_WC_TMDB_SEASON
GROUP BY DAT_CREAT
ORDER BY DAT_CREAT DESC;

-- TV series collected per day
SELECT COUNT(*) AS COMPTE, DAT_CREAT
FROM T_WC_TMDB_SERIE
GROUP BY DAT_CREAT
ORDER BY DAT_CREAT DESC;

-- -----------------------------------------------------------------------------
-- Combined daily view (series + seasons + episodes side by side)
-- One row per day with a column per entity. Useful to eyeball the crawl rate
-- across the whole TV pipeline at once.
-- -----------------------------------------------------------------------------
SELECT
    d.DAT_CREAT,
    (SELECT COUNT(*) FROM T_WC_TMDB_SERIE   s WHERE s.DAT_CREAT = d.DAT_CREAT) AS SERIES,
    (SELECT COUNT(*) FROM T_WC_TMDB_SEASON  e WHERE e.DAT_CREAT = d.DAT_CREAT) AS SEASONS,
    (SELECT COUNT(*) FROM T_WC_TMDB_EPISODE p WHERE p.DAT_CREAT = d.DAT_CREAT) AS EPISODES
FROM (
    SELECT DAT_CREAT FROM T_WC_TMDB_SERIE
    UNION SELECT DAT_CREAT FROM T_WC_TMDB_SEASON
    UNION SELECT DAT_CREAT FROM T_WC_TMDB_EPISODE
) d
WHERE d.DAT_CREAT IS NOT NULL
GROUP BY d.DAT_CREAT
ORDER BY d.DAT_CREAT DESC;

-- -----------------------------------------------------------------------------
-- ID_TVDB coverage across the TV model (series / seasons / episodes)
-- One row per table: total rows, how many carry an ID_TVDB, how many are still
-- missing one, and the fill rate. ID_TVDB is indexed on all three tables, so the
-- WITH_TVDB count is served from the index. Backlog ref: TMDB-CRAWLER-005.
-- Note: a NULL ID_TVDB usually means TMDb has no tvdb_id for that entity, not a
-- crawler miss — read the fill rate as an upper bound on what is fetchable.
-- -----------------------------------------------------------------------------
SELECT 'SERIE' AS ENTITY,
       COUNT(*)                                              AS TOTAL,
       COUNT(ID_TVDB)                                        AS WITH_TVDB,
       COUNT(*) - COUNT(ID_TVDB)                             AS MISSING_TVDB,
       ROUND(100 * COUNT(ID_TVDB) / NULLIF(COUNT(*), 0), 1)  AS PCT_TVDB
FROM T_WC_TMDB_SERIE
UNION ALL
SELECT 'SEASON',
       COUNT(*), COUNT(ID_TVDB), COUNT(*) - COUNT(ID_TVDB),
       ROUND(100 * COUNT(ID_TVDB) / NULLIF(COUNT(*), 0), 1)
FROM T_WC_TMDB_SEASON
UNION ALL
SELECT 'EPISODE',
       COUNT(*), COUNT(ID_TVDB), COUNT(*) - COUNT(ID_TVDB),
       ROUND(100 * COUNT(ID_TVDB) / NULLIF(COUNT(*), 0), 1)
FROM T_WC_TMDB_EPISODE;

-- -----------------------------------------------------------------------------
-- TMDB-CRAWLER-022 / -023 — grounded neighbour coverage (TMDb similar / recommendations),
-- movies and TV series. Reads: how many distinct source entities carry at least one
-- stored neighbour, and the total neighbour rows, per set. Zero rows for an entity
-- usually means TMDb returned no neighbours (a new / obscure title), not a crawler
-- miss. Indexed on ID_MOVIE / ID_SERIE, so all scans stay cheap.
-- -----------------------------------------------------------------------------
SELECT 'MOVIE_SIMILAR'          AS SET_NAME,
       COUNT(DISTINCT ID_MOVIE) AS SOURCE_ENTITIES,
       COUNT(*)                 AS NEIGHBOUR_ROWS
FROM T_WC_TMDB_MOVIE_SIMILAR
UNION ALL
SELECT 'MOVIE_RECOMMENDATION', COUNT(DISTINCT ID_MOVIE), COUNT(*)
FROM T_WC_TMDB_MOVIE_RECOMMENDATION
UNION ALL
SELECT 'SERIE_SIMILAR', COUNT(DISTINCT ID_SERIE), COUNT(*)
FROM T_WC_TMDB_SERIE_SIMILAR
UNION ALL
SELECT 'SERIE_RECOMMENDATION', COUNT(DISTINCT ID_SERIE), COUNT(*)
FROM T_WC_TMDB_SERIE_RECOMMENDATION;

-- -----------------------------------------------------------------------------
-- TMDB-CRAWLER-024/025 — no localized (non-en/'') poster may sit at DISPLAY_ORDER 0.
-- Position 0 is reserved for the canonical en/'' poster. Three ways a localized poster
-- reaches 0, all now closed: (a) -024 kept per-language (*_LANG) mains off 0 by pinning
-- them to 1; (b) -025 additionally demotes a BASE poster that is itself localized — e.g.
-- a French film whose canonical POSTER_PATH is a French-tagged image — to 1, leaving 0
-- empty rather than nailing 'fr' there; (c) -026 fixed the missing-image backfill
-- (processes 67-69, movie/serie/collection *_LANG) which inserted every localized main
-- at a hardcoded DISPLAY_ORDER 0 — it now inserts localized backfills at 1. After the
-- fix + backfill, AT_0 should be 0 and stay 0; a non-zero AT_0 that reappears means a
-- localized poster was written to 0 — check all three writers: f_tmdbcontentimagesstosql
-- (full crawl), the 67-69 backfill in tmdb-crawler.py, and fix_main_image_display_order.py.
-- AT_1 is the healthy count that grows as entities get re-crawled. Cheap (indexed on
-- ID + DISPLAY_ORDER scan per entity).
-- -----------------------------------------------------------------------------
SELECT 'MOVIE' AS ENTITY,
       SUM(TYPE_IMAGE = 'poster' AND DISPLAY_ORDER = 0 AND LANG NOT IN ('en','')) AS LOCALIZED_POSTERS_AT_0,
       SUM(TYPE_IMAGE = 'poster' AND DISPLAY_ORDER = 1 AND LANG NOT IN ('en','')) AS LOCALIZED_POSTERS_AT_1
FROM T_WC_TMDB_MOVIE_IMAGE
UNION ALL
SELECT 'SERIE',
       SUM(TYPE_IMAGE = 'poster' AND DISPLAY_ORDER = 0 AND LANG NOT IN ('en','')),
       SUM(TYPE_IMAGE = 'poster' AND DISPLAY_ORDER = 1 AND LANG NOT IN ('en',''))
FROM T_WC_TMDB_SERIE_IMAGE;

-- -----------------------------------------------------------------------------
-- Seasons/episodes time budget — the runtime knob for the
-- f_tmdbserieselectiveseasonsepisodestosql calls in process 28 and changes-53.
-- The crawler resolves it once per run from this server variable, seeding it with
-- the in-code default (7200s) the first time the row does not exist. A NULL/empty
-- result means the crawler has not run since the feature was added (not a fault);
-- update VAR_VALUE to retune the budget without a redeploy — the next run picks it
-- up. Cheap (single indexed VAR_NAME lookup).
-- -----------------------------------------------------------------------------
SELECT VAR_NAME, VAR_VALUE, LONG_DESC, TIM_UPDATED
FROM T_WC_SERVER_VARIABLE
WHERE DELETED = 0
  AND VAR_NAME = 'strtmdbcrawlerseasonsepisodestimebudget';

-- -----------------------------------------------------------------------------
-- TMDB-CRAWLER-027 — TMDb ids that answer 34 ("resource could not be found").
-- Before the fix a dead id was re-probed on every run: process 32 rebuilt the same
-- orphan movie list indefinitely, the 30-day refresh processes brought the same
-- companies back, and each id cost a whole "everything" chain (10 API calls for a
-- movie, 3 of them printing an error). T_WC_TMDB_ID_NOT_FOUND now remembers them,
-- with a retry window that widens at each confirmation (base delay x attempts).
-- Read it as: ACTIVE = ids currently skipped, RETRYABLE = windows that expired and
-- will be probed again on the next run, RECORDED_LAST_7_DAYS = the fresh arrivals.
-- A sudden jump in the last column for one entity type is the signal worth acting
-- on: it means TMDb dropped a batch of ids (or answered 34 wrongly for a while),
-- not that the crawler misbehaved. Cheap (small table, indexed on ENTITY_TYPE).
-- -----------------------------------------------------------------------------
SELECT ENTITY_TYPE,
       COUNT(*)                                                        AS RECORDED,
       SUM(TIM_RETRY_AFTER > NOW())                                    AS ACTIVE,
       SUM(TIM_RETRY_AFTER <= NOW())                                   AS RETRYABLE,
       SUM(TIM_FIRST_SEEN >= DATE_SUB(NOW(), INTERVAL 7 DAY))          AS RECORDED_LAST_7_DAYS,
       MAX(ATTEMPT_COUNT)                                              AS MAX_ATTEMPTS,
       MIN(TIM_FIRST_SEEN)                                             AS FIRST_SEEN,
       MAX(TIM_LAST_SEEN)                                              AS LAST_SEEN
FROM T_WC_TMDB_ID_NOT_FOUND
GROUP BY ENTITY_TYPE
ORDER BY RECORDED DESC;

-- -----------------------------------------------------------------------------
-- TMDB-CRAWLER-027 — daily arrival rate of not-found ids, per entity type.
-- The steady state is a handful per day (TMDb merges and deletes continuously).
-- A spike on a single day, especially spread over several entity types at once,
-- points at an upstream incident rather than at real deletions: check that day's
-- crawler log before letting the widening retry windows hide those ids for months.
-- The two run counters (strtmdbcrawleridnotfound*count) give the same signal live.
-- -----------------------------------------------------------------------------
SELECT DATE(TIM_FIRST_SEEN) AS DAT_RECORDED,
       ENTITY_TYPE,
       COUNT(*)             AS IDS_RECORDED
FROM T_WC_TMDB_ID_NOT_FOUND
WHERE TIM_FIRST_SEEN >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY DATE(TIM_FIRST_SEEN), ENTITY_TYPE
ORDER BY DAT_RECORDED DESC, IDS_RECORDED DESC;

-- -----------------------------------------------------------------------------
-- TMDB-CRAWLER-020 / -030 — additive release-date and watch-provider coverage.
-- Completion timestamps count successful snapshots, including valid empty ones;
-- NULL means the endpoint has not completed successfully for that title yet.
-- The dedicated indexes keep these fill-rate counts cheap.
-- -----------------------------------------------------------------------------
SELECT 'MOVIE_RELEASE_DATES' AS DATASET,
       COUNT(*) AS SOURCE_TITLES,
       COUNT(TIM_RELEASE_DATES_COMPLETED) AS COMPLETED_TITLES,
       COUNT(*) - COUNT(TIM_RELEASE_DATES_COMPLETED) AS NOT_COMPLETED,
       ROUND(100 * COUNT(TIM_RELEASE_DATES_COMPLETED) / NULLIF(COUNT(*), 0), 1) AS PCT_COMPLETED,
       MIN(TIM_RELEASE_DATES_COMPLETED) AS OLDEST_SNAPSHOT,
       MAX(TIM_RELEASE_DATES_COMPLETED) AS NEWEST_SNAPSHOT
FROM T_WC_TMDB_MOVIE
WHERE DELETED = 0 AND TIM_CREDITS_COMPLETED IS NOT NULL
UNION ALL
SELECT 'MOVIE_WATCH_PROVIDERS', COUNT(*), COUNT(TIM_WATCH_PROVIDERS_COMPLETED),
       COUNT(*) - COUNT(TIM_WATCH_PROVIDERS_COMPLETED),
       ROUND(100 * COUNT(TIM_WATCH_PROVIDERS_COMPLETED) / NULLIF(COUNT(*), 0), 1),
       MIN(TIM_WATCH_PROVIDERS_COMPLETED), MAX(TIM_WATCH_PROVIDERS_COMPLETED)
FROM T_WC_TMDB_MOVIE
WHERE DELETED = 0 AND TIM_CREDITS_COMPLETED IS NOT NULL
UNION ALL
SELECT 'SERIE_WATCH_PROVIDERS', COUNT(*), COUNT(TIM_WATCH_PROVIDERS_COMPLETED),
       COUNT(*) - COUNT(TIM_WATCH_PROVIDERS_COMPLETED),
       ROUND(100 * COUNT(TIM_WATCH_PROVIDERS_COMPLETED) / NULLIF(COUNT(*), 0), 1),
       MIN(TIM_WATCH_PROVIDERS_COMPLETED), MAX(TIM_WATCH_PROVIDERS_COMPLETED)
FROM T_WC_TMDB_SERIE
WHERE DELETED = 0 AND TIM_CREDITS_COMPLETED IS NOT NULL;

-- Release-date distribution. Types: 1 premiere, 2 limited theatrical,
-- 3 theatrical, 4 digital, 5 physical, 6 TV. Zero rows means TMDb returned no
-- release event, not necessarily that the movie backfill failed; check the
-- completion query above before diagnosing a crawler gap.
SELECT RELEASE_TYPE,
       COUNT(DISTINCT ID_MOVIE) AS MOVIES,
       COUNT(DISTINCT COUNTRY_CODE) AS COUNTRIES,
       COUNT(*) AS RELEASE_ROWS,
       MIN(TIM_RELEASE) AS EARLIEST_RELEASE,
       MAX(TIM_RELEASE) AS LATEST_RELEASE,
       MAX(TIM_UPDATED) AS NEWEST_SNAPSHOT
FROM T_WC_TMDB_MOVIE_RELEASE_DATE
GROUP BY RELEASE_TYPE
ORDER BY RELEASE_TYPE;

-- Watch-provider coverage and freshness by content family. The stored country
-- link is the attribution route; provider rows never represent cinema showtimes.
SELECT 'MOVIE' AS ENTITY,
       COUNT(DISTINCT ID_MOVIE) AS TITLES,
       COUNT(DISTINCT COUNTRY_CODE) AS COUNTRIES,
       COUNT(DISTINCT ID_PROVIDER) AS PROVIDERS,
       COUNT(*) AS PROVIDER_ROWS,
       MIN(TIM_PROVIDER_UPDATED) AS OLDEST_SNAPSHOT,
       MAX(TIM_PROVIDER_UPDATED) AS NEWEST_SNAPSHOT
FROM T_WC_TMDB_MOVIE_WATCH_PROVIDER
UNION ALL
SELECT 'SERIE', COUNT(DISTINCT ID_SERIE), COUNT(DISTINCT COUNTRY_CODE),
       COUNT(DISTINCT ID_PROVIDER), COUNT(*),
       MIN(TIM_PROVIDER_UPDATED), MAX(TIM_PROVIDER_UPDATED)
FROM T_WC_TMDB_SERIE_WATCH_PROVIDER;

-- Availability modes by content family. A missing mode can be a legitimate
-- upstream absence for the crawled catalogue, not a parser failure.
SELECT 'MOVIE' AS ENTITY, MONETIZATION_TYPE,
       COUNT(DISTINCT ID_MOVIE) AS TITLES, COUNT(*) AS PROVIDER_ROWS
FROM T_WC_TMDB_MOVIE_WATCH_PROVIDER
GROUP BY MONETIZATION_TYPE
UNION ALL
SELECT 'SERIE', MONETIZATION_TYPE, COUNT(DISTINCT ID_SERIE), COUNT(*)
FROM T_WC_TMDB_SERIE_WATCH_PROVIDER
GROUP BY MONETIZATION_TYPE
ORDER BY ENTITY, MONETIZATION_TYPE;

-- TMDB-CRAWLER-031: global provider catalogues. State counts are written in the
-- same transaction as their catalogue and regional-priority rows. A missing
-- state row means that catalogue has never completed successfully; zero is not
-- expected from these global endpoints and is rejected before replacement.
SELECT state.CONTENT_TYPE,
       state.PROVIDER_COUNT AS RECORDED_PROVIDERS,
       COUNT(DISTINCT catalog.ID_PROVIDER) AS ACTUAL_PROVIDERS,
       state.REGION_RELATION_COUNT AS RECORDED_REGION_RELATIONS,
       COUNT(DISTINCT region.ID_ROW) AS ACTUAL_REGION_RELATIONS,
       state.TIM_COMPLETED
FROM T_WC_TMDB_WATCH_PROVIDER_CATALOG_STATE state
LEFT JOIN T_WC_TMDB_WATCH_PROVIDER_CATALOG catalog
       ON catalog.CONTENT_TYPE = state.CONTENT_TYPE
LEFT JOIN T_WC_TMDB_WATCH_PROVIDER_REGION region
       ON region.CONTENT_TYPE = state.CONTENT_TYPE
GROUP BY state.CONTENT_TYPE, state.PROVIDER_COUNT, state.REGION_RELATION_COUNT,
         state.TIM_COMPLETED
ORDER BY state.CONTENT_TYPE;

-- One provider id is one identity. Different non-empty names or logos between
-- the movie and TV catalogues are source conflicts to inspect, not identities
-- to merge by label. Zero rows is healthy.
SELECT ID_PROVIDER,
       COUNT(DISTINCT NULLIF(PROVIDER_NAME, '')) AS NAME_VARIANTS,
       COUNT(DISTINCT NULLIF(LOGO_PATH, '')) AS LOGO_VARIANTS,
       GROUP_CONCAT(DISTINCT CONTENT_TYPE ORDER BY CONTENT_TYPE) AS CATALOGUES
FROM T_WC_TMDB_WATCH_PROVIDER_CATALOG
GROUP BY ID_PROVIDER
HAVING NAME_VARIANTS > 1 OR LOGO_VARIANTS > 1
ORDER BY ID_PROVIDER;

-- Every catalogue membership and work association should resolve to a provider
-- identity. A non-zero count means acquisition order or catalog coverage drift,
-- not that a provider should be invented from its label.
SELECT 'CATALOG' AS ASSOCIATION_TYPE, COUNT(*) AS ORPHAN_ROWS
FROM T_WC_TMDB_WATCH_PROVIDER_CATALOG association_row
LEFT JOIN T_WC_TMDB_WATCH_PROVIDER provider
       ON provider.ID_PROVIDER = association_row.ID_PROVIDER
WHERE provider.ID_PROVIDER IS NULL OR provider.DELETED = 1
UNION ALL
SELECT 'MOVIE', COUNT(*)
FROM T_WC_TMDB_MOVIE_WATCH_PROVIDER association_row
LEFT JOIN T_WC_TMDB_WATCH_PROVIDER provider
       ON provider.ID_PROVIDER = association_row.ID_PROVIDER
WHERE provider.ID_PROVIDER IS NULL OR provider.DELETED = 1
UNION ALL
SELECT 'SERIE', COUNT(*)
FROM T_WC_TMDB_SERIE_WATCH_PROVIDER association_row
LEFT JOIN T_WC_TMDB_WATCH_PROVIDER provider
       ON provider.ID_PROVIDER = association_row.ID_PROVIDER
WHERE provider.ID_PROVIDER IS NULL OR provider.DELETED = 1;
