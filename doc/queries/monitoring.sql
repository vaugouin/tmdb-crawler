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
