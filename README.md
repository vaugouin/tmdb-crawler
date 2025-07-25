# TMDb Crawler

A Python-based data crawler for The Movie Database (TMDb) API that synchronizes movie, TV series, person, and other entertainment data with a MySQL database.

## Overview

The TMDb Crawler is designed to maintain an up-to-date local database of entertainment content by:

1. **Downloading daily ID exports** from TMDb containing lists of all movies, TV series, people, collections, keywords, networks, and production companies
2. **Processing API changes** to keep data synchronized with TMDb updates
3. **Refreshing existing records** to ensure data accuracy
4. **Managing missing records** by fetching data for referenced but missing entities

## Setup

### Database Setup
Before running the TMDb Crawler, you need to create the required database tables and server variables:

1. **Create TMDb Tables**: Execute the `TMDb-tables.sql` script in your MariaDB/MySQL database to create all necessary tables and indexes.
   ```sql
   mysql -u your_username -p your_database < TMDb-tables.sql
   ```

2. **Create Server Variables Table**: Execute the `T_WC_SERVER_VARIABLE.sql` script to set up the server variables table for tracking processing state.
   ```sql
   mysql -u your_username -p your_database < T_WC_SERVER_VARIABLE.sql
   ```

3. **Create Wikidata Tables**: Execute the `Wikidata-tables.sql` script to create tables for Wikidata integration.
   ```sql
   mysql -u your_username -p your_database < Wikidata-tables.sql
   ```

4. **Create Wikipedia Tables**: Execute the `Wikipedia-tables.sql` script to create tables for Wikipedia data integration.
   ```sql
   mysql -u your_username -p your_database < Wikipedia-tables.sql
   ```

### Configuration
The application requires database and API credentials to function:

1. **Copy Configuration Template**: Copy `citizenphilsecrets.example.py` to `citizenphilsecrets.py`
   ```bash
   cp citizenphilsecrets.example.py citizenphilsecrets.py
   ```

