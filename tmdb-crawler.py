import time
import requests
import pymysql.cursors
import json
import citizenphil as cp
import tmdb_functions as tf
from datetime import datetime, timedelta
import gzip
import shutil
import os

datnow = datetime.now(cp.paris_tz)
# Compute the date and time for J-1 (yesterday)
# So we are sure to find the TMDb Id export files for this day
delta = timedelta(days=1)
datjminus1 = datnow - delta
#strdatjminus1 = datjminus1.strftime("%Y-%m-%d %H:%M:%S")
strdattodayminus1 = datjminus1.strftime("%Y-%m-%d")
strdattodayminus1us = datjminus1.strftime("%m_%d_%Y")
strtmdbdatprev = cp.f_getservervariable("strtmdbcrawlertmdbidimportdate",0)
strimdbdatprev = cp.f_getservervariable("strtmdbcrawlerimdbidimportdate",0)
print(f"strtmdbdatprev={strtmdbdatprev}")
print(f"strimdbdatprev={strimdbdatprev}")

try:
    conn = cp.f_getconnection()
    with conn:
        with conn.cursor() as cursor:
            cursor3 = conn.cursor()
            # Start timing the script execution
            start_time = time.time()
            strnow = datetime.now(cp.paris_tz).strftime("%Y-%m-%d %H:%M:%S")
            cp.f_setservervariable("strtmdbcrawlerstartdatetime",strnow,"Date and time of the last start of the TMDb API crawler",0)
            strprocessesexecutedprevious = cp.f_getservervariable("strtmdbcrawlerprocessesexecuted",0)
            strprocessesexecuteddesc = "List of processes executed in the TMDb API crawler"
            cp.f_setservervariable("strtmdbcrawlerprocessesexecutedprevious",strprocessesexecutedprevious,strprocessesexecuteddesc + " (previous execution)",0)
            strprocessesexecuted = ""
            cp.f_setservervariable("strtmdbcrawlerprocessesexecuted",strprocessesexecuted,strprocessesexecuteddesc,0)
            strtotalruntimedesc = "Total runtime of the TMDb crawler"
            strtotalruntimeprevious = cp.f_getservervariable("strtmdbcrawlertotalruntime",0)
            cp.f_setservervariable("strtmdbcrawlertotalruntimeprevious",strtotalruntimeprevious,strtotalruntimedesc + " (previous execution)",0)
            strtotalruntime = "RUNNING"
            cp.f_setservervariable("strtmdbcrawlertotalruntime",strtotalruntime,strtotalruntimedesc,0)
            # Which id files should we process from the TMDb HTTP server? 
            arrtmdbidfilename = {41: 'movie', 42:'person', 43:'collection', 44:'tv_series', 45: 'keyword', 46: 'tv_network', 47: 'production_company'}
            #arrtmdbidfilename = {45: 'keyword'}
            #arrtmdbidfilename = {41: 'movie'}
            intdownloadok = True
            if strdattodayminus1 > strtmdbdatprev:
                # This is a newer date, so we must import the TMDb ID files and import them in the MySQL database
                # So if this script is ran several times a day, we will only import the TMDb ID files once
                print("This is a newer date, so we must download the TMDb ID files and import them in the MySQL database")
                inttruncate = False
                intloaddatainfile = False
                # First download the id file from the TMDb HTTP server and import them in the MySQL database
                # (Loop #1)
                for inttmdbidfilename,strtmdbidfilename in arrtmdbidfilename.items():
                    strlocalgzfilename = '/shared/' + strtmdbidfilename + '.json.gz'
                    strlocaljsonfilename = '/shared/' + strtmdbidfilename + '.json'
                    if inttmdbidfilename == 41:
                        strtmdbidsqltable = "T_WC_TMDB_MOVIE_ID_IMPORT"
                        inttruncate = True
                        intloaddatainfile = True
                        strsqlload = f"""LOAD DATA INFILE '{strlocaljsonfilename}' 
INTO TABLE {strtmdbidsqltable} 
FIELDS TERMINATED BY '\t' 
LINES TERMINATED BY '\n' 
(@json_row)
SET 
adult = JSON_VALUE(@json_row, '$.adult'),
id = JSON_VALUE(@json_row, '$.id'),
original_title = JSON_VALUE(@json_row, '$.original_title'),
popularity = JSON_VALUE(@json_row, '$.popularity'),
video = JSON_VALUE(@json_row, '$.video'); """
                    elif inttmdbidfilename == 42:
                        strtmdbidsqltable = "T_WC_TMDB_PERSON_ID_IMPORT"
                        inttruncate = True
                        intloaddatainfile = True
                        strsqlload = f"""LOAD DATA INFILE '{strlocaljsonfilename}' 
INTO TABLE {strtmdbidsqltable} 
FIELDS TERMINATED BY '\t' 
LINES TERMINATED BY '\n' 
(@json_row)
SET 
adult = JSON_VALUE(@json_row, '$.adult'),
id = JSON_VALUE(@json_row, '$.id'),
name = JSON_VALUE(@json_row, '$.name'),
popularity = JSON_VALUE(@json_row, '$.popularity'); """
                    elif inttmdbidfilename == 43:
                        strtmdbidsqltable = "T_WC_TMDB_COLLECTION_ID_IMPORT"
                        inttruncate = True
                        intloaddatainfile = True
                        strsqlload = f"""LOAD DATA INFILE '{strlocaljsonfilename}' 
INTO TABLE {strtmdbidsqltable} 
FIELDS TERMINATED BY '\t' 
LINES TERMINATED BY '\n' 
(@json_row)
SET 
id = JSON_VALUE(@json_row, '$.id'),
name = JSON_VALUE(@json_row, '$.name'); """
                    elif inttmdbidfilename == 44:
                        strtmdbidsqltable = "T_WC_TMDB_TV_SERIE_ID_IMPORT"
                        inttruncate = True
                        intloaddatainfile = True
                        strsqlload = f"""LOAD DATA INFILE '{strlocaljsonfilename}' 
INTO TABLE {strtmdbidsqltable} 
FIELDS TERMINATED BY '\t' 
LINES TERMINATED BY '\n' 
(@json_row)
SET 
id = JSON_VALUE(@json_row, '$.id'),
original_name = JSON_VALUE(@json_row, '$.original_name'),
popularity = JSON_VALUE(@json_row, '$.popularity'); """
                    elif inttmdbidfilename == 45:
                        strtmdbidsqltable = "T_WC_TMDB_KEYWORD_ID_IMPORT"
                        intloaddatainfile = True
                        strsqlload = f"""LOAD DATA INFILE '{strlocaljsonfilename}' 
INTO TABLE {strtmdbidsqltable} 
FIELDS TERMINATED BY '\t' 
LINES TERMINATED BY '\n' 
(@json_row)
SET 
id = JSON_VALUE(@json_row, '$.id'),
name = JSON_VALUE(@json_row, '$.name'); """
                    elif inttmdbidfilename == 46:
                        strtmdbidsqltable = "T_WC_TMDB_TV_NETWORK_ID_IMPORT"
                        inttruncate = True
                        intloaddatainfile = True
                        strsqlload = f"""LOAD DATA INFILE '{strlocaljsonfilename}' 
INTO TABLE {strtmdbidsqltable} 
FIELDS TERMINATED BY '\t' 
LINES TERMINATED BY '\n' 
(@json_row)
SET 
id = JSON_VALUE(@json_row, '$.id'),
name = JSON_VALUE(@json_row, '$.name'); """
                    elif inttmdbidfilename == 47:
                        strtmdbidsqltable = "T_WC_TMDB_PRODUCTION_COMPANY_ID_IMPORT"
                        inttruncate = True
                        intloaddatainfile = True
                        strsqlload = f"""LOAD DATA INFILE '{strlocaljsonfilename}' 
INTO TABLE {strtmdbidsqltable} 
FIELDS TERMINATED BY '\t' 
LINES TERMINATED BY '\n' 
(@json_row)
SET 
id = JSON_VALUE(@json_row, '$.id'),
name = JSON_VALUE(@json_row, '$.name'); """
                    else:
                        strtmdbidsqltable = ""
                    if strtmdbidsqltable != "":
                        print(f"{inttmdbidfilename}: {strtmdbidfilename} -> {strtmdbidsqltable}")
                        lngcount = 0
                        strprocessesexecuted += str(inttmdbidfilename) + ", "
                        cp.f_setservervariable("strtmdbcrawlerprocessesexecuted",strprocessesexecuted,strprocessesexecuteddesc,0)
                        strnow = datetime.now(cp.paris_tz).strftime("%Y-%m-%d %H:%M:%S")
                        cp.f_setservervariable("strtmdbcrawlertmdbid"+strtmdbidfilename+"importdate",strnow,"Date and time of the last download of the TMDb "+strtmdbidfilename+" ID import file",0)
                        cp.f_setservervariable("strtmdbcrawlertmdbid"+strtmdbidfilename+"startdate",strnow,"Date and time of the download start of the TMDb "+strtmdbidfilename+" ID import file",0)
                        strtmdbidfileurl = f"https://files.tmdb.org/p/exports/{strtmdbidfilename}_ids_{strdattodayminus1us}.json.gz"
                        print(f"Download from {strtmdbidfileurl} to {strlocalgzfilename}")
                        response = requests.get(strtmdbidfileurl, stream=True)
                        if response.status_code == 200:
                            print(f"Extract {strlocalgzfilename} to {strlocaljsonfilename}")
                            with open(strlocalgzfilename, 'wb') as file:
                                for chunk in response.iter_content(chunk_size=8192):
                                    file.write(chunk)
                            with gzip.open(strlocalgzfilename, 'rb') as f_in:
                                with open(strlocaljsonfilename, 'wb') as f_out:
                                    shutil.copyfileobj(f_in, f_out)
                            print(f"Import {strlocaljsonfilename} to {strtmdbidsqltable}")
                            if intloaddatainfile:
                                strsqlbefore = f"""SET autocommit = 0; 
SET unique_checks = 0; 
SET foreign_key_checks = 0; 
ALTER TABLE {strtmdbidsqltable} DISABLE KEYS; 
TRUNCATE TABLE {strtmdbidsqltable}; """
                                strsqlafter = f"""ALTER TABLE {strtmdbidsqltable} ENABLE KEYS; 
SET foreign_key_checks = 1; 
SET unique_checks = 1; 
COMMIT; 
SET autocommit = 1; """
                                # Step 1: Execute pre-import SQL
                                for statement in strsqlbefore.strip().split(';'):
                                    if statement.strip():
                                        cursor.execute(statement)
                                # Step 2: Execute LOAD DATA
                                cursor.execute(strsqlload)
                                # Step 3: Execute post-import SQL
                                for statement in strsqlafter.strip().split(';'):
                                    if statement.strip():
                                        cursor.execute(statement)
                            else:
                                # Slow process without the LOAD DATA INFILE instruction
                                with open(strlocaljsonfilename, 'r') as file:
                                    if inttruncate:
                                        strsqltruncate = f"TRUNCATE TABLE {strtmdbidsqltable} "
                                        print(strsqltruncate)
                                        cursor.execute(strsqltruncate)
                                    for line in file:
                                        # Parse each line (which is a JSON record) into a Python dictionary
                                        record = json.loads(line)
                                        print(record)
                                        lngid = record.get("id")
                                        if inttruncate:
                                            intinsert = True
                                        else:
                                            intinsert = False
                                            strsqlexists = f"SELECT id FROM {strtmdbidsqltable} WHERE id = {lngid}"
                                            # print(strsqlexists)
                                            cursor.execute(strsqlexists)
                                            lngrowcount = cursor.rowcount
                                            if lngrowcount == 0:
                                                intinsert = True
                                        if intinsert:
                                            # This id is not loaded yet 
                                            # Assuming your table columns match the dictionary keys
                                            columns = ', '.join(record.keys())
                                            placeholders = ', '.join(['%s'] * len(record))
                                            strsql = f"INSERT INTO {strtmdbidsqltable} ({columns}) VALUES ({placeholders})"
                                            try:
                                                cursor.execute(strsql, list(record.values()))
                                                lngcount += 1
                                                if lngcount % 100 == 0:
                                                    conn.commit()
                                                    cp.f_setservervariable("strtmdbcrawlertmdbid"+strtmdbidfilename+"count",str(lngcount),"Record count of the TMDb "+strtmdbidfilename+" ID import file",0)
                                            except pymysql.MySQLError as e:
                                                print(f"❌ MySQL Error: {e}")
                                                if getattr(conn, "open", False):
                                                    conn.rollback()
                                    conn.commit()
                                    cp.f_setservervariable("strtmdbcrawlertmdbid"+strtmdbidfilename+"count",str(lngcount),"Record count of the TMDb "+strtmdbidfilename+" ID import file",0)
                            print(f"Import {strlocaljsonfilename} to {strtmdbidsqltable} done!")
                            # File is read in the database so we delete it: .json.gz and .json file
                            print(f"Remove {strlocalgzfilename}")
                            os.remove(strlocalgzfilename)
                            print(f"Remove {strlocaljsonfilename}")
                            os.remove(strlocaljsonfilename)
                        else:
                            # Failed to download one file
                            print("Failed to download the file.")
                            intdownloadok = False
            if intdownloadok:
                # All files were downloaded so we save the date and time of the last completed download of TMDb id import files
                cp.f_setservervariable("strtmdbcrawlertmdbidimportdate",strdattodayminus1,"Date of the last download of the TMDb ID import files",0)
            intdownloadok = False
            def f_getprocesssql(intindex):
                datnow = datetime.now(cp.paris_tz)
                strcurrentprocess = ""
                strsql = ""
                if intindex == 1:
                    strcurrentprocess = f"{intindex}: processing new collections from TMDb ID files"
                    strsql += "SELECT id FROM T_WC_TMDB_COLLECTION_ID_IMPORT "
                    strsql += "WHERE id NOT IN (SELECT ID_COLLECTION FROM T_WC_TMDB_COLLECTION WHERE DELETED = 0 AND TIM_CREDITS_COMPLETED IS NOT NULL) "
                    strsql += "ORDER BY id ASC "
                    strsql += "LIMIT 20000 "
                elif intindex == 2:
                    strcurrentprocess = f"{intindex}: processing new movies from TMDb ID files"
                    strsql += "SELECT id FROM T_WC_TMDB_MOVIE_ID_IMPORT "
                    strsql += "WHERE id NOT IN (SELECT ID_MOVIE FROM T_WC_TMDB_MOVIE WHERE DELETED = 0 AND TIM_CREDITS_COMPLETED IS NOT NULL) "
                    strsql += "ORDER BY popularity DESC "
                    strsql += "LIMIT 20000 "
                elif intindex == 3:
                    strcurrentprocess = f"{intindex}: processing new person from TMDb ID files"
                    strsql += "SELECT id FROM T_WC_TMDB_PERSON_ID_IMPORT "
                    strsql += "WHERE id NOT IN (SELECT ID_PERSON FROM T_WC_TMDB_PERSON WHERE DELETED = 0 AND TIM_CREDITS_COMPLETED IS NOT NULL) "
                    strsql += "ORDER BY popularity DESC "
                    strsql += "LIMIT 20000 "
                elif intindex == 4:
                    strcurrentprocess = f"{intindex}: processing new series from TMDb ID files"
                    strsql += "SELECT id FROM T_WC_TMDB_TV_SERIE_ID_IMPORT "
                    strsql += "WHERE id NOT IN (SELECT ID_SERIE FROM T_WC_TMDB_SERIE WHERE DELETED = 0 AND TIM_CREDITS_COMPLETED IS NOT NULL) "
                    strsql += "ORDER BY popularity DESC "
                    strsql += "LIMIT 20000 "
                elif intindex == 12:
                    strcurrentprocess = f"{intindex}: processing new keywords from TMDb ID files"
                    strsql += "SELECT id, name FROM T_WC_TMDB_KEYWORD_ID_IMPORT "
                    strsql += "WHERE id NOT IN (SELECT ID_KEYWORD FROM T_WC_TMDB_KEYWORD WHERE DELETED = 0 AND TIM_CREDITS_COMPLETED IS NOT NULL) "
                    strsql += "ORDER BY id ASC "
                elif intindex in (22, 24, 25, 26, 27, 28):
                    delta30 = timedelta(days=30)
                    datjminus30 = datnow - delta30
                    strdatjminus30 = datjminus30.strftime("%Y-%m-%d")
                    if intindex == 22:
                        strcurrentprocess = f"{intindex}: refreshing movies"
                        strsql += "SELECT T_WC_TMDB_MOVIE.ID_MOVIE AS id FROM T_WC_TMDB_MOVIE "
                        strsql += "WHERE T_WC_TMDB_MOVIE.TIM_UPDATED < '" + strdatjminus30 + "' "
                        strsql += "ORDER BY T_WC_TMDB_MOVIE.TIM_UPDATED ASC "
                        strsql += "LIMIT 5000 "
                    elif intindex == 24:
                        strcurrentprocess = f"{intindex}: refreshing persons"
                        strsql += "SELECT T_WC_TMDB_PERSON.ID_PERSON AS id FROM T_WC_TMDB_PERSON "
                        strsql += "WHERE T_WC_TMDB_PERSON.TIM_UPDATED < '" + strdatjminus30 + "' "
                        strsql += "ORDER BY T_WC_TMDB_PERSON.TIM_UPDATED ASC "
                        strsql += "LIMIT 5000 "
                    elif intindex == 25:
                        strcurrentprocess = f"{intindex}: refreshing collections"
                        strsql += "SELECT T_WC_TMDB_COLLECTION.ID_COLLECTION AS id FROM T_WC_TMDB_COLLECTION "
                        strsql += "WHERE T_WC_TMDB_COLLECTION.TIM_UPDATED < '" + strdatjminus30 + "' "
                        strsql += "ORDER BY T_WC_TMDB_COLLECTION.TIM_UPDATED ASC "
                        strsql += "LIMIT 5000 "
                    elif intindex == 26:
                        strcurrentprocess = f"{intindex}: refreshing companies"
                        strsql += "SELECT T_WC_TMDB_COMPANY.ID_COMPANY AS id FROM T_WC_TMDB_COMPANY "
                        strsql += "WHERE T_WC_TMDB_COMPANY.TIM_UPDATED < '" + strdatjminus30 + "' "
                        strsql += "ORDER BY T_WC_TMDB_COMPANY.TIM_UPDATED ASC "
                        strsql += "LIMIT 5000 "
                    elif intindex == 27:
                        strcurrentprocess = f"{intindex}: refreshing networks"
                        strsql += "SELECT T_WC_TMDB_NETWORK.ID_NETWORK AS id FROM T_WC_TMDB_NETWORK "
                        strsql += "WHERE T_WC_TMDB_NETWORK.TIM_UPDATED < '" + strdatjminus30 + "' "
                        strsql += "ORDER BY T_WC_TMDB_NETWORK.TIM_UPDATED ASC "
                        strsql += "LIMIT 5000 "
                    elif intindex == 28:
                        strcurrentprocess = f"{intindex}: refreshing series"
                        strsql += "SELECT T_WC_TMDB_SERIE.ID_SERIE AS id FROM T_WC_TMDB_SERIE "
                        strsql += "WHERE T_WC_TMDB_SERIE.TIM_UPDATED < '" + strdatjminus30 + "' "
                        strsql += "ORDER BY T_WC_TMDB_SERIE.TIM_UPDATED ASC "
                        strsql += "LIMIT 5000 "
                elif intindex == 23:
                    if strdattodayminus1 > strtmdbdatprev:
                        strcurrentprocess = f"{intindex}: refreshing movies when id wikidata is not set"
                        strsql += "SELECT T_WC_TMDB_MOVIE.ID_MOVIE AS id, "
                        strsql += "T_WC_WIKIDATA_MOVIE_V1.ID_WIKIDATA AS ID_WIKIDATA, "
                        strsql += "T_WC_WIKIDATA_MOVIE_V1.ID_IMDB, "
                        strsql += "T_WC_WIKIDATA_MOVIE_V1.ID_MOVIE AS ID_WIKIDATA_MOVIE, "
                        strsql += "T_WC_TMDB_MOVIE.ID_WIKIDATA AS ID_TMDB_WIKIDATA, "
                        strsql += "T_WC_TMDB_MOVIE.TITLE "
                        strsql += "FROM T_WC_WIKIDATA_MOVIE_V1 "
                        strsql += "INNER JOIN T_WC_TMDB_MOVIE ON T_WC_WIKIDATA_MOVIE_V1.ID_IMDB = T_WC_TMDB_MOVIE.ID_IMDB "
                        strsql += "WHERE T_WC_WIKIDATA_MOVIE_V1.ID_IMDB IS NOT NULL AND T_WC_WIKIDATA_MOVIE_V1.ID_IMDB <> '' AND T_WC_WIKIDATA_MOVIE_V1.ID_IMDB LIKE 'tt%' "
                        strsql += "AND T_WC_WIKIDATA_MOVIE_V1.ID_WIKIDATA <> T_WC_TMDB_MOVIE.ID_WIKIDATA "
                        strsql += "AND (T_WC_TMDB_MOVIE.ID_WIKIDATA IS NULL OR T_WC_TMDB_MOVIE.ID_WIKIDATA = '') "
                        strsql += "ORDER BY T_WC_TMDB_MOVIE.ID_MOVIE ASC "
                elif intindex == 13:
                    if strdattodayminus1 > strtmdbdatprev:
                        strcurrentprocess = f"{intindex}: refreshing lists"
                        strsql += "SELECT ID_LIST AS id, NAME FROM T_WC_TMDB_LIST "
                elif intindex == 14:
                    strcurrentprocess = f"{intindex}: processing deleted movies"
                    strsql += "SELECT ID_MOVIE as id "
                    strsql += "FROM T_WC_TMDB_MOVIE "
                    strsql += "WHERE T_WC_TMDB_MOVIE.ID_MOVIE NOT IN ( SELECT id AS ID_MOVIE FROM T_WC_TMDB_MOVIE_ID_IMPORT ) "
                    strsql += "AND T_WC_TMDB_MOVIE.ADULT = 0 "
                    strsql += "ORDER BY ID_MOVIE "
                elif intindex == 15:
                    strcurrentprocess = f"{intindex}: processing deleted persons"
                    strsql += "SELECT ID_PERSON as id "
                    strsql += "FROM T_WC_TMDB_PERSON "
                    strsql += "WHERE T_WC_TMDB_PERSON.ID_PERSON NOT IN ( SELECT id AS ID_PERSON FROM T_WC_TMDB_PERSON_ID_IMPORT ) "
                    strsql += "AND T_WC_TMDB_PERSON.ADULT = 0 "
                    strsql += "ORDER BY ID_PERSON "
                elif intindex == 16:
                    if strdattodayminus1 > strtmdbdatprev:
                        strcurrentprocess = f"{intindex}: processing deleted series"
                        strsql += "SELECT ID_SERIE as id "
                        strsql += "FROM T_WC_TMDB_SERIE "
                        strsql += "WHERE T_WC_TMDB_SERIE.ID_SERIE NOT IN ( SELECT id AS ID_SERIE FROM T_WC_TMDB_TV_SERIE_ID_IMPORT ) "
                        strsql += "ORDER BY ID_SERIE "
                elif intindex == 17:
                    strcurrentprocess = f"{intindex}: processing new companies from TMDb ID files"
                    strsql += "SELECT id FROM T_WC_TMDB_PRODUCTION_COMPANY_ID_IMPORT "
                    strsql += "WHERE id NOT IN (SELECT ID_COMPANY FROM T_WC_TMDB_COMPANY WHERE DELETED = 0) "
                    strsql += "ORDER BY id ASC "
                    strsql += "LIMIT 20000 "
                elif intindex == 18:
                    strcurrentprocess = f"{intindex}: processing new networks from TMDb ID files"
                    strsql += "SELECT id FROM T_WC_TMDB_TV_NETWORK_ID_IMPORT "
                    strsql += "WHERE id NOT IN (SELECT ID_NETWORK FROM T_WC_TMDB_NETWORK WHERE DELETED = 0) "
                    strsql += "ORDER BY id ASC "
                    strsql += "LIMIT 20000 "
                elif intindex == 31:
                    strcurrentprocess = f"{intindex}: processing persons found in movie credits but with no person record"
                    strsql += "SELECT DISTINCT ID_PERSON AS id "
                    strsql += "FROM T_WC_TMDB_PERSON_MOVIE "
                    strsql += "WHERE ID_PERSON NOT IN (SELECT ID_PERSON FROM T_WC_TMDB_PERSON) "
                    strsql += "ORDER BY ID_PERSON "
                elif intindex == 32:
                    strcurrentprocess = f"{intindex}: processing movies found in movie credits but with no movie record"
                    strsql += "SELECT DISTINCT ID_MOVIE AS id "
                    strsql += "FROM T_WC_TMDB_PERSON_MOVIE "
                    strsql += "WHERE ID_MOVIE NOT IN (SELECT ID_MOVIE FROM T_WC_TMDB_MOVIE) "
                    strsql += "ORDER BY ID_MOVIE "
                elif intindex == 33:
                    strcurrentprocess = f"{intindex}: processing series found in serie credits but with no serie record"
                    strsql += "SELECT DISTINCT ID_SERIE AS id "
                    strsql += "FROM T_WC_TMDB_PERSON_SERIE "
                    strsql += "WHERE ID_SERIE NOT IN (SELECT ID_SERIE FROM T_WC_TMDB_SERIE) "
                    strsql += "ORDER BY ID_SERIE "
                return strcurrentprocess, strsql

            def f_executeprocessrow(intindex, row):
                lngid = row['id']
                if intindex in (1, 25):
                    tf.f_tmdbcollectiontosqleverything(lngid)
                elif intindex in (2, 22, 23, 32):
                    tf.f_tmdbmovietosqleverything(lngid)
                elif intindex in (3, 24, 31):
                    tf.f_tmdbpersontosqleverything(lngid)
                elif intindex in (4, 28, 33):
                    tf.f_tmdbserietosqleverything(lngid)
                elif intindex in (17, 26):
                    tf.f_tmdbcompanytosqleverything(lngid)
                elif intindex in (18, 27):
                    tf.f_tmdbnetworktosqleverything(lngid)
                elif intindex == 12:
                    tf.f_tmdbkeywordtosqleverything(lngid, row['name'])
                elif intindex == 13:
                    tf.f_tmdblisttosqleverything(lngid)
                elif intindex == 14:
                    if not tf.f_tmdbmovieexist(lngid):
                        tf.f_tmdbmoviedelete(lngid)
                elif intindex == 15:
                    if not tf.f_tmdbpersonexist(lngid):
                        tf.f_tmdbpersondelete(lngid)
                elif intindex == 16:
                    if not tf.f_tmdbserieexist(lngid):
                        tf.f_tmdbseriedelete(lngid)

            def f_processrowwithmysqlguard(intindex, row, strdesc):
                lngid = row['id']
                try:
                    f_executeprocessrow(intindex, row)
                    return True
                except pymysql.MySQLError as e:
                    if cp.f_ismysqllocktimeout(e):
                        cp.f_handlemysqlerror(e, f"process {intindex} {strdesc} id {lngid}")
                        return False
                    raise

            def f_runprocessscope(arrprocessscope, strprocessesexecuted):
                for intindex, strdesc in arrprocessscope.items():
                    strprocessesexecuted += str(intindex) + ", "
                    cp.f_setservervariable("strtmdbcrawlerprocessesexecuted",strprocessesexecuted,strprocessesexecuteddesc,0)
                    strcurrentprocess, strsql = f_getprocesssql(intindex)
                    if strsql != "":
                        print(strcurrentprocess)
                        cp.f_setservervariable("strtmdbcrawlercurrentprocess",strcurrentprocess,"Current process in the TMDb API crawler",0)
                        print(strsql)
                        lngcount = 0
                        strdescvarname = strdesc.replace(" ","")
                        print("strdescvarname", strdescvarname)
                        cursor.execute(strsql)
                        lngrowcount = cursor.rowcount
                        print(f"{lngrowcount} lines")
                        results = cursor.fetchall()
                        for row in results:
                            lngid = row['id']
                            print(f"{strdesc} id: {lngid}")
                            if not f_processrowwithmysqlguard(intindex, row, strdesc):
                                continue
                            lngcount += 1
                            cp.f_setservervariable("strtmdbcrawlerprocess"+str(intindex)+strdescvarname+"count",str(lngcount),"Count of rows processed for process "+str(intindex)+" : "+strdesc+"",0)
                            strnow = datetime.now(cp.paris_tz).strftime("%Y-%m-%d %H:%M:%S")
                            cp.f_setservervariable("strtmdbcrawlerdatetime",strnow,"Date and time of the last crawled record using the TMDb API",0)
                    print("------------------------------------------")
                return strprocessesexecuted

            # Handling new content, missing content and refreshing some content (Loop #2)
            arrprocessscope = {17: 'new companies', 18: 'new networks', 12: 'new keywords', 1: 'new collections', 2:'new movies', 3:'new persons', 4: 'new series', 13:'refresh lists', 14:'deleted movies', 15:'deleted persons', 16: 'deleted series', 23: 'wikidata movie id fix', 31: 'missing persons', 32: 'missing movies', 33: 'missing series', 25: 'refreshing collections', 26: 'refreshing companies', 27: 'refreshing networks'}
            #if strnow.startswith("2026-04-20"):
            #    #arrprocessscope = {26: 'refreshing companies', 27: 'refreshing networks'}
            #    arrprocessscope = {0: 'nothing'}
            strprocessesexecuted = f_runprocessscope(arrprocessscope, strprocessesexecuted)
            strsql = ""
            
            # Now updating changed contents (Loop #3)
            strnowdate = datetime.now(cp.paris_tz).strftime("%Y-%m-%d")
            arrtmdbchanges = {51: 'movie', 52: 'person', 53: 'serie'}
            #arrtmdbchanges = {53: 'serie'}
            #arrtmdbchanges = {51: 'movie', 52:'person'}
            #arrtmdbchanges = {0: 'nothing'}
            #if strnow.startswith("2026-04-20"):
            #    arrtmdbchanges = {0: 'nothing'}
            for inttmdbchanges,strtmdbchanges in arrtmdbchanges.items():
                strprocessesexecuted += str(inttmdbchanges) + ", "
                cp.f_setservervariable("strtmdbcrawlerprocessesexecuted",strprocessesexecuted,strprocessesexecuteddesc,0)
                strtmdbchangesdatevarname = "strtmdbcrawlerchanges" + strtmdbchanges + "date"
                strtmdbchangescountvarname = "strtmdbcrawlerchanges" + strtmdbchanges + "count"
                strtmdbchangesdate = cp.f_getservervariable(strtmdbchangesdatevarname,0)
                print(f"strtmdbchangesdatevarname = '{strtmdbchangesdatevarname}' ; strtmdbchangesdate = '{strtmdbchangesdate}'")
                if strtmdbchangesdate != "":
                    dattmdbchangesdate = datetime.strptime(strtmdbchangesdate, '%Y-%m-%d')
                    datprevday = dattmdbchangesdate - timedelta(days=2)
                    strtmdbchangesdate = datprevday.strftime('%Y-%m-%d')
                strcurrentprocess = f"{inttmdbchanges}: Processing {strtmdbchanges} changes from the TMDb API"
                cp.f_setservervariable("strtmdbcrawlercurrentprocess",strcurrentprocess,"Current process in the TMDb API crawler",0)
                strsqltable = ""
                if inttmdbchanges == 51:
                    # Movie changes
                    strsqltable = "T_WC_TMDB_MOVIE"
                    strtmdbchangesapi = "movie"
                elif inttmdbchanges == 52:
                    # Person changes
                    strsqltable = "T_WC_TMDB_PERSON"
                    strtmdbchangesapi = "person"
                elif inttmdbchanges == 53:
                    # TV serie changes
                    strsqltable = "T_WC_TMDB_SERIE"
                    strtmdbchangesapi = "tv"
                if strsqltable != "":
                    lngcount = 0
                    if strtmdbchangesdate == "":
                        strsql = "SELECT MIN(TIM_UPDATED) AS DATEMIN FROM " + strsqltable + " "
                        cursor.execute(strsql)
                        results = cursor.fetchall()
                        for row in results:
                            dattmdbchangesdate = row['DATEMIN']
                            strtmdbchangesdate = dattmdbchangesdate.strftime("%Y-%m-%d")
                            strtmdbchangesdate = strtmdbchangesdate[:10]
                            cp.f_setservervariable(strtmdbchangesdatevarname,strtmdbchangesdate,"Date of the last request for " + str(inttmdbchanges) + " : " + strtmdbchanges + " changes using the TMDb API",0)
                    intencoredate = True
                    while intencoredate:
                        if strtmdbchangesdate == "" or strtmdbchangesdate > strnowdate:
                            intencoredate = False
                        else:
                            # Now process changes for the given date 
                            lngpage = 1
                            lngtotalpages = 0
                            dattmdbchangesdate = datetime.strptime(strtmdbchangesdate, '%Y-%m-%d')
                            dattmdbchangesdateplus2 = dattmdbchangesdate + timedelta(days=2)
                            strtmdbchangesdateplus2 = dattmdbchangesdateplus2.strftime('%Y-%m-%d')
                            intencore = True
                            while intencore:
                                strtmdbapichangesurl = "3/" + strtmdbchangesapi + "/changes?start_date=" + strtmdbchangesdate + "&end_date=" + strtmdbchangesdate + "&page=" + str(lngpage)
                                strtmdbapifullurl = cp.strtmdbapidomainurl + "/" + strtmdbapichangesurl
                                print(strtmdbapifullurl)
                                response = requests.get(strtmdbapifullurl, headers=cp.headers)
                                data = response.json()
                                # print(data)
                                results = data['results']
                                lngtotalpages = data['total_pages']
                                print("total_pages =",lngtotalpages)
                                for row in results:
                                    lngid = row['id']
                                    intadult = row['adult']
                                    if 1:
                                        # We can refresh this content
                                        if inttmdbchanges == 51:
                                            # Movie changes
                                            # Check if this movie was already retrieved from TMDb 2 days after it was updated on TMDb
                                            strsqlselect = "SELECT * FROM T_WC_TMDB_MOVIE WHERE ID_MOVIE = " + str(lngid) + " AND DELETED = 0 AND TIM_CREDITS_COMPLETED >= '" + strtmdbchangesdateplus2 + "' "
                                            #print(strsqlselect)
                                            cursor3.execute(strsqlselect)
                                            lngrowcount = cursor3.rowcount
                                            if lngrowcount == 0:
                                                #print("Not already retrieved so we have to update it from the TMDb API")
                                                print(f"{strtmdbchanges} changed id: {lngid}")
                                                try:
                                                    tf.f_tmdbmovietosqleverything(lngid)
                                                except pymysql.MySQLError as e:
                                                    if cp.f_ismysqllocktimeout(e):
                                                        cp.f_handlemysqlerror(e, f"changes {inttmdbchanges} {strtmdbchanges} id {lngid}")
                                                        continue
                                                    raise
                                                lngcount += 1
                                            else:
                                                results3 = cursor3.fetchall()
                                                for row3 in results3:
                                                    timupdated = row3['TIM_CREDITS_COMPLETED']
                                                    print(f"Movie {lngid} retrieved at {timupdated} so download using the TMDb API not necessary")
                                        elif inttmdbchanges == 52:
                                            # Person changes
                                            # Check if this person was already retrieved from TMDb 2 days after it was updated on TMDb
                                            strsqlselect = "SELECT * FROM T_WC_TMDB_PERSON WHERE ID_PERSON = " + str(lngid) + " AND DELETED = 0 AND TIM_CREDITS_COMPLETED >= '" + strtmdbchangesdateplus2 + "' "
                                            #print(strsqlselect)
                                            cursor3.execute(strsqlselect)
                                            lngrowcount = cursor3.rowcount
                                            if lngrowcount == 0:
                                                #print("Not already retrieved so we have to update it from the TMDb API")
                                                print(f"{strtmdbchanges} changed id: {lngid}")
                                                try:
                                                    tf.f_tmdbpersontosqleverything(lngid)
                                                except pymysql.MySQLError as e:
                                                    if cp.f_ismysqllocktimeout(e):
                                                        cp.f_handlemysqlerror(e, f"changes {inttmdbchanges} {strtmdbchanges} id {lngid}")
                                                        continue
                                                    raise
                                                lngcount += 1
                                            else:
                                                results3 = cursor3.fetchall()
                                                for row3 in results3:
                                                    timupdated = row3['TIM_CREDITS_COMPLETED']
                                                    print(f"Person {lngid} retrieved at {timupdated} so download using the TMDb API not necessary")
                                        if inttmdbchanges == 53:
                                            # Serie changes
                                            # Check if this serie was already retrieved from TMDb 2 days after it was updated on TMDb
                                            strsqlselect = "SELECT * FROM T_WC_TMDB_SERIE WHERE ID_SERIE = " + str(lngid) + " AND DELETED = 0 AND TIM_CREDITS_COMPLETED >= '" + strtmdbchangesdateplus2 + "' "
                                            #print(strsqlselect)
                                            cursor3.execute(strsqlselect)
                                            lngrowcount = cursor3.rowcount
                                            if lngrowcount == 0:
                                                #print("Not already retrieved so we have to update it from the TMDb API")
                                                print(f"{strtmdbchanges} changed id: {lngid}")
                                                try:
                                                    tf.f_tmdbserietosqleverything(lngid)
                                                    tf.f_tmdbserieselectiveseasonsepisodestosql(lngid)
                                                except pymysql.MySQLError as e:
                                                    if cp.f_ismysqllocktimeout(e):
                                                        cp.f_handlemysqlerror(e, f"changes {inttmdbchanges} {strtmdbchanges} id {lngid}")
                                                        continue
                                                    raise
                                                lngcount += 1
                                            else:
                                                results3 = cursor3.fetchall()
                                                for row3 in results3:
                                                    timupdated = row3['TIM_CREDITS_COMPLETED']
                                                    print(f"Serie {lngid} retrieved at {timupdated} so download using the TMDb API not necessary")
                                strnow = datetime.now(cp.paris_tz).strftime("%Y-%m-%d %H:%M:%S")
                                cp.f_setservervariable("strtmdbcrawlerdatetime",strnow,"Date and time of the last crawled record using the TMDb API",0)
                                lngpage += 1
                                if lngpage > lngtotalpages:
                                    intencore = False
                            # The current date is fully processed
                            print("The current date is fully processed")
                            dattmdbchangesdate = datetime.strptime(strtmdbchangesdate, '%Y-%m-%d')
                            print("dattmdbchangesdate=",strtmdbchangesdate)
                            datnextday = dattmdbchangesdate + timedelta(days=1)
                            strtmdbchangesdate = datnextday.strftime('%Y-%m-%d')
                            print("datnextday=",strtmdbchangesdate)
                            cp.f_setservervariable(strtmdbchangesdatevarname,strtmdbchangesdate,"Date of the last request for " + str(inttmdbchanges) + " : " + strtmdbchanges + " changes using the TMDb API",0)
                            cp.f_setservervariable(strtmdbchangescountvarname,str(lngcount),"Count of " + str(inttmdbchanges) + " : " + strtmdbchanges + " changes using the TMDb API",0)
                            strnowdate = datetime.now(cp.paris_tz).strftime("%Y-%m-%d")
                            if strtmdbchangesdate > strnowdate:
                                intencoredate = False

            # Configuration for missing images processing (Loop #4)
            # Each entity type is configured with:
            # - content_table: main content table name
            # - image_table: corresponding image table name
            # - id_field: primary key field name in both tables
            # - image_fields: list of tuples (field_name, image_type) for each image path to check
            # - language: language code for the images (e.g., 'en') or 'from_table' to read from LANG column
            # - lang_field: (optional) name of the language column in content_table when language='from_table'
            missing_images_config = {
                61: {
                    'desc': 'movie images',
                    'content_table': 'T_WC_TMDB_MOVIE',
                    'image_table': 'T_WC_TMDB_MOVIE_IMAGE',
                    'id_field': 'ID_MOVIE',
                    'image_fields': [
                        ('POSTER_PATH', 'poster'),
                        ('BACKDROP_PATH', 'backdrop')
                    ],
                    'language': 'en'
                },
                62: {
                    'desc': 'person images',
                    'content_table': 'T_WC_TMDB_PERSON',
                    'image_table': 'T_WC_TMDB_PERSON_IMAGE',
                    'id_field': 'ID_PERSON',
                    'image_fields': [
                        ('PROFILE_PATH', 'profile')
                    ],
                    'language': 'en'
                },
                63: {
                    'desc': 'serie images',
                    'content_table': 'T_WC_TMDB_SERIE',
                    'image_table': 'T_WC_TMDB_SERIE_IMAGE',
                    'id_field': 'ID_SERIE',
                    'image_fields': [
                        ('POSTER_PATH', 'poster'),
                        ('BACKDROP_PATH', 'backdrop')
                    ],
                    'language': 'en'
                },
                64: {
                    'desc': 'collection images',
                    'content_table': 'T_WC_TMDB_COLLECTION',
                    'image_table': 'T_WC_TMDB_COLLECTION_IMAGE',
                    'id_field': 'ID_COLLECTION',
                    'image_fields': [
                        ('POSTER_PATH', 'poster'),
                        ('BACKDROP_PATH', 'backdrop')
                    ],
                    'language': 'en'
                },
                65: {
                    'desc': 'company images',
                    'content_table': 'T_WC_TMDB_COMPANY',
                    'image_table': 'T_WC_TMDB_COMPANY_IMAGE',
                    'id_field': 'ID_COMPANY',
                    'image_fields': [
                        ('LOGO_PATH', 'logo')
                    ],
                    'language': 'en'
                },
                66: {
                    'desc': 'network images',
                    'content_table': 'T_WC_TMDB_NETWORK',
                    'image_table': 'T_WC_TMDB_NETWORK_IMAGE',
                    'id_field': 'ID_NETWORK',
                    'image_fields': [
                        ('LOGO_PATH', 'logo')
                    ],
                    'language': 'en'
                },
                67: {
                    'desc': 'movie lang images',
                    'content_table': 'T_WC_TMDB_MOVIE_LANG',
                    'image_table': 'T_WC_TMDB_MOVIE_IMAGE',
                    'id_field': 'ID_MOVIE',
                    'image_fields': [
                        ('POSTER_PATH', 'poster'),
                        ('BACKDROP_PATH', 'backdrop')
                    ],
                    'language': 'from_table',  # Read from LANG column
                    'lang_field': 'LANG'
                },
                68: {
                    'desc': 'serie lang images',
                    'content_table': 'T_WC_TMDB_SERIE_LANG',
                    'image_table': 'T_WC_TMDB_SERIE_IMAGE',
                    'id_field': 'ID_SERIE',
                    'image_fields': [
                        ('POSTER_PATH', 'poster'),
                        ('BACKDROP_PATH', 'backdrop')
                    ],
                    'language': 'from_table',  # Read from LANG column
                    'lang_field': 'LANG'
                },
                69: {
                    'desc': 'collection lang images',
                    'content_table': 'T_WC_TMDB_COLLECTION_LANG',
                    'image_table': 'T_WC_TMDB_COLLECTION_IMAGE',
                    'id_field': 'ID_COLLECTION',
                    'image_fields': [
                        ('POSTER_PATH', 'poster'),
                        ('BACKDROP_PATH', 'backdrop')
                    ],
                    'language': 'from_table',  # Read from LANG column
                    'lang_field': 'LANG'
                }
            }

            # Helper function to process missing images for any entity type
            def process_missing_images(config, cursor, intimageindex):
                """
                Process missing images for a given entity type.

                Args:
                    config: Configuration dict with content_table, image_table, id_field, image_fields, language
                    cursor: Database cursor
                    intimageindex: Process index for logging

                Returns:
                    tuple: (lngcount, lnginsertcount) - number of records processed and images inserted
                """
                strlang = config['language']
                content_table = config['content_table']
                image_table = config['image_table']
                id_field = config['id_field']
                image_fields = config['image_fields']

                # Check if language should be read from table
                use_lang_from_table = (strlang == 'from_table')
                lang_field = config.get('lang_field', 'LANG') if use_lang_from_table else None

                # Build SELECT query with all image path fields
                field_list = [id_field] + [field_name for field_name, _ in image_fields]
                if use_lang_from_table:
                    field_list.append(lang_field)
                strsql = f"SELECT {', '.join(field_list)} FROM {content_table} WHERE DELETED = 0 ORDER BY {id_field}"

                cursor.execute(strsql)
                results = cursor.fetchall()

                lngcount = 0
                lnginsertcount = 0

                for row in results:
                    lngid = row[id_field]

                    # Get language for this row (either from config or from table)
                    if use_lang_from_table:
                        row_lang = row.get(lang_field, 'en')  # Default to 'en' if LANG is null
                    else:
                        row_lang = strlang

                    # Process each image field for this record
                    for field_name, image_type in image_fields:
                        image_path = row[field_name]

                        if image_path and image_path != '':
                            # Check if image already exists in image table
                            strsqlcheck = f"SELECT ID_ROW FROM {image_table} WHERE {id_field} = %s AND IMAGE_PATH = %s AND DELETED = 0"
                            cursor.execute(strsqlcheck, (lngid, image_path))

                            if cursor.rowcount == 0:
                                # Insert missing image
                                strsqlinsert = f"""INSERT INTO {image_table}
                                    ({id_field}, IMAGE_PATH, TYPE_IMAGE, DELETED, DISPLAY_ORDER, DAT_CREAT, TIM_UPDATED, LANG)
                                    VALUES (%s, %s, %s, 0, 0, NOW(), NOW(), %s)"""
                                cursor.execute(strsqlinsert, (lngid, image_path, image_type, row_lang))
                                lnginsertcount += 1
                                print(f"Inserted missing {image_type} for {content_table.lower().replace('t_wc_tmdb_', '')} {lngid}: {image_path} (lang: {row_lang})")

                    lngcount += 1
                    if lngcount % 100 == 0:
                        conn.commit()
                        print(f"Processed {lngcount} records, inserted {lnginsertcount} missing images")

                conn.commit()
                return lngcount, lnginsertcount

            # Now handling missing images (Loop #4)
            arrmissingimages = {61: 'movie images', 62: 'person images', 63: 'serie images', 64: 'collection images', 65: 'company images', 66: 'network images', 67: 'movie lang images', 68: 'serie lang images', 69: 'collection lang images'}
            #arrmissingimages = {61: 'movie images'}
            #if strnow.startswith("2026-04-20"):
            #    arrmissingimages = {0: 'nothing'}
            for intimageindex, strimagedesc in arrmissingimages.items():
                strprocessesexecuted += str(intimageindex) + ", "
                cp.f_setservervariable("strtmdbcrawlerprocessesexecuted",strprocessesexecuted,strprocessesexecuteddesc,0)
                strcurrentprocess = f"{intimageindex}: processing missing {strimagedesc}"
                print(strcurrentprocess)
                cp.f_setservervariable("strtmdbcrawlercurrentprocess",strcurrentprocess,"Current process in the TMDb API crawler",0)

                # Use the helper function with configuration if this index is configured
                if intimageindex in missing_images_config:
                    config = missing_images_config[intimageindex]
                    lngcount, lnginsertcount = process_missing_images(config, cursor, intimageindex)
                else:
                    lngcount = 0
                    lnginsertcount = 0

                print(f"Completed {strimagedesc}: processed {lngcount} records, inserted {lnginsertcount} missing images")
                cp.f_setservervariable("strtmdbcrawlerprocess"+str(intimageindex)+strimagedesc.replace(' ','')+"count",str(lnginsertcount),"Count of inserted rows for process "+str(intimageindex)+" : "+strimagedesc+"",0)
                print("------------------------------------------")

            # Now handling refreshing contents (Loop #5)
            arrprocessscope = {22: 'refreshing movies', 28: 'refreshing series', 24: 'refreshing persons'}
            #if strnow.startswith("2026-04-20"):
            #    arrprocessscope = {28: 'refreshing series', 24: 'refreshing persons'}
            strprocessesexecuted = f_runprocessscope(arrprocessscope, strprocessesexecuted)

            strcurrentprocess = ""
            cp.f_setservervariable("strtmdbcrawlercurrentprocess",strcurrentprocess,"Current process in the TMDb API crawler",0)
            strnow = datetime.now(cp.paris_tz).strftime("%Y-%m-%d %H:%M:%S")
            cp.f_setservervariable("strtmdbcrawlerenddatetime",strnow,"Date and time of the TMDb API crawler ending",0)
            # Calculate total runtime and convert to readable format
            end_time = time.time()
            strtotalruntime = int(end_time - start_time)  # Total runtime in seconds
            cp.f_setservervariable("strtmdbcrawlertotalruntimeseconds",str(strtotalruntime),strtotalruntimedesc,0)
            readable_duration = cp.convert_seconds_to_duration(strtotalruntime)
            cp.f_setservervariable("strtmdbcrawlertotalruntime",readable_duration,strtotalruntimedesc,0)
            print(f"Total runtime: {strtotalruntime} seconds ({readable_duration})")
    print("Process completed")
except pymysql.MySQLError as e:
    cp.f_handlemysqlerror(e, "tmdb-crawler main")
