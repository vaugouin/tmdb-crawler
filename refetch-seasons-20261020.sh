#!/bin/bash

# Run-once catch-up of the episodes lost in the incident of 2026-10-20 (see
# refetch_seasons_20261020.py). Reuses the crawler image and overrides the
# command, like fix-main-image.sh. Resumable: re-run it after an interruption.

set -euo pipefail

cd "$(dirname "$0")"

docker build -t tmdb-crawler-python-app .
docker run -it --rm --network="host" --name tmdb-refetch-seasons \
    --env-file .env \
    tmdb-crawler-python-app python ./refetch_seasons_20261020.py
