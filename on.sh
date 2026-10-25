#!/bin/bash
# Switch tmdb-crawler.sh back on: removes the flag file CRON_OFF that off.sh wrote.
cd "$(dirname "$(readlink -f "$0")")" || exit 1
# A launcher renamed by the old off.sh (<name>-off.sh, before 2026-10-25) is put back,
# or dropped when git has already restored the tracked one.
[ -f tmdb-crawler-off.sh ] && { [ -f tmdb-crawler.sh ] && rm -f tmdb-crawler-off.sh || mv tmdb-crawler-off.sh tmdb-crawler.sh; }
rm -f CRON_OFF && echo "tmdb-crawler: on (CRON_OFF removed)"