2. **Update Configuration**: Edit `citizenphilsecrets.py` with your actual values:
   - **MariaDB/MySQL Connection**: Update database host, username, password, and database name
   - **TMDb API Key**: Add your TMDb API key (obtain from https://www.themoviedb.org/settings/api)

   **Important**: Never commit `citizenphilsecrets.py` to version control as it contains sensitive credentials.

## Features

### Data Import & Synchronization
- **Daily ID File Processing**: Downloads and imports compressed JSON files containing TMDb entity IDs
- **Change Detection**: Monitors TMDb API changes for movies, TV series, and people
- **Incremental Updates**: Only processes new or modified records to optimize performance
- **Missing Data Recovery**: Automatically fetches missing movies, series, and people referenced in existing data

### Database Operations
- **Fast Bulk Import**: Uses MySQL's `LOAD DATA INFILE` for efficient data loading
- **Fallback Processing**: Alternative row-by-row processing when bulk import is unavailable
- **Transaction Management**: Ensures data integrity with proper transaction handling
- **Progress Tracking**: Maintains server variables to track processing status and counts

### Content Types Supported
- **Movies**: Complete movie data including metadata, credits, keywords, and images
- **TV Series**: Series information with episode data, credits, and keywords
- **People**: Person profiles with filmography and images
- **Collections**: Movie collections and series groupings
- **Keywords**: Content tagging and categorization
- **Networks**: TV networks and streaming platforms
- **Production Companies**: Studio and production company information

## Architecture

### Process Flow
1. **Initialization**: Sets up database connections and retrieves last processing dates
2. **ID File Download**: Downloads daily export files from TMDb if newer data is available
3. **Bulk Import**: Imports ID files into temporary MySQL tables
4. **Targeted Processing**: Executes specific processes based on configuration:
   - New content discovery
   - Data refresh for outdated records
   - Missing entity recovery
   - Keyword and credit completion
5. **Change Processing**: Handles real-time changes from TMDb API
6. **Cleanup**: Updates processing timestamps and status variables

### Database Schema
The crawler works with multiple MySQL tables including:
- `T_WC_TMDB_MOVIE` - Movie records
- `T_WC_TMDB_SERIE` - TV series records  
- `T_WC_TMDB_PERSON` - People records
- `T_WC_TMDB_*_ID_IMPORT` - Temporary import tables
- Various junction tables for relationships (credits, keywords, etc.)

## Configuration

### Process Types
The crawler supports 30+ different process types (indexed 1-33+), including:
- **1-10**: Core content processing (movies, series, people)
- **11-20**: Data refresh operations
- **21-30**: Missing data recovery
- **31-33**: Specialized processing for credits and keywords
- **51-53**: Change processing for movies, people, and series

### Environment Variables
The script relies on the `citizenphil` module for:
- Database connection management
- TMDb API credentials and headers
- Server variable storage and retrieval
- Timezone handling (Paris timezone)

## Dependencies

- **pymysql**: MySQL database connectivity
- **requests**: HTTP API communication
- **numpy**: Data processing utilities
- **pytz**: Timezone management
- **citizenphil**: Custom module for database and API management

## Usage

### Docker Deployment
The crawler is designed to run in a Docker container:

```bash
# Build the container
docker build -t tmdb-crawler-python-app .

# Run the container
docker run -d --rm --network="host" --name tmdb-crawler \
  -v $HOME/docker/shared_data:/shared tmdb-crawler-python-app
```

### Shell Script
Use the provided `tmdb-crawler.sh` script to manage the Docker container:

```bash
./tmdb-crawler.sh
```

The script will:
- Check if the container is already running
- Create necessary directories (`$HOME/docker/shared_data`)
- Build and start the container if needed

## Data Flow

### Daily Processing
1. **Morning Sync**: Downloads previous day's ID exports from TMDb
2. **Bulk Import**: Loads new IDs into MySQL staging tables
3. **Content Processing**: Fetches detailed data for new entities
4. **Relationship Building**: Establishes connections between movies, people, and other entities

### Real-time Updates
1. **Change Monitoring**: Polls TMDb changes API for recent modifications
2. **Selective Updates**: Only processes entities that have been modified
3. **Incremental Sync**: Maintains data freshness without full re-processing

## Performance Features

- **Optimized Queries**: Uses efficient SQL queries with proper indexing
- **Batch Processing**: Groups API calls and database operations
- **Rate Limiting**: Respects TMDb API rate limits
- **Memory Management**: Processes large datasets in manageable chunks
- **Progress Tracking**: Provides visibility into long-running operations

## Monitoring

The crawler maintains several server variables for monitoring:
- Processing timestamps and durations
- Record counts for each process type
- Current operation status
- Error tracking and recovery status

## Error Handling

- **Database Rollback**: Automatic transaction rollback on MySQL errors
- **API Retry Logic**: Handles temporary API failures gracefully
- **Data Validation**: Ensures data integrity before database commits
- **Logging**: Comprehensive logging for debugging and monitoring

## File Structure

```
tmdb-crawler/
├── tmdb-crawler.py                    # Main crawler script - core application logic
├── tmdb-crawler.sh                    # Docker management script for container lifecycle
├── citizenphil.py                     # Custom module for database and API management
├── citizenphilsecrets.py              # Configuration file with credentials (not in git)
├── citizenphilsecrets.example.py      # Template for configuration file
├── Dockerfile                         # Container configuration for Docker deployment
├── requirements.txt                   # Python dependencies specification
├── TMDb-tables.sql                    # Database schema creation script
├── T_WC_SERVER_VARIABLE.sql           # Server variables table setup script
├── Wikidata-tables.sql                # Wikidata integration tables creation script
├── Wikipedia-tables.sql               # Wikipedia data tables creation script
├── .gitignore                         # Git ignore rules for sensitive files
└── README.md                          # This documentation
```

### Key Files Description

- **`tmdb-crawler.py`** - The main application containing all crawler logic, API interactions, and database operations
- **`citizenphil.py`** - Core utility module providing database connectivity, API management, and common functions
- **`citizenphilsecrets.py`** - Configuration file containing database credentials and API keys (excluded from version control)
- **`TMDb-tables.sql`** - SQL script to create all required database tables and indexes for the TMDb data
- **`T_WC_SERVER_VARIABLE.sql`** - SQL script to set up server variables table for tracking processing state
- **`Wikidata-tables.sql`** - SQL script to create database tables for Wikidata integration and cross-referencing
- **`Wikipedia-tables.sql`** - SQL script to create database tables for Wikipedia data integration
- **`tmdb-crawler.sh`** - Shell script for easy Docker container management and deployment

## Notes

- The crawler is timezone-aware and uses Paris timezone for all timestamps
- Processing can be configured to run specific subsets of operations
- The system maintains backward compatibility with existing database schemas
- All file operations use the `/shared` volume for Docker container persistence
