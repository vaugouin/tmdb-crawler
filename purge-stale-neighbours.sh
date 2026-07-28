#!/bin/bash

# TMDB-CRAWLER-029, run-once purge: remove the neighbour rows TMDb stopped returning long
# ago, in the four similar / recommendations tables.
#
# Reuses the crawler Docker image and overrides the command, so the regular crawler
# container and CMD are left untouched, same pattern as fix-main-image.sh.
#
# DEFAULT IS A DRY RUN: it measures and prints, it deletes nothing. Read the report, then
# re-run with --apply. Run TMDB-CRAWLER-028 first and let it crawl for a few days, otherwise
# the accumulation restarts at the next crawl and this purge has to be repeated for ever.
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
