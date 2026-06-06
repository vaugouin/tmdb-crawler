#!/bin/bash

# Run-once migration: pin each content's main image to DISPLAY_ORDER 0 and make
# sure it is never deleted, across all TMDb image tables.
#
# It reuses the crawler Docker image and simply overrides the command, so the
# regular crawler container/CMD is left untouched. Run it once from the project
# directory; it is idempotent and safe to re-run.

set -euo pipefail

# Run from the directory containing this script (which also holds the .env file).
cd "$(dirname "$0")"

# Build the (shared) crawler image if needed, then run the one-off migration.
docker build -t tmdb-crawler-python-app .
docker run -it --rm --network="host" --name tmdb-fix-main-image \
    --env-file .env \
    tmdb-crawler-python-app python ./fix_main_image_display_order.py
