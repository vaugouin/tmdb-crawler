"""
Run-once catch-up after the incident of 2026-10-20 (disk full, corrupted
T_WC_TMDB_EPISODE reloaded from the dump of 2026-10-16 07:17, then completed
from T_WC_T2S_EPISODE up to the T2S run of 2026-10-19 04:26).

Re-fetches from TMDb every season whose episodes neither source could restore,
sized by doc/sql/check-episode-gap-20261020.sql:
  A. seasons refreshed since the dump whose series is not in T2S;
  B. seasons refreshed since the last T2S run.
One call per season: f_tmdbseasontosql() rewrites the episode rows (basic data,
crew, guest stars) from the embedded episodes[]. Per-episode endpoints are left
to the regular crawler.

Idempotent and resumable: a season is skipped once its TIM_UPDATED is later
than the start of the first run (server variable strtmdbrefetchseasons20261020start).

    ./refetch-seasons-20261020.sh
"""

from datetime import datetime

import citizenphil as cp
import tmdb_functions as tf

STR_DUMP_TIME = "2026-10-16 07:17:00"
STR_T2S_LAST_RUN = "2026-10-19 04:20:00"
STR_START_VAR = "strtmdbrefetchseasons20261020start"


def main():
    strstart = cp.f_getservervariable(STR_START_VAR, 0)
    if not strstart:
        strstart = datetime.now(cp.paris_tz).strftime("%Y-%m-%d %H:%M:%S")
        cp.f_setservervariable(STR_START_VAR, strstart, "Start of the season catch-up of the 2026-10-20 incident", 0)
    print(f"Catch-up start: {strstart}")

    connection = cp.f_getconnection()
    cursor = connection.cursor()
    strsql = """
SELECT s.ID_SERIE, s.SEASON_NUMBER
FROM T_WC_TMDB_SEASON s
WHERE s.SEASON_NUMBER IS NOT NULL
  AND s.TIM_UPDATED < %s
  AND ( (s.TIM_UPDATED >= %s AND s.ID_SERIE NOT IN (SELECT ID_SERIE FROM T_WC_T2S_SERIE))
     OR s.TIM_UPDATED >= %s )
ORDER BY s.ID_SERIE, s.SEASON_NUMBER """
    cursor.execute(strsql, (strstart, STR_DUMP_TIME, STR_T2S_LAST_RUN))
    arrseasons = cursor.fetchall()
    lngtotal = len(arrseasons)
    print(f"Seasons to re-fetch: {lngtotal}")

    lngok = 0
    lngfailed = 0
    for intindex, row in enumerate(arrseasons, start=1):
        lngseasonid = tf.f_tmdbseasontosql(row["ID_SERIE"], row["SEASON_NUMBER"])
        if lngseasonid > 0:
            lngok += 1
        else:
            lngfailed += 1
            print(f"Failed: serie {row['ID_SERIE']} season {row['SEASON_NUMBER']}")
        if intindex % 100 == 0 or intindex == lngtotal:
            print(f"{intindex}/{lngtotal} seasons, {lngok} ok, {lngfailed} failed")

    print("\n=== Catch-up complete ===")
    print(f"  Seasons re-fetched : {lngok}")
    print(f"  Seasons failed     : {lngfailed}")


if __name__ == "__main__":
    main()
