#!/bin/bash

# TMDB-CRAWLER-029, run-once purge: remove the neighbour rows TMDb stopped returning long
# ago, in the four similar / recommendations tables.
#
# Reuses the crawler Docker image and overrides the command, so the regular crawler
# container and CMD are left untouched, same pattern as fix-main-image.sh.
#
# DEFAULT IS A DRY RUN: it measures and prints, it deletes nothing. Read the report, then
# re-run with --apply.
#
# DEPLOY TMDB-CRAWLER-028 FIRST. The order matters, the delay does not: purge while the old
# code is still crawling and the next crawl restarts the accumulation from scratch. Once -028
# is deployed you can purge the same day. Worth checking the fix on one title first though:
# House of the Dragon (94997) had 392 neighbours, it should fall to about 20 on its own.
#
#   ./purge-stale-neighbours.sh                 # dry run, safe
#   ./purge-stale-neighbours.sh --apply         # actually delete
#   ./purge-stale-neighbours.sh --apply --table T_WC_TMDB_SERIE_SIMILAR   # one table only

set -euo pipefail

cd "$(dirname "$0")"

docker build -t tmdb-crawler-python-app .
docker run -it --rm --network="host" --name tmdb-purge-stale-neighbours \
    --env-file .env \
    tmdb-crawler-python-app python ./purge_stale_neighbours.py "$@"
