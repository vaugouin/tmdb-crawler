import time
import requests
import pymysql.cursors
import json
import citizenphil as cp
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

strprocessesexecutedprevious = cp.f_getservervariable("strtmdbcrawlerprocessesexecuted",0)
strprocessesexecuteddesc = "List of processes executed in the TMDb API crawler"
cp.f_setservervariable("strtmdbcrawlerprocessesexecutedprevious",strprocessesexecutedprevious,strprocessesexecuteddesc + " (previous execution)",0)
strprocessesexecuted = ""
cp.f_setservervariable("strtmdbcrawlerprocessesexecuted",strprocessesexecuted,strprocessesexecuteddesc,0)

try:
    with cp.connectioncp:
        with cp.connectioncp.cursor() as cursor:
            cursor3 = cp.connectioncp.cursor()
            strnow = datetime.now(cp.paris_tz).strftime("%Y-%m-%d %H:%M:%S")
            cp.f_setservervariable("strtmdbcrawlerstartdatetime",strnow,"Date and time of the last start of the TMDb API crawler",0)
            #cp.f_setservervariable("strtmdbcrawlercurrentsql","","Current SQL query in the TMDb API crawler",0)
            # What id files should we process from the TMDb HTTP server? 
            arrtmdbidfilename = {41: 'movie', 42:'person', 43:'collection', 44:'tv_series', 45: 'keyword', 46: 'tv_network', 47: 'production_company'}
            #arrtmdbidfilename = {45: 'keyword'}
            #arrtmdbidfilename = {41: 'movie'}
            intdownloadok = True
            if strdattodayminus1 > strtmdbdatprev:
                # This is a newer date, so we must import the TMDb ID files and import them in the MySQL database
                print("This is a newer date, so we must download the TMDb ID files and import them in the MySQL database")
                # By default, we assume download will be ok 
                inttruncate = False
                intloaddatainfile = False
                # First download the id file from the TMDb HTTP server and import them in the MySQL database
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
                        # Send a GET request to the URL with streaming enabled
                        response = requests.get(strtmdbidfileurl, stream=True)
                        # Check if the request was successful
                        if response.status_code == 200:
                            # Open a file in binary write mode
                            print(f"Extract {strlocalgzfilename} to {strlocaljsonfilename}")
                            with open(strlocalgzfilename, 'wb') as file:
                                # Iterate over the response data in chunks
                                for chunk in response.iter_content(chunk_size=8192):
                                    # Write each chunk to the local file
                                    file.write(chunk)
                                # file.write(response.content)
                            # Extract gz to json
                            with gzip.open(strlocalgzfilename, 'rb') as f_in:
                                # Open a new file in write-binary mode
                                with open(strlocaljsonfilename, 'wb') as f_out:
                                    # Copy the decompressed data to the new file
                                    shutil.copyfileobj(f_in, f_out)
                            # Open and read the JSON file
                            print(f"Import {strlocaljsonfilename} to {strtmdbidsqltable}")
                            if intloaddatainfile:
                                # Fast process using the LOAD DATA INFILE instruction
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
                                # Final commit if needed (though COMMIT is in strsqlafter)
                                #connection.commit()
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
                                            # print(strsql)
                                            try:
                                                cursor.execute(strsql, list(record.values()))
                                                lngcount += 1
                                                if lngcount % 100 == 0:
                                                    # Commit the changes to the database
                                                    cp.connectioncp.commit()
                                                    cp.f_setservervariable("strtmdbcrawlertmdbid"+strtmdbidfilename+"count",str(lngcount),"Record count of the TMDb "+strtmdbidfilename+" ID import file",0)
                                            except pymysql.MySQLError as e:
                                                print(f"❌ MySQL Error: {e}")
                                                cp.connectioncp.rollback()
                                    cp.connectioncp.commit()
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
            
            # Now handling new contents from TMdB
            arrprocessscope = {17: 'new companies', 18: 'new networks', 1: 'new collections', 2:'new movies', 3:'new persons', 4: 'new series', 13:'refresh lists', 14:'deleted movies', 15:'deleted persons', 16: 'deleted series', 23: 'wikidata movie id fix', 31: 'missing persons', 32: 'missing movies', 33: 'missing series', 22: 'refreshing movies', 24: 'refreshing persons', 25: 'refreshing collections', 26: 'refreshing companies', 27: 'refreshing networks'}
            #arrprocessscope = {22: 'refreshing movies'}
            #arrprocessscope = {4: 'new series', 16: 'deleted series', 33: 'missing series'}
            #arrprocessscope = {17: 'new companies', 12: 'new keywords', 1: 'new collections', 2:'new movies', 3:'new persons', 13:'refresh lists', 23: 'wikidata movie id fix', 31: 'missing persons', 32: 'missing movies'}
            #arrprocessscope = {24: 'refreshing persons'}
            #arrprocessscope = {31: 'missing persons'}
            #arrprocessscope = {32: 'missing movies'}
            #arrprocessscope = {4: 'new series', 16: 'deleted series'}
            #arrprocessscope = {18: 'new networks'}
            #arrprocessscope = {25: 'refreshing collections'}
            #arrprocessscope = {27: 'refreshing networks'}
            #arrprocessscope = {26: 'refreshing companies'}
            #arrprocessscope = {0: 'nothing'}
            for intindex, strdesc in arrprocessscope.items():
                # Get the current date and time
                datnow = datetime.now(cp.paris_tz)
                # Compute the date and time 14 days ago
                delta = timedelta(days=14)
                datjminus14 = datnow - delta
                strdatjminus14 = datjminus14.strftime("%Y-%m-%d %H:%M:%S")
                strprocessesexecuted += str(intindex) + ", "
                cp.f_setservervariable("strtmdbcrawlerprocessesexecuted",strprocessesexecuted,strprocessesexecuteddesc,0)
                # Print the result (optional)
                #print("Current Date and Time:", current_datetime)
                #print("Date and Time 14 days ago:", past_datetime)
                # Now use the TMDb API to import data into the MySQL database
                # print(intindex, value)
                strcurrentprocess = ""
                strsql = ""
                if intindex == 1:
                    strcurrentprocess = f"{intindex}: processing new collections from TMDb ID files"
                    strsql = ""
                    strsql += "SELECT id FROM T_WC_TMDB_COLLECTION_ID_IMPORT "
                    strsql += "WHERE id NOT IN (SELECT ID_COLLECTION FROM T_WC_TMDB_COLLECTION WHERE DELETED = 0 AND TIM_CREDITS_COMPLETED IS NOT NULL) "
                    strsql += "ORDER BY id ASC "
                    strsql += "LIMIT 20000 "
                elif intindex == 2:
                    # New movies
                    strcurrentprocess = f"{intindex}: processing new movies from TMDb ID files"
                    strsql = ""
                    strsql += "SELECT id FROM T_WC_TMDB_MOVIE_ID_IMPORT "
                    strsql += "WHERE id NOT IN (SELECT ID_MOVIE FROM T_WC_TMDB_MOVIE WHERE DELETED = 0 AND TIM_CREDITS_COMPLETED IS NOT NULL) "
                    # strsql += "AND id = 1154175 "
                    # strsql += "AND popularity >= 10 "
                    strsql += "ORDER BY popularity DESC "
                    strsql += "LIMIT 20000 "
                elif intindex == 3:
                    strcurrentprocess = f"{intindex}: processing new person from TMDb ID files"
                    strsql = ""
                    strsql += "SELECT id FROM T_WC_TMDB_PERSON_ID_IMPORT "
                    strsql += "WHERE id NOT IN (SELECT ID_PERSON FROM T_WC_TMDB_PERSON WHERE DELETED = 0 AND TIM_CREDITS_COMPLETED IS NOT NULL) "
                    # strsql += "AND popularity >= 10 "
                    strsql += "ORDER BY popularity DESC "
                    strsql += "LIMIT 20000 "
                elif intindex == 4:
                    # New series
                    strcurrentprocess = f"{intindex}: processing new series from TMDb ID files"
                    strsql = ""
                    strsql += "SELECT id FROM T_WC_TMDB_TV_SERIE_ID_IMPORT "
                    strsql += "WHERE id NOT IN (SELECT ID_SERIE FROM T_WC_TMDB_SERIE WHERE DELETED = 0 AND TIM_CREDITS_COMPLETED IS NOT NULL) "
                    #strsql += "AND id = 1399 "
                    # strsql += "AND popularity >= 10 "
                    strsql += "ORDER BY popularity DESC "
                    strsql += "LIMIT 20000 "
                elif intindex == 7:
                    strcurrentprocess = f"{intindex}: processing uncomplete movie keywords"
                    strsql = ""
                    strsql += "SELECT T_WC_TMDB_MOVIE.ID_MOVIE AS id FROM T_WC_TMDB_MOVIE "
                    strsql += "WHERE T_WC_TMDB_MOVIE.TIM_KEYWORDS_COMPLETED IS NULL "
                    strsql += "ORDER BY T_WC_TMDB_MOVIE.POPULARITY DESC "
                elif intindex == 8:
                    strcurrentprocess = f"{intindex}: processing persons WHERE CRAWLER_VERSION <= 2"
                    strsql = ""
                    strsql += "SELECT ID_PERSON AS id FROM T_WC_TMDB_PERSON "
                    strsql += "WHERE CRAWLER_VERSION <= 2 "
                    strsql += "ORDER BY POPULARITY DESC "
                elif intindex == 9:
                    strcurrentprocess = f"{intindex}: processing new movies in French from TMDb ID files"
                    strsql = ""
                    strsql += "SELECT ID_MOVIE AS id FROM T_WC_TMDB_MOVIE "
                    strsql += "WHERE ID_MOVIE NOT IN (SELECT ID_MOVIE FROM T_WC_TMDB_MOVIE_LANG WHERE LANG = 'fr' AND DELETED = 0) "
                    strsql += "ORDER BY POPULARITY DESC "
                elif intindex == 10:
                    strcurrentprocess = f"{intindex}: processing new collections in French from TMDb ID files"
                    strsql = ""
                    strsql += "SELECT ID_COLLECTION AS id FROM T_WC_TMDB_COLLECTION "
                    strsql += "WHERE ID_COLLECTION NOT IN (SELECT ID_COLLECTION FROM T_WC_TMDB_COLLECTION_LANG WHERE LANG = 'fr' AND DELETED = 0) "
                elif intindex == 11:
                    # Refreshing movies
                    strcurrentprocess = f"{intindex}: refreshing movies"
                    strsql = ""
                    strsql += "SELECT T_WC_TMDB_MOVIE.ID_MOVIE AS id FROM T_WC_TMDB_MOVIE "
                    #strsql += "WHERE T_WC_TMDB_MOVIE.TIM_CREDITS_COMPLETED < '" + strdatjminus14 + "' "
                    strsql += "WHERE T_WC_TMDB_MOVIE.TIM_CREDITS_COMPLETED < '" + strdatjminus14 + "' "
                    strsql += "ORDER BY T_WC_TMDB_MOVIE.TIM_CREDITS_COMPLETED "
                    strsql += "LIMIT 20000 "
                elif intindex == 22:
                    # Refreshing movies
                    strcurrentprocess = f"{intindex}: refreshing movies"
                    strsql = ""
                    strsql += "SELECT T_WC_TMDB_MOVIE.ID_MOVIE AS id FROM T_WC_TMDB_MOVIE "
                    strsql += "WHERE T_WC_TMDB_MOVIE.TIM_UPDATED < '2025-07-17' "
                    #strsql += "AND (T_WC_TMDB_MOVIE.ID_MOVIE IN ( "
                    #strsql += "SELECT ID_MOVIE FROM T_WC_TMDB_MOVIE_LIST WHERE ID_LIST IN ( "
                    #strsql += "SELECT ID_LIST FROM T_WC_TMDB_LIST WHERE DELETED = 0 AND USE_FOR_TAGGING = 1 "
                    #strsql += ") "
                    #strsql += ") "
                    #strsql += "OR (T_WC_WIKIDATA_MOVIE.ID_CRITERION IS NOT NULL AND T_WC_WIKIDATA_MOVIE.ID_CRITERION <> 0) "
                    #strsql += ") "
                    strsql += "ORDER BY T_WC_TMDB_MOVIE.TIM_UPDATED ASC "
                    strsql += "LIMIT 20000 "
                elif intindex == 24:
                    # Refreshing persons
                    strcurrentprocess = f"{intindex}: refreshing persons"
                    strsql = ""
                    strsql += "SELECT T_WC_TMDB_PERSON.ID_PERSON AS id FROM T_WC_TMDB_PERSON "
                    strsql += "WHERE T_WC_TMDB_PERSON.TIM_UPDATED < '2025-07-18' "
                    strsql += "ORDER BY T_WC_TMDB_PERSON.TIM_UPDATED ASC "
                    strsql += "LIMIT 20000 "
                elif intindex == 23:
                    # Refreshing movies when id wikidata is not set
                    if strdattodayminus1 > strtmdbdatprev:
                        # This is a newer date, so we process
                        strcurrentprocess = f"{intindex}: refreshing movies when id wikidata is not set"
                        strsql = ""
                        strsql += "SELECT T_WC_TMDB_MOVIE.ID_MOVIE AS id, "
                        strsql += "T_WC_WIKIDATA_MOVIE.ID_WIKIDATA AS ID_WIKIDATA, "
                        strsql += "T_WC_WIKIDATA_MOVIE.ID_IMDB, "
                        strsql += "T_WC_WIKIDATA_MOVIE.ID_MOVIE AS ID_WIKIDATA_MOVIE, "
                        strsql += "T_WC_TMDB_MOVIE.ID_WIKIDATA AS ID_TMDB_WIKIDATA, "
                        strsql += "T_WC_TMDB_MOVIE.TITLE "
                        strsql += "FROM T_WC_WIKIDATA_MOVIE "
                        strsql += "INNER JOIN T_WC_TMDB_MOVIE ON T_WC_WIKIDATA_MOVIE.ID_IMDB = T_WC_TMDB_MOVIE.ID_IMDB "
                        strsql += "WHERE T_WC_WIKIDATA_MOVIE.ID_IMDB IS NOT NULL AND T_WC_WIKIDATA_MOVIE.ID_IMDB <> '' AND T_WC_WIKIDATA_MOVIE.ID_IMDB LIKE 'tt%' "
                        strsql += "AND T_WC_WIKIDATA_MOVIE.ID_WIKIDATA <> T_WC_TMDB_MOVIE.ID_WIKIDATA "
                        strsql += "AND (T_WC_TMDB_MOVIE.ID_WIKIDATA IS NULL OR T_WC_TMDB_MOVIE.ID_WIKIDATA = '') "
                        strsql += "ORDER BY T_WC_TMDB_MOVIE.ID_MOVIE ASC "
                elif intindex == 25:
                    # Refreshing collections
                    strcurrentprocess = f"{intindex}: refreshing collections"
                    strsql = ""
                    strsql += "SELECT T_WC_TMDB_COLLECTION.ID_COLLECTION AS id FROM T_WC_TMDB_COLLECTION "
                    strsql += "WHERE T_WC_TMDB_COLLECTION.TIM_UPDATED < '2025-07-18' "
                    strsql += "ORDER BY T_WC_TMDB_COLLECTION.TIM_UPDATED ASC "
                    strsql += "LIMIT 20000 "
                elif intindex == 26:
                    # Refreshing companies
                    strcurrentprocess = f"{intindex}: refreshing companies"
                    strsql = ""
                    strsql += "SELECT T_WC_TMDB_COMPANY.ID_COMPANY AS id FROM T_WC_TMDB_COMPANY "
                    strsql += "WHERE T_WC_TMDB_COMPANY.TIM_UPDATED < '2025-07-18' "
                    strsql += "ORDER BY T_WC_TMDB_COMPANY.TIM_UPDATED ASC "
                    strsql += "LIMIT 20000 "
                elif intindex == 27:
                    # Refreshing networks
                    strcurrentprocess = f"{intindex}: refreshing networks"
                    strsql = ""
                    strsql += "SELECT T_WC_TMDB_NETWORK.ID_NETWORK AS id FROM T_WC_TMDB_NETWORK "
                    strsql += "WHERE T_WC_TMDB_NETWORK.TIM_UPDATED < '2025-07-18' "
                    strsql += "ORDER BY T_WC_TMDB_NETWORK.TIM_UPDATED ASC "
                    strsql += "LIMIT 20000 "
                elif intindex == 12:
                    # New keywords
                    strcurrentprocess = f"{intindex}: processing new keywords in French from TMDb ID files"
                    strsql = ""
                    strsql += "SELECT id, name FROM T_WC_TMDB_KEYWORD_ID_IMPORT "
                    strsql += "WHERE id NOT IN (SELECT id FROM T_WC_TMDB_KEYWORD_ID_IMPORT_LANG WHERE LANG = 'fr') "
                    strsql += "LIMIT 20000 "
                elif intindex == 13:
                    # Refresh lists
                    if strdattodayminus1 > strtmdbdatprev:
                        # This is a newer date, so we process only once a day
                        strcurrentprocess = f"{intindex}: refreshing lists"
                        strsql = ""
                        strsql += "SELECT ID_LIST AS id, NAME FROM T_WC_TMDB_LIST "
                elif intindex == 14:
                    # Deleted movies
                    strcurrentprocess = f"{intindex}: processing deleted movies"
                    strsql = ""
                    strsql += "SELECT ID_MOVIE as id "
                    strsql += "FROM T_WC_TMDB_MOVIE "
                    strsql += "WHERE T_WC_TMDB_MOVIE.ID_MOVIE NOT IN ( SELECT id AS ID_MOVIE FROM T_WC_TMDB_MOVIE_ID_IMPORT ) "
                    # Processing only non adult movies because the ID import file contains only non adult records
                    strsql += "AND T_WC_TMDB_MOVIE.ADULT = 0 "
                    strsql += "ORDER BY ID_MOVIE "
                elif intindex == 15:
                    # Deleted persons
                    strcurrentprocess = f"{intindex}: processing deleted persons"
                    strsql = ""
                    strsql += "SELECT ID_PERSON as id "
                    strsql += "FROM T_WC_TMDB_PERSON "
                    strsql += "WHERE T_WC_TMDB_PERSON.ID_PERSON NOT IN ( SELECT id AS ID_PERSON FROM T_WC_TMDB_PERSON_ID_IMPORT ) "
                    # Processing only non adult persons because the ID import file contains only non adult records
                    strsql += "AND T_WC_TMDB_PERSON.ADULT = 0 "
                    strsql += "ORDER BY ID_PERSON "
                elif intindex == 16:
                    # Deleted series
                    if strdattodayminus1 > strtmdbdatprev:
                        # This is a newer date, so we process only once a day
                        strcurrentprocess = f"{intindex}: processing deleted series"
                        strsql = ""
                        strsql += "SELECT ID_SERIE as id "
                        strsql += "FROM T_WC_TMDB_SERIE "
                        strsql += "WHERE T_WC_TMDB_SERIE.ID_SERIE NOT IN ( SELECT id AS ID_SERIE FROM T_WC_TMDB_TV_SERIE_ID_IMPORT ) "
                        #strsql += "AND T_WC_TMDB_SERIE.ADULT = 0 "
                        strsql += "ORDER BY ID_SERIE "
                        #strsql += "LIMIT 1 "
                elif intindex == 17:
                    # New companies
                    strcurrentprocess = f"{intindex}: processing new companies from TMDb ID files"
                    strsql = ""
                    strsql += "SELECT id FROM T_WC_TMDB_PRODUCTION_COMPANY_ID_IMPORT "
                    strsql += "WHERE id NOT IN (SELECT ID_COMPANY FROM T_WC_TMDB_COMPANY WHERE DELETED = 0) "
                    #strsql += "AND id = 1399 "
                    strsql += "ORDER BY id ASC "
                    strsql += "LIMIT 20000 "
                elif intindex == 18:
                    # New networks
                    strcurrentprocess = f"{intindex}: processing new networks from TMDb ID files"
                    strsql = ""
                    strsql += "SELECT id FROM T_WC_TMDB_TV_NETWORK_ID_IMPORT "
                    strsql += "WHERE id NOT IN (SELECT ID_NETWORK FROM T_WC_TMDB_NETWORK WHERE DELETED = 0) "
                    strsql += "ORDER BY id ASC "
                    strsql += "LIMIT 20000 "
                elif intindex == 31:
                    strcurrentprocess = f"{intindex}: processing persons found in movie credits but with no person record"
                    strsql = ""
                    strsql += "SELECT DISTINCT ID_PERSON AS id "
                    strsql += "FROM T_WC_TMDB_PERSON_MOVIE "
                    strsql += "WHERE ID_PERSON NOT IN (SELECT ID_PERSON FROM T_WC_TMDB_PERSON) "
                    strsql += "ORDER BY ID_PERSON "
                elif intindex == 32:
                    strcurrentprocess = f"{intindex}: processing movies found in movie credits but with no movie record"
                    strsql = ""
                    strsql += "SELECT DISTINCT ID_MOVIE AS id "
                    strsql += "FROM T_WC_TMDB_PERSON_MOVIE "
                    strsql += "WHERE ID_MOVIE NOT IN (SELECT ID_MOVIE FROM T_WC_TMDB_MOVIE) "
                    strsql += "ORDER BY ID_MOVIE "
                elif intindex == 33:
                    strcurrentprocess = f"{intindex}: processing series found in serie credits but with no serie record"
                    strsql = ""
                    strsql += "SELECT DISTINCT ID_SERIE AS id "
                    strsql += "FROM T_WC_TMDB_PERSON_SERIE "
                    strsql += "WHERE ID_SERIE NOT IN (SELECT ID_SERIE FROM T_WC_TMDB_SERIE) "
                    strsql += "ORDER BY ID_SERIE "
                
                if strsql != "":
                    print(strcurrentprocess)
                    cp.f_setservervariable("strtmdbcrawlercurrentprocess",strcurrentprocess,"Current process in the TMDb API crawler",0)
                    print(strsql)
                    lngcount = 0
                    strdescvarname = strdesc.replace(" ","")
                    print("strdescvarname", strdescvarname)
                    #cp.f_setservervariable("strtmdbcrawlercurrentsql",strsql,"Current SQL query in the TMDb API crawler",0)
                    cursor.execute(strsql)
                    lngrowcount = cursor.rowcount
                    print(f"{lngrowcount} lines")
                    # Fetching all rows from the last executed statement
                    results = cursor.fetchall()
                    # Iterating through the results and printing
                    for row in results:
                        # print("------------------------------------------")
                        lngid = row['id']
                        print(f"{strdesc} id: {lngid}")
                        if intindex == 1:
                            # New collections
                            cp.f_tmdbcollectiontosql(lngid)
                            cp.f_tmdbcollectionlangtosql(lngid,'fr')
                            #cp.f_tmdbcollectioncreditstosql(lngid)
                            cp.f_tmdbcollectionsetcreditscompleted(lngid)
                            cp.f_tmdbcollectionimagestosql(lngid)
                        elif intindex == 2:
                            # New movies
                            cp.f_tmdbmovietosql(lngid)
                            cp.f_tmdbmovielangtosql(lngid,'fr')
                            cp.f_tmdbmoviesetcreditscompleted(lngid)
                            cp.f_tmdbmoviekeywordstosql(lngid)
                            cp.f_tmdbmoviesetkeywordscompleted(lngid)
                            cp.f_tmdbmovieimagestosql(lngid)
                        elif intindex == 3:
                            cp.f_tmdbpersontosql(lngid)
                            cp.f_tmdbpersonsetcreditscompleted(lngid)
                            cp.f_tmdbpersonimagestosql(lngid)
                        elif intindex == 4:
                            # New series
                            #print("New series")
                            cp.f_tmdbserietosql(lngid)
                            cp.f_tmdbserielangtosql(lngid,'fr')
                            cp.f_tmdbseriesetcreditscompleted(lngid)
                            cp.f_tmdbseriekeywordstosql(lngid)
                            cp.f_tmdbseriesetkeywordscompleted(lngid)
                            cp.f_tmdbserieimagestosql(lngid)
                        elif intindex == 7:
                            cp.f_tmdbmoviekeywordstosql(lngid)
                            cp.f_tmdbmoviesetkeywordscompleted(lngid)
                        elif intindex == 8:
                            cp.f_tmdbpersontosql(lngid)
                            cp.f_tmdbpersonsetcreditscompleted(lngid)
                            cp.f_tmdbpersonimagestosql(lngid)
                        elif intindex == 9:
                            cp.f_tmdbmovielangtosql(lngid,'fr')
                        elif intindex == 10:
                            cp.f_tmdbcollectionlangtosql(lngid,'fr')
                        elif intindex == 11:
                            # Refreshing movies
                            cp.f_tmdbmovietosqleverything(lngid)
                        elif intindex == 22:
                            # Refreshing movies
                            cp.f_tmdbmovietosql(lngid)
                            cp.f_tmdbmovielangtosql(lngid,'fr')
                            cp.f_tmdbmoviesetcreditscompleted(lngid)
                            cp.f_tmdbmoviekeywordstosql(lngid)
                            cp.f_tmdbmoviesetkeywordscompleted(lngid)
                        elif intindex == 24:
                            # Refreshing persons
                            cp.f_tmdbpersontosql(lngid)
                            cp.f_tmdbpersonsetcreditscompleted(lngid)
                            cp.f_tmdbpersonimagestosql(lngid)
                        elif intindex == 23:
                            cp.f_tmdbmovietosqleverything(lngid)
                        elif intindex == 25:
                            # Refreshing collections
                            cp.f_tmdbcollectiontosql(lngid)
                            cp.f_tmdbcollectionlangtosql(lngid,'fr')
                            #cp.f_tmdbcollectioncreditstosql(lngid)
                            cp.f_tmdbcollectionsetcreditscompleted(lngid)
                            cp.f_tmdbcollectionimagestosql(lngid)
                        elif intindex == 26:
                            # Refreshing companies
                            cp.f_tmdbcompanytosql(lngid)
                            cp.f_tmdbcompanysetcreditscompleted(lngid)
                            cp.f_tmdbcompanyimagestosql(lngid)
                        elif intindex == 27:
                            # Refreshing networks
                            cp.f_tmdbnetworktosql(lngid)
                            cp.f_tmdbnetworksetcreditscompleted(lngid)
                            cp.f_tmdbnetworkimagestosql(lngid)
                        elif intindex == 12:
                            # New keywords
                            strname = row['name']
                            strsqlinsert = "INSERT INTO T_WC_TMDB_KEYWORD_ID_IMPORT_LANG (id, name, LANG) VALUES (" + str(lngid) + ", '" + strname.replace("\\", "\\\\").replace("'", "\\'") + "', 'fr') "
                            cursor3.execute(strsqlinsert)
                            cp.connectioncp.commit()
                        elif intindex == 13:
                            # Refresh lists
                            strname = row['NAME']
                            cp.f_tmdblisttosql(lngid)
                            cp.f_tmdblistsetcreditscompleted(lngid)
                        elif intindex == 14:
                            # Deleted movies
                            if not cp.f_tmdbmovieexist(lngid):
                                # Delete this movie in the MySQL database because it does not exist anymore in the TMDb database
                                cp.f_tmdbmoviedelete(lngid)
                        elif intindex == 15:
                            # Deleted persons
                            if not cp.f_tmdbpersonexist(lngid):
                                # Delete this person in the MySQL database because it does not exist anymore in the TMDb database
                                cp.f_tmdbpersondelete(lngid)
                        elif intindex == 16:
                            # Deleted series
                            if not cp.f_tmdbserieexist(lngid):
                                # Delete this serie in the MySQL database because it does not exist anymore in the TMDb database
                                cp.f_tmdbseriedelete(lngid)
                        elif intindex == 17:
                            # New companies
                            cp.f_tmdbcompanytosql(lngid)
                            cp.f_tmdbcompanysetcreditscompleted(lngid)
                            cp.f_tmdbcompanyimagestosql(lngid)
                        elif intindex == 18:
                            # New networks
                            cp.f_tmdbnetworktosql(lngid)
                            cp.f_tmdbnetworksetcreditscompleted(lngid)
                            cp.f_tmdbnetworkimagestosql(lngid)
                        elif intindex == 31:
                            # Missing persons
                            cp.f_tmdbpersontosql(lngid)
                            cp.f_tmdbpersonsetcreditscompleted(lngid)
                            cp.f_tmdbpersonimagestosql(lngid)
                        elif intindex == 32:
                            # Missing movies
                            cp.f_tmdbmovietosql(lngid)
                            cp.f_tmdbmovielangtosql(lngid,'fr')
                            # When everything is loaded for the current movie, we set the TIM_CREDITS_COMPLETED value
                            cp.f_tmdbmoviesetcreditscompleted(lngid)
                            cp.f_tmdbmoviekeywordstosql(lngid)
                            cp.f_tmdbmoviesetkeywordscompleted(lngid)
                        elif intindex == 33:
                            # Missing series
                            cp.f_tmdbserietosql(lngid)
                            cp.f_tmdbserielangtosql(lngid,'fr')
                            cp.f_tmdbseriesetcreditscompleted(lngid)
                            cp.f_tmdbseriekeywordstosql(lngid)
                            cp.f_tmdbseriesetkeywordscompleted(lngid)
                            cp.f_tmdbserieimagestosql(lngid)
                        lngcount += 1
                        cp.f_setservervariable("strtmdbcrawlerprocess"+str(intindex)+strdescvarname+"count",str(lngcount),"Count of rows processed for process "+str(intindex)+" : "+strdesc+"",0)
                        strnow = datetime.now(cp.paris_tz).strftime("%Y-%m-%d %H:%M:%S")
                        cp.f_setservervariable("strtmdbcrawlerdatetime",strnow,"Date and time of the last crawled record using the TMDb API",0)
                print("------------------------------------------")
            strsql = ""
            
            # Now updating changed contents
            strnowdate = datetime.now(cp.paris_tz).strftime("%Y-%m-%d")
            arrtmdbchanges = {51: 'movie', 52: 'person', 53: 'serie'}
            #arrtmdbchanges = {53: 'serie'}
            #arrtmdbchanges = {51: 'movie', 52:'person'}
            #arrtmdbchanges = {0: 'nothing'}
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
                strcurrentprocess = f"{inttmdbchanges}: processing " + str(inttmdbchanges) + " : " + strtmdbchanges + " changes from the TMDb API"
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
                    # TV changes
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
                                    #if not intadult:
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
                                                # Not already retrieved so we have to update it from the TMDb API 
                                                #print("Not already retrieved so we have to update it from the TMDb API")
                                                print(f"{strtmdbchanges} changed id: {lngid}")
                                                cp.f_tmdbmovietosqleverything(lngid)
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
                                                # Not already retrieved so we have to update it from the TMDb API 
                                                #print("Not already retrieved so we have to update it from the TMDb API")
                                                print(f"{strtmdbchanges} changed id: {lngid}")
                                                cp.f_tmdbpersontosql(lngid)
                                                cp.f_tmdbpersonsetcreditscompleted(lngid)
                                                cp.f_tmdbpersonimagestosql(lngid)
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
                                                # Not already retrieved so we have to update it from the TMDb API 
                                                #print("Not already retrieved so we have to update it from the TMDb API")
                                                print(f"{strtmdbchanges} changed id: {lngid}")
                                                cp.f_tmdbserietosql(lngid)
                                                cp.f_tmdbserielangtosql(lngid,'fr')
                                                cp.f_tmdbseriesetcreditscompleted(lngid)
                                                cp.f_tmdbseriekeywordstosql(lngid)
                                                cp.f_tmdbseriesetkeywordscompleted(lngid)
                                                cp.f_tmdbserieimagestosql(lngid)
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
            
            strcurrentprocess = ""
            cp.f_setservervariable("strtmdbcrawlercurrentprocess",strcurrentprocess,"Current process in the TMDb API crawler",0)
            strnow = datetime.now(cp.paris_tz).strftime("%Y-%m-%d %H:%M:%S")
            cp.f_setservervariable("strtmdbcrawlerenddatetime",strnow,"Date and time of the TMDb API crawler ending",0)
    print("Process completed")
except pymysql.MySQLError as e:
    print(f"❌ MySQL Error: {e}")
    cp.connectioncp.rollback()
