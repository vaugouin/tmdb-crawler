# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TMDb Crawler is a Python application that synchronizes entertainment data (movies, TV series, people, collections, keywords, networks, companies) from The Movie Database (TMDb) API to a MySQL/MariaDB database. It runs in Docker and is designed for daily automated data synchronization.

## Commands

### Running the Crawler

```bash
# Docker deployment (production)
./tmdb-crawler.sh

# Manual Docker build and run
docker build -t tmdb-crawler-python-app .
docker run -d --rm --network="host" --name tmdb-crawler \
  -v $HOME/docker/shared_data:/shared tmdb-crawler-python-app

# Run locally (requires citizenphilsecrets.py configured)
python tmdb-crawler.py
```

### Database Setup

```bash
# Create required tables (run in order)
mysql -u user -p database < TMDb-tables.sql
mysql -u user -p database < T_WC_SERVER_VARIABLE.sql
mysql -u user -p database < Wikidata-tables.sql
mysql -u user -p database < Wikipedia-tables.sql
mysql -u user -p database < Text2SQL-tables.sql
```

### Configuration

Copy `citizenphilsecrets.example.py` to `citizenphilsecrets.py` and configure:
- MariaDB/MySQL connection (host, port, user, password, database name)
- TMDb API key and token (get from https://www.themoviedb.org/settings/api)

## Architecture

### Core Files

- **`tmdb-crawler.py`** - Main crawler script with 4 processing loops:
  1. **Loop #1 (processes 41-47)**: Downloads daily TMDb ID export files and bulk imports them into `T_WC_TMDB_*_ID_IMPORT` tables
  2. **Loop #2 (processes 1-33)**: Processes new/refreshed/deleted content (movies, series, persons, collections, companies, networks, keywords)
  3. **Loop #3 (processes 51-53)**: Processes TMDb changes API for movies, persons, and series
  4. **Loop #4 (processes 61-69)**: Handles missing images for all content types

- **`tmdb_functions.py`** - TMDb API wrapper module providing:
  - All TMDb API functions (`f_tmdb*tosql()`, `f_tmdb*tosqleverything()`)
  - Content-specific functions for movies, series, persons, collections, companies, networks, keywords, lists
  - Image and video fetching functions
  - Content existence checking and deletion functions

- **`citizenphil.py`** - Core utility module providing:
  - Database connection management (`connectioncp`)
  - SQL helper function `f_sqlupdatearray()` for upsert operations
  - Server variable management (`f_getservervariable()`, `f_setservervariable()`)
  - API headers configuration (`headers`)
  - Utility functions (`convert_seconds_to_duration()`, `f_stringtosql()`)

### Key Functions in tmdb_functions.py

| Function | Purpose |
|----------|---------|
| `f_tmdbmovietosqleverything(id)` | Fetch and store complete movie data with credits, images, videos |
| `f_tmdbpersontosqleverything(id)` | Fetch and store complete person data with filmography |
| `f_tmdbserietosqleverything(id)` | Fetch and store complete TV series data |
| `f_tmdbcollectiontosqleverything(id)` | Fetch and store collection data |
| `f_tmdbcompanytosqleverything(id)` | Fetch and store company data |
| `f_tmdbnetworktosqleverything(id)` | Fetch and store network data |
| `f_tmdbkeywordtosqleverything(id, name)` | Fetch and store keyword data |
| `f_tmdblisttosqleverything(id)` | Fetch and store list data with movies |
| `f_tmdbcontentimagesstosql()` | Generic image fetching for any content type |
| `f_tmdbcontentvideosstosql()` | Generic video fetching for any content type |
| `f_tmdb*exist(id)` | Check if content exists in TMDb API |
| `f_tmdb*delete(id)` | Soft delete content from database |

### Key Functions in citizenphil.py

| Function | Purpose |
|----------|---------|
| `f_sqlupdatearray(table, data, condition, add_std_fields)` | Insert or update record based on existence |
| `f_getservervariable(name, lang)` | Retrieve server variable value |
| `f_setservervariable(name, value, desc, lang)` | Set server variable value |
| `convert_seconds_to_duration(seconds)` | Convert seconds to human-readable duration |
| `f_stringtosql(text)` | Escape string for SQL queries |

### Database Schema Pattern

All tables use `T_WC_TMDB_` prefix with standard fields:
- `DELETED` - Soft delete flag
- `DAT_CREAT` - Creation date
- `TIM_UPDATED` - Last update timestamp
- `TIM_CREDITS_COMPLETED` - Timestamp when credits were fully fetched

Main tables: `T_WC_TMDB_MOVIE`, `T_WC_TMDB_SERIE`, `T_WC_TMDB_PERSON`, `T_WC_TMDB_COLLECTION`, `T_WC_TMDB_COMPANY`, `T_WC_TMDB_NETWORK`

Junction tables: `T_WC_TMDB_PERSON_MOVIE`, `T_WC_TMDB_PERSON_SERIE`, `T_WC_TMDB_MOVIE_KEYWORD`, etc.

Image tables: `T_WC_TMDB_*_IMAGE` for each content type

### Process Indices Reference

| Index | Description |
|-------|-------------|
| 1-4 | New collections, movies, persons, series |
| 12-18 | New keywords, lists, deleted content, companies, networks |
| 22-28 | Refreshing movies, series, persons, collections, companies, networks |
| 31-33 | Missing persons, movies, series (from credits) |
| 41-47 | ID file imports (movie, person, collection, tv_series, keyword, network, company) |
| 51-53 | Changes API processing (movie, person, serie) |
| 61-69 | Missing images processing |

### Naming Conventions

- Variables use Hungarian notation: `str` (string), `lng` (long/int), `dbl` (double/float), `int` (boolean flag), `arr` (array/dict), `boo` (boolean)
- SQL table names: `T_WC_TMDB_*` (T_WC_ is the namespace prefix from `strsqlns`)
- API functions: `f_tmdb*` prefix
- Server variables: `strtmdbcrawler*` prefix

### Timezone

All timestamps use Paris timezone (`Europe/Paris`), configured in `citizenphilsecrets.py`.
