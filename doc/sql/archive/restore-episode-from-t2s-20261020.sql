-- Incident of 2026-10-20: the disk filled up, MariaDB crashed at 08:13 and
-- T_WC_TMDB_EPISODE came back with a corrupted index. The table was reloaded
-- from the full dump of 2026-10-16 05:17, so it misses every episode the
-- crawler inserted or refreshed after that dump.
--
-- T_WC_T2S_EPISODE is a copy of T_WC_TMDB_EPISODE made by tmdb-movie-preprocess
-- (process 26, incremental on TIM_UPDATED) and was not damaged. This file copies
-- back from it what is newer than the restored rows:
--   1. rows present on both sides: refreshed when the T2S row is newer;
--   2. rows present only in T2S: inserted, with the TIM_*_COMPLETED columns left
--      NULL so that the crawler fetches their credits, images, videos and
--      translations again (T2S does not carry those timestamps).
-- Episodes outside the T2S scope (series or season not in T2S), and episodes
-- updated after the last preprocess run, are not recovered here.
--
-- Run AFTER the reload of the dump and BEFORE any tmdb-movie-preprocess run:
-- its stale-delete removes from T2S every episode missing from the source
-- table, which would destroy the very rows this file reads.
--
-- Writes to T_WC_TMDB_EPISODE: way 2 (runsqlvaugouindb.sh), never the agent.

SELECT VAR_VALUE AS T2S_EPISODE_LAST_RUN
FROM T_WC_SERVER_VARIABLE
WHERE VAR_NAME = 'strtmdbmoviepreprocesst2sepisodelastrun';

SELECT COUNT(*) AS TMDB_EPISODE_ROWS_BEFORE, MAX(TIM_UPDATED) AS TMDB_MAX_TIM_UPDATED
FROM T_WC_TMDB_EPISODE;

SELECT COUNT(*) AS T2S_EPISODE_ROWS, MAX(TIM_UPDATED) AS T2S_MAX_TIM_UPDATED
FROM T_WC_T2S_EPISODE;

SELECT COUNT(*) AS TO_REFRESH
FROM T_WC_T2S_EPISODE t
INNER JOIN T_WC_TMDB_EPISODE e ON e.ID_EPISODE = t.ID_EPISODE
WHERE t.TIM_UPDATED >= '2026-10-15 00:00:00'
  AND (e.TIM_UPDATED IS NULL OR t.TIM_UPDATED > e.TIM_UPDATED);

SELECT COUNT(*) AS TO_INSERT
FROM T_WC_T2S_EPISODE t
LEFT JOIN T_WC_TMDB_EPISODE e ON e.ID_EPISODE = t.ID_EPISODE
WHERE e.ID_EPISODE IS NULL;

UPDATE T_WC_TMDB_EPISODE e
INNER JOIN T_WC_T2S_EPISODE t ON t.ID_EPISODE = e.ID_EPISODE
SET e.ID_SERIE = t.ID_SERIE,
    e.ID_SEASON = t.ID_SEASON,
    e.SEASON_NUMBER = t.SEASON_NUMBER,
    e.EPISODE_NUMBER = t.EPISODE_NUMBER,
    e.TITLE = t.EPISODE_TITLE,
    e.OVERVIEW = t.OVERVIEW,
    e.AIR_YEAR = t.AIR_YEAR,
    e.AIR_MONTH = t.AIR_MONTH,
    e.AIR_DAY = t.AIR_DAY,
    e.DAT_AIR = t.DAT_AIR,
    e.RUNTIME = t.RUNTIME,
    e.PRODUCTION_CODE = t.PRODUCTION_CODE,
    e.EPISODE_TYPE = t.EPISODE_TYPE,
    e.STILL_PATH = t.STILL_PATH,
    e.VOTE_AVERAGE = t.VOTE_AVERAGE,
    e.VOTE_COUNT = t.VOTE_COUNT,
    e.ID_IMDB = t.ID_IMDB,
    e.ID_WIKIDATA = t.ID_WIKIDATA,
    e.ID_TVDB = t.ID_TVDB,
    e.DELETED = t.DELETED,
    e.DISPLAY_ORDER = t.DISPLAY_ORDER,
    e.ID_CREATOR = t.ID_CREATOR,
    e.DAT_CREAT = t.DAT_CREAT,
    e.ID_OWNER = t.ID_OWNER,
    e.ID_USER_UPDATED = t.ID_USER_UPDATED,
    e.TIM_UPDATED = t.TIM_UPDATED
WHERE t.TIM_UPDATED >= '2026-10-15 00:00:00'
  AND (e.TIM_UPDATED IS NULL OR t.TIM_UPDATED > e.TIM_UPDATED);

INSERT INTO T_WC_TMDB_EPISODE (
    ID_EPISODE, ID_SERIE, ID_SEASON, SEASON_NUMBER, EPISODE_NUMBER,
    TITLE, OVERVIEW,
    AIR_YEAR, AIR_MONTH, AIR_DAY, DAT_AIR,
    RUNTIME, PRODUCTION_CODE, EPISODE_TYPE, STILL_PATH,
    VOTE_AVERAGE, VOTE_COUNT,
    ID_IMDB, ID_WIKIDATA, ID_TVDB,
    DELETED, DISPLAY_ORDER, ID_CREATOR, DAT_CREAT, ID_OWNER,
    TIM_UPDATED, ID_USER_UPDATED
)
SELECT
    t.ID_EPISODE, t.ID_SERIE, t.ID_SEASON, t.SEASON_NUMBER, t.EPISODE_NUMBER,
    t.EPISODE_TITLE, t.OVERVIEW,
    t.AIR_YEAR, t.AIR_MONTH, t.AIR_DAY, t.DAT_AIR,
    t.RUNTIME, t.PRODUCTION_CODE, t.EPISODE_TYPE, t.STILL_PATH,
    t.VOTE_AVERAGE, t.VOTE_COUNT,
    t.ID_IMDB, t.ID_WIKIDATA, t.ID_TVDB,
    t.DELETED, t.DISPLAY_ORDER, t.ID_CREATOR, t.DAT_CREAT, t.ID_OWNER,
    t.TIM_UPDATED, t.ID_USER_UPDATED
FROM T_WC_T2S_EPISODE t
LEFT JOIN T_WC_TMDB_EPISODE e ON e.ID_EPISODE = t.ID_EPISODE
WHERE e.ID_EPISODE IS NULL;

SELECT COUNT(*) AS TMDB_EPISODE_ROWS_AFTER, MAX(TIM_UPDATED) AS TMDB_MAX_TIM_UPDATED
FROM T_WC_TMDB_EPISODE;
