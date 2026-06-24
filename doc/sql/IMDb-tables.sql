/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_WC_IMDB_MOVIE_AKA_IMPORT` (
  `titleId` varchar(20) NOT NULL,
  `ordering` int(5) NOT NULL,
  `title` varchar(900) DEFAULT NULL,
  `region` varchar(20) DEFAULT NULL,
  `language` varchar(20) DEFAULT NULL,
  `types` varchar(50) DEFAULT NULL,
  `attributes` varchar(200) DEFAULT NULL,
  `isOriginalTitle` int(5) DEFAULT NULL,
  PRIMARY KEY (`titleId`,`ordering`),
  KEY `title` (`title`(768)),
  KEY `region` (`region`),
  KEY `language` (`language`),
  KEY `types` (`types`),
  KEY `attributes` (`attributes`),
  KEY `isOriginalTitle` (`isOriginalTitle`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_WC_IMDB_MOVIE_BASIC_IMPORT` (
  `tconst` varchar(20) NOT NULL,
  `titleType` varchar(20) DEFAULT NULL,
  `primaryTitle` varchar(800) DEFAULT NULL,
  `originalTitle` varchar(800) DEFAULT NULL,
  `isAdult` int(5) DEFAULT NULL,
  `startYear` varchar(4) DEFAULT NULL,
  `endYear` varchar(4) DEFAULT NULL,
  `runtimeMinutes` varchar(10) DEFAULT NULL,
  `genres` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`tconst`),
  KEY `titleType` (`titleType`),
  KEY `primaryTitle` (`primaryTitle`(768)),
  KEY `originalTitle` (`originalTitle`(768)),
  KEY `isAdult` (`isAdult`),
  KEY `startYear` (`startYear`),
  KEY `endYear` (`endYear`),
  KEY `runtimeMinutes` (`runtimeMinutes`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_WC_IMDB_MOVIE_PRINCIPAL_IMPORT` (
  `tconst` varchar(20) NOT NULL,
  `ordering` int(5) NOT NULL,
  `nconst` varchar(20) DEFAULT NULL,
  `category` varchar(100) DEFAULT NULL,
  `job` varchar(500) DEFAULT NULL,
  `characters` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`tconst`,`ordering`),
  KEY `nconst` (`nconst`),
  KEY `category` (`category`),
  KEY `job` (`job`),
  KEY `characters` (`characters`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_WC_IMDB_MOVIE_RATING_IMPORT` (
  `tconst` varchar(20) NOT NULL,
  `averageRating` double DEFAULT NULL,
  `numVotes` int(11) NOT NULL,
  PRIMARY KEY (`tconst`),
  KEY `averageRating` (`averageRating`),
  KEY `numVotes` (`numVotes`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_WC_IMDB_PERSON_BASIC_IMPORT` (
  `nconst` varchar(20) NOT NULL,
  `primaryName` varchar(200) DEFAULT NULL,
  `birthYear` int(5) DEFAULT NULL,
  `deathYear` int(5) DEFAULT NULL,
  `primaryProfession` varchar(500) DEFAULT NULL,
  `knownForTitles` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`nconst`),
  KEY `primaryName` (`primaryName`),
  KEY `birthYear` (`birthYear`),
  KEY `deathYear` (`deathYear`),
  KEY `primaryProfession` (`primaryProfession`),
  KEY `knownForTitles` (`knownForTitles`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_WC_IMDB_PERSON_MOVIE_IMPORT` (
  `tconst` varchar(20) NOT NULL,
  `directors` mediumtext DEFAULT NULL,
  `writers` mediumtext DEFAULT NULL,
  PRIMARY KEY (`tconst`),
  KEY `directors` (`directors`(768)),
  KEY `writers` (`writers`(768))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `T_WC_IMDB_SERIE_EPISODE_IMPORT` (
  `tconst` varchar(20) NOT NULL,
  `parentTconst` varchar(20) NOT NULL,
  `seasonNumber` int(5) DEFAULT NULL,
  `episodeNumber` int(5) DEFAULT NULL,
  PRIMARY KEY (`tconst`),
  KEY `parentTconst` (`parentTconst`),
  KEY `seasonNumber` (`seasonNumber`),
  KEY `episodeNumber` (`episodeNumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
