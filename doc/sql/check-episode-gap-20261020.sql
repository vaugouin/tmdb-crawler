-- Incident of 2026-10-20, second step: size the TMDb API catch-up of the
-- episodes that restore-episode-from-t2s-20261020.sql could not recover.
-- The dump holds data up to 2026-10-16 07:17 (Paris), T2S up to its last run
-- of 2026-10-19 04:26. Two gaps remain:
--   A. seasons refreshed since the dump whose series is not in T2S;
--   B. seasons refreshed since the last T2S run (2026-10-19 04:20, with margin).
-- API calls are roughly one per season plus one per episode. Read-only.

SELECT 'A: since dump, series outside T2S' AS GAP,
       COUNT(DISTINCT s.ID_SERIE) AS SERIES, COUNT(*) AS SEASONS,
       (SELECT COUNT(*) FROM T_WC_TMDB_EPISODE e
         WHERE e.ID_SEASON IN (SELECT s2.ID_SEASON FROM T_WC_TMDB_SEASON s2
                                WHERE s2.TIM_UPDATED >= '2026-10-16 07:17:00'
                                  AND s2.ID_SERIE NOT IN (SELECT ID_SERIE FROM T_WC_T2S_SERIE))) AS EPISODES
FROM T_WC_TMDB_SEASON s
WHERE s.TIM_UPDATED >= '2026-10-16 07:17:00'
  AND s.ID_SERIE NOT IN (SELECT ID_SERIE FROM T_WC_T2S_SERIE)
UNION ALL
SELECT 'B: since last T2S run, all series',
       COUNT(DISTINCT s.ID_SERIE), COUNT(*),
       (SELECT COUNT(*) FROM T_WC_TMDB_EPISODE e
         WHERE e.ID_SEASON IN (SELECT s2.ID_SEASON FROM T_WC_TMDB_SEASON s2
                                WHERE s2.TIM_UPDATED >= '2026-10-19 04:20:00'))
FROM T_WC_TMDB_SEASON s
WHERE s.TIM_UPDATED >= '2026-10-19 04:20:00';

-- Series the changes loop visited since the dump, for comparison.
SELECT COUNT(*) AS SERIES_CHANGES_CHECKED_SINCE_DUMP,
       SUM(ID_SERIE NOT IN (SELECT ID_SERIE FROM T_WC_T2S_SERIE)) AS OUTSIDE_T2S,
       SUM(TIM_LAST_CHANGES_CHECK >= '2026-10-19 04:20:00') AS SINCE_LAST_T2S_RUN
FROM T_WC_TMDB_SERIE
WHERE TIM_LAST_CHANGES_CHECK >= '2026-10-16 07:17:00';

-- Activity per day, to see when the crawler last wrote seasons.
SELECT DATE(TIM_UPDATED) AS DAY_, COUNT(*) AS SEASONS_UPDATED
FROM T_WC_TMDB_SEASON
WHERE TIM_UPDATED >= '2026-10-16 00:00:00'
GROUP BY DATE(TIM_UPDATED)
ORDER BY DAY_;
