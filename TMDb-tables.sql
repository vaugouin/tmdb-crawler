-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : mariadb
-- Généré le : mer. 14 jan. 2026 à 09:16
-- Version du serveur : 11.2.3-MariaDB
-- Version de PHP : 8.2.16

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `vaugouindb`
--

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_COLLECTION`
--

CREATE TABLE `T_WC_TMDB_COLLECTION` (
  `ID_COLLECTION` int(11) NOT NULL,
  `NAME` varchar(250) DEFAULT NULL,
  `OVERVIEW` mediumtext DEFAULT NULL,
  `POSTER_PATH` varchar(200) DEFAULT NULL,
  `BACKDROP_PATH` varchar(200) DEFAULT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL,
  `TIM_CREDITS_COMPLETED` datetime DEFAULT NULL,
  `TIM_CREDITS_DOWNLOADED` datetime DEFAULT NULL,
  `TIM_IMAGES_COMPLETED` datetime DEFAULT NULL,
  `USED_FOR_SIMILARITY` int(5) DEFAULT NULL,
  `ID_WIKIDATA` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_COLLECTION_ID_IMPORT`
--

CREATE TABLE `T_WC_TMDB_COLLECTION_ID_IMPORT` (
  `id` int(11) NOT NULL,
  `name` varchar(250) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_COLLECTION_IMAGE`
--

CREATE TABLE `T_WC_TMDB_COLLECTION_IMAGE` (
  `ID_ROW` int(11) NOT NULL,
  `ID_COLLECTION` int(11) NOT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL,
  `TYPE_IMAGE` varchar(20) DEFAULT NULL,
  `LANG` varchar(2) DEFAULT NULL,
  `IMAGE_PATH` varchar(200) DEFAULT NULL,
  `ASPECT_RATIO` double DEFAULT NULL,
  `WIDTH` int(5) DEFAULT NULL,
  `HEIGHT` int(5) DEFAULT NULL,
  `VOTE_AVERAGE` double DEFAULT NULL,
  `VOTE_COUNT` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_COLLECTION_LANG`
--

CREATE TABLE `T_WC_TMDB_COLLECTION_LANG` (
  `ID_COLLECTION` int(11) NOT NULL,
  `LANG` varchar(10) DEFAULT NULL,
  `NAME` varchar(250) DEFAULT NULL,
  `OVERVIEW` mediumtext DEFAULT NULL,
  `POSTER_PATH` varchar(200) DEFAULT NULL,
  `BACKDROP_PATH` varchar(200) DEFAULT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_COMPANY`
--

CREATE TABLE `T_WC_TMDB_COMPANY` (
  `ID_COMPANY` int(11) NOT NULL,
  `NAME` varchar(250) DEFAULT NULL,
  `DESCRIPTION` mediumtext DEFAULT NULL,
  `LOGO_PATH` varchar(200) DEFAULT NULL,
  `HOMEPAGE_URL` varchar(500) DEFAULT NULL,
  `HEADQUARTERS` varchar(200) DEFAULT NULL,
  `ORIGIN_COUNTRY` varchar(2) DEFAULT NULL,
  `ID_PARENT` int(11) DEFAULT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL,
  `TIM_CREDITS_COMPLETED` datetime DEFAULT NULL,
  `TIM_CREDITS_DOWNLOADED` datetime DEFAULT NULL,
  `TIM_IMAGES_COMPLETED` datetime DEFAULT NULL,
  `USED_FOR_SIMILARITY` int(5) DEFAULT NULL,
  `MOVIE_COUNT` int(11) DEFAULT NULL,
  `SERIE_COUNT` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_COMPANY_IMAGE`
--

CREATE TABLE `T_WC_TMDB_COMPANY_IMAGE` (
  `ID_ROW` int(11) NOT NULL,
  `ID_COMPANY` int(11) NOT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL,
  `TYPE_IMAGE` varchar(20) DEFAULT NULL,
  `LANG` varchar(2) DEFAULT NULL,
  `IMAGE_PATH` varchar(200) DEFAULT NULL,
  `ASPECT_RATIO` double DEFAULT NULL,
  `WIDTH` int(5) DEFAULT NULL,
  `HEIGHT` int(5) DEFAULT NULL,
  `VOTE_AVERAGE` double DEFAULT NULL,
  `VOTE_COUNT` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_GENRE`
--

CREATE TABLE `T_WC_TMDB_GENRE` (
  `id` int(11) NOT NULL,
  `name` varchar(250) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_GENRE_LANG`
--

CREATE TABLE `T_WC_TMDB_GENRE_LANG` (
  `ID_ROW` int(11) NOT NULL,
  `id` int(11) NOT NULL,
  `LANG` varchar(10) DEFAULT NULL,
  `name` varchar(250) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_KEYWORD`
--

CREATE TABLE `T_WC_TMDB_KEYWORD` (
  `ID_KEYWORD` int(11) NOT NULL,
  `NAME` varchar(250) DEFAULT NULL,
  `USE_FOR_TAGGING` int(5) DEFAULT NULL,
  `USED_FOR_SIMILARITY` int(5) DEFAULT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL,
  `TIM_CREDITS_COMPLETED` datetime DEFAULT NULL,
  `TIM_CREDITS_DOWNLOADED` datetime DEFAULT NULL,
  `MOVIE_COUNT` int(11) DEFAULT NULL,
  `SERIE_COUNT` int(11) DEFAULT NULL,
  `IS_EMPTY` int(5) DEFAULT NULL,
  `IS_PERSON` int(5) DEFAULT NULL,
  `NAME_WORD_COUNT` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_KEYWORD_ID_IMPORT`
--

CREATE TABLE `T_WC_TMDB_KEYWORD_ID_IMPORT` (
  `id` int(11) NOT NULL,
  `name` varchar(250) DEFAULT NULL,
  `USED_FOR_SIMILARITY` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_KEYWORD_ID_IMPORT_LANG`
--

CREATE TABLE `T_WC_TMDB_KEYWORD_ID_IMPORT_LANG` (
  `ID_ROW` int(11) NOT NULL,
  `id` int(11) DEFAULT NULL,
  `LANG` varchar(10) DEFAULT NULL,
  `name` varchar(250) DEFAULT NULL,
  `USE_FOR_TAGGING` int(5) DEFAULT NULL,
  `USED_FOR_SIMILARITY` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_KEYWORD_LANG`
--

CREATE TABLE `T_WC_TMDB_KEYWORD_LANG` (
  `ID_ROW` int(11) NOT NULL,
  `ID_KEYWORD` int(11) DEFAULT NULL,
  `LANG` varchar(10) DEFAULT NULL,
  `NAME` varchar(250) DEFAULT NULL,
  `USE_FOR_TAGGING` int(5) DEFAULT NULL,
  `USED_FOR_SIMILARITY` int(5) DEFAULT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` int(5) DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_LANG_LANG`
--

CREATE TABLE `T_WC_TMDB_LANG_LANG` (
  `LANG` varchar(10) DEFAULT NULL,
  `LANG_DISPLAY` varchar(10) DEFAULT NULL,
  `DESCRIPTION` varchar(100) DEFAULT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_LIST`
--

CREATE TABLE `T_WC_TMDB_LIST` (
  `ID_LIST` int(11) NOT NULL,
  `NAME` varchar(500) DEFAULT NULL,
  `DESCRIPTION` mediumtext DEFAULT NULL,
  `POSTER_PATH` varchar(200) DEFAULT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL,
  `TIM_CREDITS_COMPLETED` datetime DEFAULT NULL,
  `TIM_CREDITS_DOWNLOADED` datetime DEFAULT NULL,
  `USE_FOR_TAGGING` int(5) DEFAULT NULL,
  `SHORT_NAME` varchar(100) DEFAULT NULL,
  `USED_FOR_SIMILARITY` int(5) DEFAULT NULL,
  `CREATED_BY` varchar(200) DEFAULT NULL,
  `ID_LIST_TYPE` int(5) DEFAULT NULL,
  `ID_PROPERTY` varchar(50) DEFAULT NULL,
  `ID_ITEM` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_LIST_LANG`
--

CREATE TABLE `T_WC_TMDB_LIST_LANG` (
  `ID_ROW` int(11) NOT NULL,
  `ID_LIST` int(11) DEFAULT NULL,
  `LANG` varchar(10) DEFAULT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL,
  `SHORT_NAME` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_LIST_TYPE`
--

CREATE TABLE `T_WC_TMDB_LIST_TYPE` (
  `ID_LIST_TYPE` int(5) NOT NULL,
  `DESCRIPTION` varchar(50) DEFAULT NULL,
  `AUTO_UPDATE` int(5) DEFAULT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `LONG_DESC` mediumtext DEFAULT NULL,
  `MOT_CLE` mediumtext DEFAULT NULL,
  `MOT_CLE_AUTO` mediumtext DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_MOVIE`
--

CREATE TABLE `T_WC_TMDB_MOVIE` (
  `ID_MOVIE` int(11) NOT NULL,
  `TITLE` varchar(250) DEFAULT NULL,
  `DAT_RELEASE` date DEFAULT NULL,
  `RELEASE_YEAR` int(5) DEFAULT NULL,
  `RELEASE_MONTH` int(5) DEFAULT NULL,
  `RELEASE_DAY` int(5) DEFAULT NULL,
  `ID_IMDB` varchar(20) DEFAULT NULL,
  `ID_WIKIDATA` varchar(50) DEFAULT NULL,
  `OVERVIEW` mediumtext DEFAULT NULL,
  `POSTER_PATH` varchar(200) DEFAULT NULL,
  `HOMEPAGE_URL` varchar(500) DEFAULT NULL,
  `ORIGINAL_TITLE` varchar(250) DEFAULT NULL,
  `POPULARITY` double DEFAULT NULL,
  `ORIGINAL_LANGUAGE` varchar(2) DEFAULT NULL,
  `ADULT` int(5) DEFAULT NULL,
  `STATUS` varchar(100) DEFAULT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL,
  `GENRES` varchar(200) DEFAULT NULL,
  `ID_COLLECTION` int(11) DEFAULT NULL,
  `BUDGET` double DEFAULT NULL,
  `RUNTIME` int(11) DEFAULT NULL,
  `BACKDROP_PATH` varchar(200) DEFAULT NULL,
  `REVENUE` double DEFAULT NULL,
  `TAGLINE` mediumtext DEFAULT NULL,
  `VIDEO` int(5) DEFAULT NULL,
  `VOTE_AVERAGE` double DEFAULT NULL,
  `VOTE_COUNT` int(11) DEFAULT NULL,
  `COUNTRIES` varchar(100) DEFAULT NULL,
  `SPOKEN_LANGUAGES` varchar(100) DEFAULT NULL,
  `TIM_CREDITS_COMPLETED` datetime DEFAULT NULL,
  `TIM_KEYWORDS_COMPLETED` datetime DEFAULT NULL,
  `TIM_WIKIDATA_COMPLETED` datetime DEFAULT NULL,
  `TIM_WIKIPEDIA_COMPLETED` datetime DEFAULT NULL,
  `TIM_IMAGES_COMPLETED` datetime DEFAULT NULL,
  `TIM_VIDEOS_COMPLETED` datetime DEFAULT NULL,
  `WIKIPEDIA_FORMAT_LINE` mediumtext DEFAULT NULL,
  `DAT_WIKIPEDIA_FORMAT_LINE` datetime DEFAULT NULL,
  `IS_COLOR` int(11) DEFAULT NULL,
  `IS_BLACK_AND_WHITE` int(11) DEFAULT NULL,
  `IS_SILENT` int(11) DEFAULT NULL,
  `IS_3D` int(11) DEFAULT NULL,
  `COLOR_TECHNOLOGY` varchar(100) DEFAULT NULL,
  `FILM_TECHNOLOGY` mediumtext DEFAULT NULL,
  `ASPECT_RATIO` varchar(20) DEFAULT NULL,
  `FILM_FORMAT` varchar(50) DEFAULT NULL,
  `SOUND_SYSTEM` mediumtext DEFAULT NULL,
  `NUM_AUDIO_TRACKS` int(11) DEFAULT NULL,
  `IS_VALID_FORMAT` int(11) DEFAULT NULL,
  `IS_MOVIE` int(5) DEFAULT NULL,
  `IS_DOCUMENTARY` int(5) DEFAULT NULL,
  `IS_SHORT_FILM` int(5) DEFAULT NULL,
  `SOUND_TECHNOLOGY` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_MOVIE_COMPANY`
--

CREATE TABLE `T_WC_TMDB_MOVIE_COMPANY` (
  `ID_ROW` int(11) NOT NULL,
  `ID_MOVIE` int(11) NOT NULL,
  `ID_COMPANY` int(11) NOT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_MOVIE_GENRE`
--

CREATE TABLE `T_WC_TMDB_MOVIE_GENRE` (
  `ID_ROW` int(11) NOT NULL,
  `ID_MOVIE` int(11) NOT NULL,
  `ID_GENRE` int(11) NOT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_MOVIE_ID_IMPORT`
--

CREATE TABLE `T_WC_TMDB_MOVIE_ID_IMPORT` (
  `adult` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL,
  `original_title` varchar(250) DEFAULT NULL,
  `popularity` double DEFAULT NULL,
  `video` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_MOVIE_IMAGE`
--

CREATE TABLE `T_WC_TMDB_MOVIE_IMAGE` (
  `ID_ROW` int(11) NOT NULL,
  `ID_MOVIE` int(11) NOT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL,
  `TYPE_IMAGE` varchar(20) DEFAULT NULL,
  `LANG` varchar(2) DEFAULT NULL,
  `IMAGE_PATH` varchar(200) DEFAULT NULL,
  `ASPECT_RATIO` double DEFAULT NULL,
  `WIDTH` int(5) DEFAULT NULL,
  `HEIGHT` int(5) DEFAULT NULL,
  `VOTE_AVERAGE` double DEFAULT NULL,
  `VOTE_COUNT` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_MOVIE_KEYWORD`
--

CREATE TABLE `T_WC_TMDB_MOVIE_KEYWORD` (
  `ID_ROW` int(11) NOT NULL,
  `ID_MOVIE` int(11) NOT NULL,
  `ID_KEYWORD` int(11) NOT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_MOVIE_LANG`
--

CREATE TABLE `T_WC_TMDB_MOVIE_LANG` (
  `ID_ROW` int(11) NOT NULL,
  `ID_MOVIE` int(11) NOT NULL,
  `LANG` varchar(10) DEFAULT NULL,
  `TITLE` varchar(250) DEFAULT NULL,
  `OVERVIEW` mediumtext DEFAULT NULL,
  `POSTER_PATH` varchar(200) DEFAULT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL,
  `BACKDROP_PATH` varchar(200) DEFAULT NULL,
  `TAGLINE` mediumtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_MOVIE_LANG_META`
--

CREATE TABLE `T_WC_TMDB_MOVIE_LANG_META` (
  `ID_ROW` int(11) NOT NULL,
  `ID_MOVIE` int(11) NOT NULL,
  `LANG` varchar(10) DEFAULT NULL,
  `YEAR_RELEASE` varchar(4) DEFAULT NULL,
  `ORIGINAL_LANGUAGE` varchar(100) DEFAULT NULL,
  `GENRES` mediumtext DEFAULT NULL,
  `KEYWORDS` mediumtext DEFAULT NULL,
  `COLLECTION` varchar(250) DEFAULT NULL,
  `LISTS` mediumtext DEFAULT NULL,
  `DIRECTORS` mediumtext DEFAULT NULL,
  `WRITERS` mediumtext DEFAULT NULL,
  `PRODUCERS` mediumtext DEFAULT NULL,
  `EDITORS` mediumtext DEFAULT NULL,
  `ART` mediumtext DEFAULT NULL,
  `CAMERA` mediumtext DEFAULT NULL,
  `LIGHTNING` mediumtext DEFAULT NULL,
  `SOUND` mediumtext DEFAULT NULL,
  `COSTUME_MAKEUP` mediumtext DEFAULT NULL,
  `VISUAL_EFFECTS` mediumtext DEFAULT NULL,
  `CAST_TOP` mediumtext DEFAULT NULL,
  `CREW_TOP` mediumtext DEFAULT NULL,
  `TAGS` mediumtext DEFAULT NULL,
  `OVERVIEW_LEMMA` mediumtext DEFAULT NULL,
  `KEYWORDS_LEMMA` mediumtext DEFAULT NULL,
  `LISTS_LEMMA` mediumtext DEFAULT NULL,
  `IMDB_RATING` double DEFAULT NULL,
  `IMDB_RATING_ADJUSTED` double DEFAULT NULL,
  `TEXT_DOC` mediumtext DEFAULT NULL,
  `TEXT_SBERT` mediumtext DEFAULT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_MOVIE_LEMME`
--

CREATE TABLE `T_WC_TMDB_MOVIE_LEMME` (
  `ID_ROW` int(11) NOT NULL,
  `ID_MOVIE` int(11) NOT NULL,
  `ID_LEMME` int(11) NOT NULL,
  `START_CHAR` int(11) NOT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_MOVIE_LIST`
--

CREATE TABLE `T_WC_TMDB_MOVIE_LIST` (
  `ID_TMDB_MOVIE_LIST` int(11) NOT NULL,
  `ID_LIST` int(11) NOT NULL,
  `ID_MOVIE` int(11) NOT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_MOVIE_PRODUCTION_COUNTRY`
--

CREATE TABLE `T_WC_TMDB_MOVIE_PRODUCTION_COUNTRY` (
  `ID_ROW` int(11) NOT NULL,
  `ID_MOVIE` int(11) NOT NULL,
  `COUNTRY_CODE` varchar(2) NOT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_MOVIE_SPOKEN_LANGUAGE`
--

CREATE TABLE `T_WC_TMDB_MOVIE_SPOKEN_LANGUAGE` (
  `ID_ROW` int(11) NOT NULL,
  `ID_MOVIE` int(11) NOT NULL,
  `SPOKEN_LANGUAGE` varchar(2) NOT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_MOVIE_TITLE`
--

CREATE TABLE `T_WC_TMDB_MOVIE_TITLE` (
  `ID_MOVIE_TITLE` int(11) NOT NULL,
  `ID_MOVIE` int(11) NOT NULL,
  `ISO_3166_1` varchar(3) DEFAULT NULL,
  `TITLE_TYPE` varchar(100) DEFAULT NULL,
  `TITLE` varchar(250) DEFAULT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_MOVIE_UPDATE`
--

CREATE TABLE `T_WC_TMDB_MOVIE_UPDATE` (
  `ID_MOVIE` int(11) NOT NULL,
  `ID_WIKIDATA` varchar(50) DEFAULT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_MOVIE_VIDEO`
--

CREATE TABLE `T_WC_TMDB_MOVIE_VIDEO` (
  `ID_ROW` int(11) NOT NULL,
  `ID_MOVIE` int(11) NOT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL,
  `LANG` varchar(2) DEFAULT NULL,
  `COUNTRY_CODE` varchar(2) DEFAULT NULL,
  `VIDEO_KEY` varchar(20) DEFAULT NULL,
  `VIDEO_NAME` varchar(200) DEFAULT NULL,
  `VIDEO_SITE` varchar(50) DEFAULT NULL,
  `VIDEO_TYPE` varchar(50) DEFAULT NULL,
  `QUALITY` int(5) DEFAULT NULL,
  `QUALITY_TEXT` varchar(20) DEFAULT NULL,
  `DAT_PUBLISHED` datetime DEFAULT NULL,
  `ID_CREDIT` varchar(50) DEFAULT NULL,
  `OFFICIAL` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_NETWORK`
--

CREATE TABLE `T_WC_TMDB_NETWORK` (
  `ID_NETWORK` int(11) NOT NULL,
  `NAME` varchar(250) DEFAULT NULL,
  `LOGO_PATH` varchar(200) DEFAULT NULL,
  `HOMEPAGE_URL` varchar(500) DEFAULT NULL,
  `HEADQUARTERS` varchar(200) DEFAULT NULL,
  `ORIGIN_COUNTRY` varchar(2) DEFAULT NULL,
  `ID_PARENT` int(11) DEFAULT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL,
  `TIM_CREDITS_COMPLETED` datetime DEFAULT NULL,
  `TIM_CREDITS_DOWNLOADED` datetime DEFAULT NULL,
  `TIM_IMAGES_COMPLETED` datetime DEFAULT NULL,
  `SERIE_COUNT` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_NETWORK_IMAGE`
--

CREATE TABLE `T_WC_TMDB_NETWORK_IMAGE` (
  `ID_ROW` int(11) NOT NULL,
  `ID_NETWORK` int(11) NOT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL,
  `TYPE_IMAGE` varchar(20) DEFAULT NULL,
  `LANG` varchar(2) DEFAULT NULL,
  `IMAGE_PATH` varchar(200) DEFAULT NULL,
  `ASPECT_RATIO` double DEFAULT NULL,
  `WIDTH` int(5) DEFAULT NULL,
  `HEIGHT` int(5) DEFAULT NULL,
  `VOTE_AVERAGE` double DEFAULT NULL,
  `VOTE_COUNT` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_PERSON`
--

CREATE TABLE `T_WC_TMDB_PERSON` (
  `ID_PERSON` int(11) NOT NULL,
  `NAME` varchar(200) DEFAULT NULL,
  `ID_IMDB` varchar(20) DEFAULT NULL,
  `ID_WIKIDATA` varchar(50) DEFAULT NULL,
  `BIOGRAPHY` mediumtext DEFAULT NULL,
  `BIRTHDAY` datetime DEFAULT NULL,
  `DEATHDAY` datetime DEFAULT NULL,
  `BIRTH_DAY` int(5) DEFAULT NULL,
  `BIRTH_MONTH` int(5) DEFAULT NULL,
  `BIRTH_YEAR` int(5) DEFAULT NULL,
  `DEATH_DAY` int(5) DEFAULT NULL,
  `DEATH_MONTH` int(5) DEFAULT NULL,
  `DEATH_YEAR` int(5) DEFAULT NULL,
  `GENDER` int(5) DEFAULT NULL,
  `PROFILE_PATH` varchar(200) DEFAULT NULL,
  `HOMEPAGE_URL` varchar(250) DEFAULT NULL,
  `PLACE_OF_BIRTH` varchar(200) DEFAULT NULL,
  `COUNTRY_OF_BIRTH_LONG` varchar(200) DEFAULT NULL,
  `COUNTRY_OF_BIRTH` varchar(10) DEFAULT NULL,
  `POPULARITY` double DEFAULT NULL,
  `KNOWN_FOR_DEPARTMENT` varchar(200) DEFAULT NULL,
  `ADULT` int(5) DEFAULT NULL,
  `ALSO_KNOWN_AS` mediumtext DEFAULT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL,
  `TIM_CREDITS_COMPLETED` datetime DEFAULT NULL,
  `TIM_CREDITS_DOWNLOADED` datetime DEFAULT NULL,
  `TIM_WIKIDATA_COMPLETED` datetime DEFAULT NULL,
  `TIM_IMAGES_COMPLETED` datetime DEFAULT NULL,
  `USED_FOR_SIMILARITY` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_PERSON_ID_IMPORT`
--

CREATE TABLE `T_WC_TMDB_PERSON_ID_IMPORT` (
  `id` int(11) NOT NULL,
  `name` varchar(200) DEFAULT NULL,
  `popularity` double DEFAULT NULL,
  `adult` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_PERSON_IMAGE`
--

CREATE TABLE `T_WC_TMDB_PERSON_IMAGE` (
  `ID_ROW` int(11) NOT NULL,
  `ID_PERSON` int(11) NOT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL,
  `TYPE_IMAGE` varchar(20) DEFAULT NULL,
  `LANG` varchar(2) DEFAULT NULL,
  `IMAGE_PATH` varchar(200) DEFAULT NULL,
  `ASPECT_RATIO` double DEFAULT NULL,
  `WIDTH` int(5) DEFAULT NULL,
  `HEIGHT` int(5) DEFAULT NULL,
  `VOTE_AVERAGE` double DEFAULT NULL,
  `VOTE_COUNT` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_PERSON_MOVIE`
--

CREATE TABLE `T_WC_TMDB_PERSON_MOVIE` (
  `ID_TMDB_PERSON_MOVIE` int(11) NOT NULL,
  `ID_PERSON` int(11) NOT NULL,
  `ID_MOVIE` int(11) NOT NULL,
  `ID_CREDIT` varchar(50) DEFAULT NULL,
  `CAST_CHARACTER` varchar(600) DEFAULT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL,
  `CREDIT_TYPE` varchar(10) DEFAULT NULL,
  `CREW_DEPARTMENT` varchar(200) DEFAULT NULL,
  `CREW_JOB` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_PERSON_SEARCH`
--

CREATE TABLE `T_WC_TMDB_PERSON_SEARCH` (
  `ID_ROW` int(11) NOT NULL,
  `ID_PERSON` int(11) DEFAULT NULL,
  `NAME` varchar(200) DEFAULT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_PERSON_SERIE`
--

CREATE TABLE `T_WC_TMDB_PERSON_SERIE` (
  `ID_TMDB_PERSON_SERIE` int(11) NOT NULL,
  `ID_PERSON` int(11) NOT NULL,
  `ID_SERIE` int(11) NOT NULL,
  `ID_CREDIT` varchar(50) DEFAULT NULL,
  `CAST_CHARACTER` varchar(600) DEFAULT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL,
  `CREDIT_TYPE` varchar(10) DEFAULT NULL,
  `CREW_DEPARTMENT` varchar(200) DEFAULT NULL,
  `CREW_JOB` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_PERSON_UPDATE`
--

CREATE TABLE `T_WC_TMDB_PERSON_UPDATE` (
  `ID_PERSON` int(11) NOT NULL,
  `ID_WIKIDATA` varchar(50) DEFAULT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_PRODUCTION_COMPANY_ID_IMPORT`
--

CREATE TABLE `T_WC_TMDB_PRODUCTION_COMPANY_ID_IMPORT` (
  `id` int(11) NOT NULL,
  `name` varchar(250) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_SERIE`
--

CREATE TABLE `T_WC_TMDB_SERIE` (
  `ID_SERIE` int(11) NOT NULL,
  `TITLE` varchar(250) DEFAULT NULL,
  `FIRST_AIR_YEAR` int(5) DEFAULT NULL,
  `FIRST_AIR_MONTH` int(5) DEFAULT NULL,
  `FIRST_AIR_DAY` int(5) DEFAULT NULL,
  `DAT_FIRST_AIR` date DEFAULT NULL,
  `LAST_AIR_YEAR` int(5) DEFAULT NULL,
  `LAST_AIR_MONTH` int(5) DEFAULT NULL,
  `LAST_AIR_DAY` int(5) DEFAULT NULL,
  `DAT_LAST_AIR` date DEFAULT NULL,
  `ID_IMDB` varchar(20) DEFAULT NULL,
  `ID_WIKIDATA` varchar(50) DEFAULT NULL,
  `OVERVIEW` mediumtext DEFAULT NULL,
  `POSTER_PATH` varchar(200) DEFAULT NULL,
  `HOMEPAGE_URL` varchar(500) DEFAULT NULL,
  `ORIGINAL_TITLE` varchar(250) DEFAULT NULL,
  `POPULARITY` double DEFAULT NULL,
  `ORIGINAL_LANGUAGE` varchar(2) DEFAULT NULL,
  `ADULT` int(5) DEFAULT NULL,
  `STATUS` varchar(100) DEFAULT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL,
  `GENRES` varchar(200) DEFAULT NULL,
  `BACKDROP_PATH` varchar(200) DEFAULT NULL,
  `TAGLINE` mediumtext DEFAULT NULL,
  `VOTE_AVERAGE` double DEFAULT NULL,
  `VOTE_COUNT` int(11) DEFAULT NULL,
  `TIM_CREDITS_COMPLETED` datetime DEFAULT NULL,
  `TIM_KEYWORDS_COMPLETED` datetime DEFAULT NULL,
  `TIM_WIKIDATA_COMPLETED` datetime DEFAULT NULL,
  `TIM_WIKIPEDIA_COMPLETED` datetime DEFAULT NULL,
  `TIM_IMAGES_COMPLETED` datetime DEFAULT NULL,
  `TIM_VIDEOS_COMPLETED` datetime DEFAULT NULL,
  `COUNTRIES` varchar(100) DEFAULT NULL,
  `SPOKEN_LANGUAGES` varchar(100) DEFAULT NULL,
  `NUMBER_OF_EPISODES` int(5) DEFAULT NULL,
  `NUMBER_OF_SEASONS` int(5) DEFAULT NULL,
  `SERIE_TYPE` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_SERIE_COMPANY`
--

CREATE TABLE `T_WC_TMDB_SERIE_COMPANY` (
  `ID_ROW` int(11) NOT NULL,
  `ID_SERIE` int(11) NOT NULL,
  `ID_COMPANY` int(11) NOT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_SERIE_GENRE`
--

CREATE TABLE `T_WC_TMDB_SERIE_GENRE` (
  `ID_ROW` int(11) NOT NULL,
  `ID_SERIE` int(11) NOT NULL,
  `ID_GENRE` int(11) NOT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_SERIE_IMAGE`
--

CREATE TABLE `T_WC_TMDB_SERIE_IMAGE` (
  `ID_ROW` int(11) NOT NULL,
  `ID_SERIE` int(11) NOT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL,
  `TYPE_IMAGE` varchar(20) DEFAULT NULL,
  `LANG` varchar(2) DEFAULT NULL,
  `IMAGE_PATH` varchar(200) DEFAULT NULL,
  `ASPECT_RATIO` double DEFAULT NULL,
  `WIDTH` int(5) DEFAULT NULL,
  `HEIGHT` int(5) DEFAULT NULL,
  `VOTE_AVERAGE` double DEFAULT NULL,
  `VOTE_COUNT` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_SERIE_KEYWORD`
--

CREATE TABLE `T_WC_TMDB_SERIE_KEYWORD` (
  `ID_ROW` int(11) NOT NULL,
  `ID_SERIE` int(11) NOT NULL,
  `ID_KEYWORD` int(11) NOT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_SERIE_LANG`
--

CREATE TABLE `T_WC_TMDB_SERIE_LANG` (
  `ID_ROW` int(11) NOT NULL,
  `ID_SERIE` int(11) NOT NULL,
  `LANG` varchar(10) DEFAULT NULL,
  `TITLE` varchar(250) DEFAULT NULL,
  `OVERVIEW` mediumtext DEFAULT NULL,
  `POSTER_PATH` varchar(200) DEFAULT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL,
  `BACKDROP_PATH` varchar(200) DEFAULT NULL,
  `TAGLINE` mediumtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_SERIE_LIST`
--

CREATE TABLE `T_WC_TMDB_SERIE_LIST` (
  `ID_TMDB_SERIE_LIST` int(11) NOT NULL,
  `ID_LIST` int(11) NOT NULL,
  `ID_SERIE` int(11) NOT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_SERIE_NETWORK`
--

CREATE TABLE `T_WC_TMDB_SERIE_NETWORK` (
  `ID_ROW` int(11) NOT NULL,
  `ID_SERIE` int(11) NOT NULL,
  `ID_NETWORK` int(11) NOT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_SERIE_PRODUCTION_COUNTRY`
--

CREATE TABLE `T_WC_TMDB_SERIE_PRODUCTION_COUNTRY` (
  `ID_ROW` int(11) NOT NULL,
  `ID_SERIE` int(11) NOT NULL,
  `COUNTRY_CODE` varchar(2) NOT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_SERIE_SPOKEN_LANGUAGE`
--

CREATE TABLE `T_WC_TMDB_SERIE_SPOKEN_LANGUAGE` (
  `ID_ROW` int(11) NOT NULL,
  `ID_SERIE` int(11) NOT NULL,
  `SPOKEN_LANGUAGE` varchar(2) NOT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_SERIE_VIDEO`
--

CREATE TABLE `T_WC_TMDB_SERIE_VIDEO` (
  `ID_ROW` int(11) NOT NULL,
  `ID_SERIE` int(11) NOT NULL,
  `DELETED` int(5) DEFAULT NULL,
  `DISPLAY_ORDER` int(5) DEFAULT NULL,
  `ID_CREATOR` int(5) DEFAULT NULL,
  `DAT_CREAT` date DEFAULT NULL,
  `ID_OWNER` int(5) DEFAULT NULL,
  `TIM_UPDATED` datetime DEFAULT NULL,
  `ID_USER_UPDATED` int(5) DEFAULT NULL,
  `LANG` varchar(2) DEFAULT NULL,
  `COUNTRY_CODE` varchar(2) DEFAULT NULL,
  `VIDEO_KEY` varchar(20) DEFAULT NULL,
  `VIDEO_NAME` varchar(200) DEFAULT NULL,
  `VIDEO_SITE` varchar(50) DEFAULT NULL,
  `VIDEO_TYPE` varchar(50) DEFAULT NULL,
  `QUALITY` int(5) DEFAULT NULL,
  `QUALITY_TEXT` varchar(20) DEFAULT NULL,
  `DAT_PUBLISHED` datetime DEFAULT NULL,
  `ID_CREDIT` varchar(50) DEFAULT NULL,
  `OFFICIAL` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_TV_NETWORK_ID_IMPORT`
--

CREATE TABLE `T_WC_TMDB_TV_NETWORK_ID_IMPORT` (
  `id` int(11) NOT NULL,
  `name` varchar(250) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_TMDB_TV_SERIE_ID_IMPORT`
--

CREATE TABLE `T_WC_TMDB_TV_SERIE_ID_IMPORT` (
  `id` int(11) NOT NULL,
  `original_name` varchar(250) DEFAULT NULL,
  `popularity` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `T_WC_TMDB_COLLECTION`
--
ALTER TABLE `T_WC_TMDB_COLLECTION`
  ADD PRIMARY KEY (`ID_COLLECTION`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`),
  ADD KEY `NAME` (`NAME`),
  ADD KEY `POSTER_PATH` (`POSTER_PATH`),
  ADD KEY `BACKDROP_PATH` (`BACKDROP_PATH`),
  ADD KEY `TIM_CREDITS_COMPLETED` (`TIM_CREDITS_COMPLETED`),
  ADD KEY `TIM_CREDITS_DOWNLOADED` (`TIM_CREDITS_DOWNLOADED`),
  ADD KEY `USED_FOR_SIMILARITY` (`USED_FOR_SIMILARITY`),
  ADD KEY `TIM_IMAGES_COMPLETED` (`TIM_IMAGES_COMPLETED`),
  ADD KEY `ID_WIKIDATA` (`ID_WIKIDATA`);

--
-- Index pour la table `T_WC_TMDB_COLLECTION_ID_IMPORT`
--
ALTER TABLE `T_WC_TMDB_COLLECTION_ID_IMPORT`
  ADD PRIMARY KEY (`id`),
  ADD KEY `name` (`name`);

--
-- Index pour la table `T_WC_TMDB_COLLECTION_IMAGE`
--
ALTER TABLE `T_WC_TMDB_COLLECTION_IMAGE`
  ADD PRIMARY KEY (`ID_ROW`),
  ADD KEY `ID_COLLECTION` (`ID_COLLECTION`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`),
  ADD KEY `TYPE_IMAGE` (`TYPE_IMAGE`),
  ADD KEY `LANG` (`LANG`),
  ADD KEY `IMAGE_PATH` (`IMAGE_PATH`),
  ADD KEY `ASPECT_RATIO` (`ASPECT_RATIO`),
  ADD KEY `WIDTH` (`WIDTH`),
  ADD KEY `HEIGHT` (`HEIGHT`),
  ADD KEY `VOTE_AVERAGE` (`VOTE_AVERAGE`),
  ADD KEY `VOTE_COUNT` (`VOTE_COUNT`);

--
-- Index pour la table `T_WC_TMDB_COLLECTION_LANG`
--
ALTER TABLE `T_WC_TMDB_COLLECTION_LANG`
  ADD KEY `ID_COLLECTION` (`ID_COLLECTION`),
  ADD KEY `LANG` (`LANG`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`),
  ADD KEY `NAME` (`NAME`),
  ADD KEY `POSTER_PATH` (`POSTER_PATH`),
  ADD KEY `BACKDROP_PATH` (`BACKDROP_PATH`);

--
-- Index pour la table `T_WC_TMDB_COMPANY`
--
ALTER TABLE `T_WC_TMDB_COMPANY`
  ADD PRIMARY KEY (`ID_COMPANY`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`),
  ADD KEY `NAME` (`NAME`),
  ADD KEY `LOGO_PATH` (`LOGO_PATH`),
  ADD KEY `TIM_CREDITS_COMPLETED` (`TIM_CREDITS_COMPLETED`),
  ADD KEY `TIM_CREDITS_DOWNLOADED` (`TIM_CREDITS_DOWNLOADED`),
  ADD KEY `ID_PARENT` (`ID_PARENT`),
  ADD KEY `ORIGIN_COUNTRY` (`ORIGIN_COUNTRY`),
  ADD KEY `HEADQUARTERS` (`HEADQUARTERS`),
  ADD KEY `TIM_IMAGES_COMPLETED` (`TIM_IMAGES_COMPLETED`),
  ADD KEY `USED_FOR_SIMILARITY` (`USED_FOR_SIMILARITY`),
  ADD KEY `MOVIE_COUNT` (`MOVIE_COUNT`),
  ADD KEY `SERIE_COUNT` (`SERIE_COUNT`);

--
-- Index pour la table `T_WC_TMDB_COMPANY_IMAGE`
--
ALTER TABLE `T_WC_TMDB_COMPANY_IMAGE`
  ADD PRIMARY KEY (`ID_ROW`),
  ADD KEY `ID_COMPANY` (`ID_COMPANY`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`),
  ADD KEY `TYPE_IMAGE` (`TYPE_IMAGE`),
  ADD KEY `LANG` (`LANG`),
  ADD KEY `IMAGE_PATH` (`IMAGE_PATH`),
  ADD KEY `ASPECT_RATIO` (`ASPECT_RATIO`),
  ADD KEY `WIDTH` (`WIDTH`),
  ADD KEY `HEIGHT` (`HEIGHT`),
  ADD KEY `VOTE_AVERAGE` (`VOTE_AVERAGE`),
  ADD KEY `VOTE_COUNT` (`VOTE_COUNT`);

--
-- Index pour la table `T_WC_TMDB_GENRE`
--
ALTER TABLE `T_WC_TMDB_GENRE`
  ADD PRIMARY KEY (`id`),
  ADD KEY `name` (`name`);

--
-- Index pour la table `T_WC_TMDB_GENRE_LANG`
--
ALTER TABLE `T_WC_TMDB_GENRE_LANG`
  ADD PRIMARY KEY (`ID_ROW`),
  ADD KEY `id` (`id`),
  ADD KEY `LANG` (`LANG`),
  ADD KEY `name` (`name`);

--
-- Index pour la table `T_WC_TMDB_KEYWORD`
--
ALTER TABLE `T_WC_TMDB_KEYWORD`
  ADD PRIMARY KEY (`ID_KEYWORD`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`),
  ADD KEY `NAME` (`NAME`),
  ADD KEY `TIM_CREDITS_COMPLETED` (`TIM_CREDITS_COMPLETED`),
  ADD KEY `TIM_CREDITS_DOWNLOADED` (`TIM_CREDITS_DOWNLOADED`),
  ADD KEY `USE_FOR_TAGGING` (`USE_FOR_TAGGING`),
  ADD KEY `USED_FOR_SIMILARITY` (`USED_FOR_SIMILARITY`),
  ADD KEY `MOVIE_COUNT` (`MOVIE_COUNT`),
  ADD KEY `SERIE_COUNT` (`SERIE_COUNT`),
  ADD KEY `IS_EMPTY` (`IS_EMPTY`),
  ADD KEY `IS_PERSON` (`IS_PERSON`),
  ADD KEY `NAME_WORD_COUNT` (`NAME_WORD_COUNT`);

--
-- Index pour la table `T_WC_TMDB_KEYWORD_ID_IMPORT`
--
ALTER TABLE `T_WC_TMDB_KEYWORD_ID_IMPORT`
  ADD PRIMARY KEY (`id`),
  ADD KEY `name` (`name`),
  ADD KEY `USED_FOR_SIMILARITY` (`USED_FOR_SIMILARITY`);

--
-- Index pour la table `T_WC_TMDB_KEYWORD_ID_IMPORT_LANG`
--
ALTER TABLE `T_WC_TMDB_KEYWORD_ID_IMPORT_LANG`
  ADD PRIMARY KEY (`ID_ROW`),
  ADD KEY `id` (`id`),
  ADD KEY `LANG` (`LANG`),
  ADD KEY `name` (`name`),
  ADD KEY `USED_FOR_SIMILARITY` (`USED_FOR_SIMILARITY`),
  ADD KEY `USE_FOR_TAGGING` (`USE_FOR_TAGGING`);

--
-- Index pour la table `T_WC_TMDB_KEYWORD_LANG`
--
ALTER TABLE `T_WC_TMDB_KEYWORD_LANG`
  ADD PRIMARY KEY (`ID_ROW`),
  ADD KEY `ID_KEYWORD` (`ID_KEYWORD`),
  ADD KEY `LANG` (`LANG`),
  ADD KEY `NAME` (`NAME`),
  ADD KEY `USED_FOR_SIMILARITY` (`USED_FOR_SIMILARITY`),
  ADD KEY `USE_FOR_TAGGING` (`USE_FOR_TAGGING`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`);

--
-- Index pour la table `T_WC_TMDB_LANG_LANG`
--
ALTER TABLE `T_WC_TMDB_LANG_LANG`
  ADD KEY `LANG_DISPLAY` (`LANG_DISPLAY`),
  ADD KEY `LANG` (`LANG`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `DESCRIPTION` (`DESCRIPTION`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`);

--
-- Index pour la table `T_WC_TMDB_LIST`
--
ALTER TABLE `T_WC_TMDB_LIST`
  ADD PRIMARY KEY (`ID_LIST`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`),
  ADD KEY `NAME` (`NAME`),
  ADD KEY `POSTER_PATH` (`POSTER_PATH`),
  ADD KEY `TIM_CREDITS_DOWNLOADED` (`TIM_CREDITS_DOWNLOADED`),
  ADD KEY `TIM_CREDITS_COMPLETED` (`TIM_CREDITS_COMPLETED`),
  ADD KEY `USE_FOR_TAGGING` (`USE_FOR_TAGGING`),
  ADD KEY `USED_FOR_SIMILARITY` (`USED_FOR_SIMILARITY`),
  ADD KEY `SHORT_NAME` (`SHORT_NAME`),
  ADD KEY `CREATED_BY` (`CREATED_BY`),
  ADD KEY `ID_LIST_TYPE` (`ID_LIST_TYPE`),
  ADD KEY `ID_PROPERTY` (`ID_PROPERTY`),
  ADD KEY `ID_ITEM` (`ID_ITEM`);

--
-- Index pour la table `T_WC_TMDB_LIST_LANG`
--
ALTER TABLE `T_WC_TMDB_LIST_LANG`
  ADD PRIMARY KEY (`ID_ROW`),
  ADD KEY `ID_LIST` (`ID_LIST`),
  ADD KEY `LANG` (`LANG`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `SHORT_NAME` (`SHORT_NAME`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`);

--
-- Index pour la table `T_WC_TMDB_LIST_TYPE`
--
ALTER TABLE `T_WC_TMDB_LIST_TYPE`
  ADD PRIMARY KEY (`ID_LIST_TYPE`),
  ADD KEY `AUTO_UPDATE` (`AUTO_UPDATE`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`),
  ADD KEY `DESCRIPTION` (`DESCRIPTION`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`);

--
-- Index pour la table `T_WC_TMDB_MOVIE`
--
ALTER TABLE `T_WC_TMDB_MOVIE`
  ADD PRIMARY KEY (`ID_MOVIE`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`),
  ADD KEY `ID_IMDB` (`ID_IMDB`),
  ADD KEY `TITLE` (`TITLE`),
  ADD KEY `POPULARITY` (`POPULARITY`),
  ADD KEY `ADULT` (`ADULT`),
  ADD KEY `POSTER_PATH` (`POSTER_PATH`),
  ADD KEY `ORIGINAL_LANGUAGE` (`ORIGINAL_LANGUAGE`),
  ADD KEY `STATUS` (`STATUS`),
  ADD KEY `GENRES` (`GENRES`),
  ADD KEY `ID_COLLECTION` (`ID_COLLECTION`),
  ADD KEY `BUDGET` (`BUDGET`),
  ADD KEY `DAT_RELEASE` (`DAT_RELEASE`),
  ADD KEY `RUNTIME` (`RUNTIME`),
  ADD KEY `BACKDROP_PATH` (`BACKDROP_PATH`),
  ADD KEY `REVENUE` (`REVENUE`),
  ADD KEY `VIDEO` (`VIDEO`),
  ADD KEY `VOTE_AVERAGE` (`VOTE_AVERAGE`),
  ADD KEY `VOTE_COUNT` (`VOTE_COUNT`),
  ADD KEY `TIM_CREDITS_COMPLETED` (`TIM_CREDITS_COMPLETED`),
  ADD KEY `ORIGINAL_TITLE` (`ORIGINAL_TITLE`),
  ADD KEY `ID_WIKIDATA` (`ID_WIKIDATA`),
  ADD KEY `TIM_KEYWORDS_COMPLETED` (`TIM_KEYWORDS_COMPLETED`),
  ADD KEY `TIM_WIKIDATA_COMPLETED` (`TIM_WIKIDATA_COMPLETED`),
  ADD KEY `TIM_WIKIPEDIA_COMPLETED` (`TIM_WIKIPEDIA_COMPLETED`),
  ADD KEY `WIKIPEDIA_FORMAT_LINE` (`WIKIPEDIA_FORMAT_LINE`(768)),
  ADD KEY `IS_COLOR` (`IS_COLOR`),
  ADD KEY `IS_BLACK_AND_WHITE` (`IS_BLACK_AND_WHITE`),
  ADD KEY `IS_SILENT` (`IS_SILENT`),
  ADD KEY `IS_3D` (`IS_3D`),
  ADD KEY `COLOR_TECHNOLOGY` (`COLOR_TECHNOLOGY`),
  ADD KEY `FILM_TECHNOLOGY` (`FILM_TECHNOLOGY`(768)),
  ADD KEY `ASPECT_RATIO` (`ASPECT_RATIO`),
  ADD KEY `FILM_FORMAT` (`FILM_FORMAT`),
  ADD KEY `SOUND_SYSTEM` (`SOUND_SYSTEM`(768)),
  ADD KEY `NUM_AUDIO_TRACKS` (`NUM_AUDIO_TRACKS`),
  ADD KEY `IS_VALID_FORMAT` (`IS_VALID_FORMAT`),
  ADD KEY `IS_MOVIE` (`IS_MOVIE`),
  ADD KEY `IS_DOCUMENTARY` (`IS_DOCUMENTARY`),
  ADD KEY `RELEASE_YEAR` (`RELEASE_YEAR`),
  ADD KEY `RELEASE_MONTH` (`RELEASE_MONTH`),
  ADD KEY `RELEASE_DAY` (`RELEASE_DAY`),
  ADD KEY `IS_SHORT_FILM` (`IS_SHORT_FILM`),
  ADD KEY `TIM_IMAGES_COMPLETED` (`TIM_IMAGES_COMPLETED`),
  ADD KEY `SOUND_TECHNOLOGY` (`SOUND_TECHNOLOGY`),
  ADD KEY `DAT_WIKIPEDIA_FORMAT_LINE` (`DAT_WIKIPEDIA_FORMAT_LINE`),
  ADD KEY `TIM_VIDEOS_COMPLETED` (`TIM_VIDEOS_COMPLETED`);

--
-- Index pour la table `T_WC_TMDB_MOVIE_COMPANY`
--
ALTER TABLE `T_WC_TMDB_MOVIE_COMPANY`
  ADD PRIMARY KEY (`ID_ROW`),
  ADD KEY `ID_MOVIE` (`ID_MOVIE`),
  ADD KEY `ID_COMPANY` (`ID_COMPANY`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`);

--
-- Index pour la table `T_WC_TMDB_MOVIE_GENRE`
--
ALTER TABLE `T_WC_TMDB_MOVIE_GENRE`
  ADD PRIMARY KEY (`ID_ROW`),
  ADD KEY `ID_MOVIE` (`ID_MOVIE`),
  ADD KEY `ID_GENRE` (`ID_GENRE`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`);

--
-- Index pour la table `T_WC_TMDB_MOVIE_ID_IMPORT`
--
ALTER TABLE `T_WC_TMDB_MOVIE_ID_IMPORT`
  ADD PRIMARY KEY (`id`),
  ADD KEY `popularity` (`popularity`);

--
-- Index pour la table `T_WC_TMDB_MOVIE_IMAGE`
--
ALTER TABLE `T_WC_TMDB_MOVIE_IMAGE`
  ADD PRIMARY KEY (`ID_ROW`),
  ADD KEY `ID_MOVIE` (`ID_MOVIE`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`),
  ADD KEY `TYPE_IMAGE` (`TYPE_IMAGE`),
  ADD KEY `LANG` (`LANG`),
  ADD KEY `IMAGE_PATH` (`IMAGE_PATH`),
  ADD KEY `ASPECT_RATIO` (`ASPECT_RATIO`),
  ADD KEY `WIDTH` (`WIDTH`),
  ADD KEY `HEIGHT` (`HEIGHT`),
  ADD KEY `VOTE_AVERAGE` (`VOTE_AVERAGE`),
  ADD KEY `VOTE_COUNT` (`VOTE_COUNT`);

--
-- Index pour la table `T_WC_TMDB_MOVIE_KEYWORD`
--
ALTER TABLE `T_WC_TMDB_MOVIE_KEYWORD`
  ADD PRIMARY KEY (`ID_ROW`),
  ADD KEY `ID_MOVIE` (`ID_MOVIE`),
  ADD KEY `ID_KEYWORD` (`ID_KEYWORD`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`);

--
-- Index pour la table `T_WC_TMDB_MOVIE_LANG`
--
ALTER TABLE `T_WC_TMDB_MOVIE_LANG`
  ADD PRIMARY KEY (`ID_ROW`),
  ADD KEY `ID_MOVIE` (`ID_MOVIE`),
  ADD KEY `LANG` (`LANG`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`),
  ADD KEY `TITLE` (`TITLE`),
  ADD KEY `POSTER_PATH` (`POSTER_PATH`),
  ADD KEY `BACKDROP_PATH` (`BACKDROP_PATH`);

--
-- Index pour la table `T_WC_TMDB_MOVIE_LANG_META`
--
ALTER TABLE `T_WC_TMDB_MOVIE_LANG_META`
  ADD PRIMARY KEY (`ID_ROW`),
  ADD KEY `ID_MOVIE` (`ID_MOVIE`),
  ADD KEY `LANG` (`LANG`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`),
  ADD KEY `YEAR_RELEASE` (`YEAR_RELEASE`),
  ADD KEY `ORIGINAL_LANGUAGE` (`ORIGINAL_LANGUAGE`),
  ADD KEY `IMDB_RATING` (`IMDB_RATING`);

--
-- Index pour la table `T_WC_TMDB_MOVIE_LEMME`
--
ALTER TABLE `T_WC_TMDB_MOVIE_LEMME`
  ADD PRIMARY KEY (`ID_ROW`),
  ADD KEY `ID_MOVIE` (`ID_MOVIE`),
  ADD KEY `ID_LEMME` (`ID_LEMME`),
  ADD KEY `START_CHAR` (`START_CHAR`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`);

--
-- Index pour la table `T_WC_TMDB_MOVIE_LIST`
--
ALTER TABLE `T_WC_TMDB_MOVIE_LIST`
  ADD PRIMARY KEY (`ID_TMDB_MOVIE_LIST`),
  ADD KEY `ID_LIST` (`ID_LIST`),
  ADD KEY `ID_MOVIE` (`ID_MOVIE`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`);

--
-- Index pour la table `T_WC_TMDB_MOVIE_PRODUCTION_COUNTRY`
--
ALTER TABLE `T_WC_TMDB_MOVIE_PRODUCTION_COUNTRY`
  ADD PRIMARY KEY (`ID_ROW`),
  ADD KEY `ID_MOVIE` (`ID_MOVIE`),
  ADD KEY `COUNTRY_CODE` (`COUNTRY_CODE`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`);

--
-- Index pour la table `T_WC_TMDB_MOVIE_SPOKEN_LANGUAGE`
--
ALTER TABLE `T_WC_TMDB_MOVIE_SPOKEN_LANGUAGE`
  ADD PRIMARY KEY (`ID_ROW`),
  ADD KEY `ID_MOVIE` (`ID_MOVIE`),
  ADD KEY `SPOKEN_LANGUAGE` (`SPOKEN_LANGUAGE`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`);

--
-- Index pour la table `T_WC_TMDB_MOVIE_TITLE`
--
ALTER TABLE `T_WC_TMDB_MOVIE_TITLE`
  ADD PRIMARY KEY (`ID_MOVIE_TITLE`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`),
  ADD KEY `ID_MOVIE` (`ID_MOVIE`),
  ADD KEY `TITLE` (`TITLE`),
  ADD KEY `ISO_3166_1` (`ISO_3166_1`),
  ADD KEY `TITLE_TYPE` (`TITLE_TYPE`);

--
-- Index pour la table `T_WC_TMDB_MOVIE_UPDATE`
--
ALTER TABLE `T_WC_TMDB_MOVIE_UPDATE`
  ADD PRIMARY KEY (`ID_MOVIE`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`),
  ADD KEY `ID_WIKIDATA` (`ID_WIKIDATA`);

--
-- Index pour la table `T_WC_TMDB_MOVIE_VIDEO`
--
ALTER TABLE `T_WC_TMDB_MOVIE_VIDEO`
  ADD PRIMARY KEY (`ID_ROW`),
  ADD KEY `ID_MOVIE` (`ID_MOVIE`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`),
  ADD KEY `LANG` (`LANG`),
  ADD KEY `COUNTRY_CODE` (`COUNTRY_CODE`),
  ADD KEY `VIDEO_KEY` (`VIDEO_KEY`),
  ADD KEY `VIDEO_SITE` (`VIDEO_SITE`),
  ADD KEY `VIDEO_TYPE` (`VIDEO_TYPE`),
  ADD KEY `QUALITY` (`QUALITY`),
  ADD KEY `VIDEO_NAME` (`VIDEO_NAME`),
  ADD KEY `QUALITY_TEXT` (`QUALITY_TEXT`),
  ADD KEY `DAT_PUBLISHED` (`DAT_PUBLISHED`),
  ADD KEY `ID_CREDIT` (`ID_CREDIT`),
  ADD KEY `OFFICIAL` (`OFFICIAL`);

--
-- Index pour la table `T_WC_TMDB_NETWORK`
--
ALTER TABLE `T_WC_TMDB_NETWORK`
  ADD PRIMARY KEY (`ID_NETWORK`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`),
  ADD KEY `NAME` (`NAME`),
  ADD KEY `LOGO_PATH` (`LOGO_PATH`),
  ADD KEY `TIM_CREDITS_COMPLETED` (`TIM_CREDITS_COMPLETED`),
  ADD KEY `TIM_CREDITS_DOWNLOADED` (`TIM_CREDITS_DOWNLOADED`),
  ADD KEY `ID_PARENT` (`ID_PARENT`),
  ADD KEY `ORIGIN_COUNTRY` (`ORIGIN_COUNTRY`),
  ADD KEY `TIM_IMAGES_COMPLETED` (`TIM_IMAGES_COMPLETED`),
  ADD KEY `HOMEPAGE_URL` (`HOMEPAGE_URL`),
  ADD KEY `HEADQUARTERS` (`HEADQUARTERS`),
  ADD KEY `SERIE_COUNT` (`SERIE_COUNT`);

--
-- Index pour la table `T_WC_TMDB_NETWORK_IMAGE`
--
ALTER TABLE `T_WC_TMDB_NETWORK_IMAGE`
  ADD PRIMARY KEY (`ID_ROW`),
  ADD KEY `ID_NETWORK` (`ID_NETWORK`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`),
  ADD KEY `TYPE_IMAGE` (`TYPE_IMAGE`),
  ADD KEY `LANG` (`LANG`),
  ADD KEY `IMAGE_PATH` (`IMAGE_PATH`),
  ADD KEY `ASPECT_RATIO` (`ASPECT_RATIO`),
  ADD KEY `WIDTH` (`WIDTH`),
  ADD KEY `HEIGHT` (`HEIGHT`),
  ADD KEY `VOTE_AVERAGE` (`VOTE_AVERAGE`),
  ADD KEY `VOTE_COUNT` (`VOTE_COUNT`);

--
-- Index pour la table `T_WC_TMDB_PERSON`
--
ALTER TABLE `T_WC_TMDB_PERSON`
  ADD PRIMARY KEY (`ID_PERSON`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`),
  ADD KEY `ID_IMDB` (`ID_IMDB`),
  ADD KEY `BIRTHDAY` (`BIRTHDAY`),
  ADD KEY `DEATHDAY` (`DEATHDAY`),
  ADD KEY `GENDER` (`GENDER`),
  ADD KEY `NAME` (`NAME`),
  ADD KEY `POPULARITY` (`POPULARITY`),
  ADD KEY `ADULT` (`ADULT`),
  ADD KEY `TIM_COMPLETED` (`TIM_CREDITS_COMPLETED`),
  ADD KEY `PROFILE_PATH` (`PROFILE_PATH`),
  ADD KEY `KNOWN_FOR_DEPARTMENT` (`KNOWN_FOR_DEPARTMENT`),
  ADD KEY `TIM_CREDITS_DOWNLOADED` (`TIM_CREDITS_DOWNLOADED`),
  ADD KEY `TIM_CREDITS_COMPLETED` (`TIM_CREDITS_COMPLETED`),
  ADD KEY `PLACE_OF_BIRTH` (`PLACE_OF_BIRTH`),
  ADD KEY `ID_WIKIDATA` (`ID_WIKIDATA`),
  ADD KEY `USED_FOR_SIMILARITY` (`USED_FOR_SIMILARITY`),
  ADD KEY `BIRTH_DAY` (`BIRTH_DAY`),
  ADD KEY `BIRTH_MONTH` (`BIRTH_MONTH`),
  ADD KEY `BIRTH_YEAR` (`BIRTH_YEAR`),
  ADD KEY `DEATH_DAY` (`DEATH_DAY`),
  ADD KEY `DEATH_MONTH` (`DEATH_MONTH`),
  ADD KEY `DEATH_YEAR` (`DEATH_YEAR`),
  ADD KEY `COUNTRY_OF_BIRTH` (`COUNTRY_OF_BIRTH`),
  ADD KEY `COUNTRY_OF_BIRTH_LONG` (`COUNTRY_OF_BIRTH_LONG`),
  ADD KEY `TIM_IMAGES_COMPLETED` (`TIM_IMAGES_COMPLETED`),
  ADD KEY `TIM_WIKIDATA_COMPLETED` (`TIM_WIKIDATA_COMPLETED`);

--
-- Index pour la table `T_WC_TMDB_PERSON_ID_IMPORT`
--
ALTER TABLE `T_WC_TMDB_PERSON_ID_IMPORT`
  ADD PRIMARY KEY (`id`),
  ADD KEY `popularity` (`popularity`),
  ADD KEY `popularity_2` (`popularity`);

--
-- Index pour la table `T_WC_TMDB_PERSON_IMAGE`
--
ALTER TABLE `T_WC_TMDB_PERSON_IMAGE`
  ADD PRIMARY KEY (`ID_ROW`),
  ADD KEY `ID_PERSON` (`ID_PERSON`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`),
  ADD KEY `TYPE_IMAGE` (`TYPE_IMAGE`),
  ADD KEY `LANG` (`LANG`),
  ADD KEY `IMAGE_PATH` (`IMAGE_PATH`),
  ADD KEY `ASPECT_RATIO` (`ASPECT_RATIO`),
  ADD KEY `WIDTH` (`WIDTH`),
  ADD KEY `HEIGHT` (`HEIGHT`),
  ADD KEY `VOTE_AVERAGE` (`VOTE_AVERAGE`),
  ADD KEY `VOTE_COUNT` (`VOTE_COUNT`);

--
-- Index pour la table `T_WC_TMDB_PERSON_MOVIE`
--
ALTER TABLE `T_WC_TMDB_PERSON_MOVIE`
  ADD PRIMARY KEY (`ID_TMDB_PERSON_MOVIE`),
  ADD KEY `ID_PERSON` (`ID_PERSON`),
  ADD KEY `ID_MOVIE` (`ID_MOVIE`),
  ADD KEY `ID_CREDIT` (`ID_CREDIT`),
  ADD KEY `CAST_CHARACTER` (`CAST_CHARACTER`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `CREDIT_TYPE` (`CREDIT_TYPE`),
  ADD KEY `CREW_DEPARTMENT` (`CREW_DEPARTMENT`),
  ADD KEY `CREW_JOB` (`CREW_JOB`);

--
-- Index pour la table `T_WC_TMDB_PERSON_SEARCH`
--
ALTER TABLE `T_WC_TMDB_PERSON_SEARCH`
  ADD PRIMARY KEY (`ID_ROW`),
  ADD KEY `ID_PERSON` (`ID_PERSON`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`),
  ADD KEY `NAME` (`NAME`);

--
-- Index pour la table `T_WC_TMDB_PERSON_SERIE`
--
ALTER TABLE `T_WC_TMDB_PERSON_SERIE`
  ADD PRIMARY KEY (`ID_TMDB_PERSON_SERIE`),
  ADD KEY `ID_PERSON` (`ID_PERSON`),
  ADD KEY `ID_SERIE` (`ID_SERIE`),
  ADD KEY `ID_CREDIT` (`ID_CREDIT`),
  ADD KEY `CAST_CHARACTER` (`CAST_CHARACTER`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `CREDIT_TYPE` (`CREDIT_TYPE`),
  ADD KEY `CREW_DEPARTMENT` (`CREW_DEPARTMENT`),
  ADD KEY `CREW_JOB` (`CREW_JOB`);

--
-- Index pour la table `T_WC_TMDB_PERSON_UPDATE`
--
ALTER TABLE `T_WC_TMDB_PERSON_UPDATE`
  ADD PRIMARY KEY (`ID_PERSON`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`),
  ADD KEY `ID_WIKIDATA` (`ID_WIKIDATA`);

--
-- Index pour la table `T_WC_TMDB_PRODUCTION_COMPANY_ID_IMPORT`
--
ALTER TABLE `T_WC_TMDB_PRODUCTION_COMPANY_ID_IMPORT`
  ADD PRIMARY KEY (`id`),
  ADD KEY `name` (`name`);

--
-- Index pour la table `T_WC_TMDB_SERIE`
--
ALTER TABLE `T_WC_TMDB_SERIE`
  ADD PRIMARY KEY (`ID_SERIE`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`),
  ADD KEY `ID_IMDB` (`ID_IMDB`),
  ADD KEY `TITLE` (`TITLE`),
  ADD KEY `POPULARITY` (`POPULARITY`),
  ADD KEY `ADULT` (`ADULT`),
  ADD KEY `POSTER_PATH` (`POSTER_PATH`),
  ADD KEY `ORIGINAL_LANGUAGE` (`ORIGINAL_LANGUAGE`),
  ADD KEY `STATUS` (`STATUS`),
  ADD KEY `GENRES` (`GENRES`),
  ADD KEY `DAT_RELEASE` (`DAT_FIRST_AIR`),
  ADD KEY `BACKDROP_PATH` (`BACKDROP_PATH`),
  ADD KEY `VOTE_AVERAGE` (`VOTE_AVERAGE`),
  ADD KEY `VOTE_COUNT` (`VOTE_COUNT`),
  ADD KEY `TIM_CREDITS_COMPLETED` (`TIM_CREDITS_COMPLETED`),
  ADD KEY `ORIGINAL_TITLE` (`ORIGINAL_TITLE`),
  ADD KEY `ID_WIKIDATA` (`ID_WIKIDATA`),
  ADD KEY `TIM_KEYWORDS_COMPLETED` (`TIM_KEYWORDS_COMPLETED`),
  ADD KEY `TIM_WIKIDATA_COMPLETED` (`TIM_WIKIDATA_COMPLETED`),
  ADD KEY `TIM_WIKIPEDIA_COMPLETED` (`TIM_WIKIPEDIA_COMPLETED`),
  ADD KEY `DAT_LAST_AIR` (`DAT_LAST_AIR`),
  ADD KEY `FIRST_AIR_YEAR` (`FIRST_AIR_YEAR`),
  ADD KEY `FIRST_AIR_MONTH` (`FIRST_AIR_MONTH`),
  ADD KEY `FIRST_AIR_DAY` (`FIRST_AIR_DAY`),
  ADD KEY `LAST_AIR_YEAR` (`LAST_AIR_YEAR`),
  ADD KEY `LAST_AIR_MONTH` (`LAST_AIR_MONTH`),
  ADD KEY `LAST_AIR_DAY` (`LAST_AIR_DAY`),
  ADD KEY `NUMBER_OF_EPISODES` (`NUMBER_OF_EPISODES`),
  ADD KEY `NUMBER_OF_SEASONS` (`NUMBER_OF_SEASONS`),
  ADD KEY `SERIE_TYPE` (`SERIE_TYPE`),
  ADD KEY `TIM_IMAGES_COMPLETED` (`TIM_IMAGES_COMPLETED`),
  ADD KEY `TIM_VIDEOS_COMPLETED` (`TIM_VIDEOS_COMPLETED`);

--
-- Index pour la table `T_WC_TMDB_SERIE_COMPANY`
--
ALTER TABLE `T_WC_TMDB_SERIE_COMPANY`
  ADD PRIMARY KEY (`ID_ROW`),
  ADD KEY `ID_SERIE` (`ID_SERIE`),
  ADD KEY `ID_COMPANY` (`ID_COMPANY`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`);

--
-- Index pour la table `T_WC_TMDB_SERIE_GENRE`
--
ALTER TABLE `T_WC_TMDB_SERIE_GENRE`
  ADD PRIMARY KEY (`ID_ROW`),
  ADD KEY `ID_SERIE` (`ID_SERIE`),
  ADD KEY `ID_GENRE` (`ID_GENRE`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`);

--
-- Index pour la table `T_WC_TMDB_SERIE_IMAGE`
--
ALTER TABLE `T_WC_TMDB_SERIE_IMAGE`
  ADD PRIMARY KEY (`ID_ROW`),
  ADD KEY `ID_SERIE` (`ID_SERIE`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`),
  ADD KEY `TYPE_IMAGE` (`TYPE_IMAGE`),
  ADD KEY `LANG` (`LANG`),
  ADD KEY `IMAGE_PATH` (`IMAGE_PATH`),
  ADD KEY `ASPECT_RATIO` (`ASPECT_RATIO`),
  ADD KEY `WIDTH` (`WIDTH`),
  ADD KEY `HEIGHT` (`HEIGHT`),
  ADD KEY `VOTE_AVERAGE` (`VOTE_AVERAGE`),
  ADD KEY `VOTE_COUNT` (`VOTE_COUNT`);

--
-- Index pour la table `T_WC_TMDB_SERIE_KEYWORD`
--
ALTER TABLE `T_WC_TMDB_SERIE_KEYWORD`
  ADD PRIMARY KEY (`ID_ROW`),
  ADD KEY `ID_SERIE` (`ID_SERIE`),
  ADD KEY `ID_KEYWORD` (`ID_KEYWORD`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`);

--
-- Index pour la table `T_WC_TMDB_SERIE_LANG`
--
ALTER TABLE `T_WC_TMDB_SERIE_LANG`
  ADD PRIMARY KEY (`ID_ROW`),
  ADD KEY `ID_SERIE` (`ID_SERIE`),
  ADD KEY `LANG` (`LANG`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`),
  ADD KEY `TITLE` (`TITLE`),
  ADD KEY `POSTER_PATH` (`POSTER_PATH`),
  ADD KEY `BACKDROP_PATH` (`BACKDROP_PATH`);

--
-- Index pour la table `T_WC_TMDB_SERIE_LIST`
--
ALTER TABLE `T_WC_TMDB_SERIE_LIST`
  ADD PRIMARY KEY (`ID_TMDB_SERIE_LIST`),
  ADD KEY `ID_LIST` (`ID_LIST`),
  ADD KEY `ID_SERIE` (`ID_SERIE`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`);

--
-- Index pour la table `T_WC_TMDB_SERIE_NETWORK`
--
ALTER TABLE `T_WC_TMDB_SERIE_NETWORK`
  ADD PRIMARY KEY (`ID_ROW`),
  ADD KEY `ID_SERIE` (`ID_SERIE`),
  ADD KEY `ID_NETWORK` (`ID_NETWORK`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`);

--
-- Index pour la table `T_WC_TMDB_SERIE_PRODUCTION_COUNTRY`
--
ALTER TABLE `T_WC_TMDB_SERIE_PRODUCTION_COUNTRY`
  ADD PRIMARY KEY (`ID_ROW`),
  ADD KEY `ID_SERIE` (`ID_SERIE`),
  ADD KEY `COUNTRY_CODE` (`COUNTRY_CODE`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`);

--
-- Index pour la table `T_WC_TMDB_SERIE_SPOKEN_LANGUAGE`
--
ALTER TABLE `T_WC_TMDB_SERIE_SPOKEN_LANGUAGE`
  ADD PRIMARY KEY (`ID_ROW`),
  ADD KEY `ID_SERIE` (`ID_SERIE`),
  ADD KEY `SPOKEN_LANGUAGE` (`SPOKEN_LANGUAGE`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`);

--
-- Index pour la table `T_WC_TMDB_SERIE_VIDEO`
--
ALTER TABLE `T_WC_TMDB_SERIE_VIDEO`
  ADD PRIMARY KEY (`ID_ROW`),
  ADD KEY `ID_SERIE` (`ID_SERIE`),
  ADD KEY `DELETED` (`DELETED`),
  ADD KEY `DISPLAY_ORDER` (`DISPLAY_ORDER`),
  ADD KEY `ID_OWNER` (`ID_OWNER`),
  ADD KEY `ID_CREATOR` (`ID_CREATOR`),
  ADD KEY `ID_USER_UPDATED` (`ID_USER_UPDATED`),
  ADD KEY `TIM_UPDATED` (`TIM_UPDATED`),
  ADD KEY `DAT_CREAT` (`DAT_CREAT`),
  ADD KEY `LANG` (`LANG`),
  ADD KEY `COUNTRY_CODE` (`COUNTRY_CODE`),
  ADD KEY `VIDEO_KEY` (`VIDEO_KEY`),
  ADD KEY `VIDEO_SITE` (`VIDEO_SITE`),
  ADD KEY `VIDEO_TYPE` (`VIDEO_TYPE`),
  ADD KEY `QUALITY` (`QUALITY`),
  ADD KEY `VIDEO_NAME` (`VIDEO_NAME`),
  ADD KEY `QUALITY_TEXT` (`QUALITY_TEXT`),
  ADD KEY `DAT_PUBLISHED` (`DAT_PUBLISHED`),
  ADD KEY `ID_CREDIT` (`ID_CREDIT`),
  ADD KEY `OFFICIAL` (`OFFICIAL`);

--
-- Index pour la table `T_WC_TMDB_TV_NETWORK_ID_IMPORT`
--
ALTER TABLE `T_WC_TMDB_TV_NETWORK_ID_IMPORT`
  ADD PRIMARY KEY (`id`),
  ADD KEY `name` (`name`);

--
-- Index pour la table `T_WC_TMDB_TV_SERIE_ID_IMPORT`
--
ALTER TABLE `T_WC_TMDB_TV_SERIE_ID_IMPORT`
  ADD PRIMARY KEY (`id`),
  ADD KEY `popularity` (`popularity`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_COLLECTION_IMAGE`
--
ALTER TABLE `T_WC_TMDB_COLLECTION_IMAGE`
  MODIFY `ID_ROW` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_COMPANY_IMAGE`
--
ALTER TABLE `T_WC_TMDB_COMPANY_IMAGE`
  MODIFY `ID_ROW` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_GENRE_LANG`
--
ALTER TABLE `T_WC_TMDB_GENRE_LANG`
  MODIFY `ID_ROW` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_KEYWORD_ID_IMPORT_LANG`
--
ALTER TABLE `T_WC_TMDB_KEYWORD_ID_IMPORT_LANG`
  MODIFY `ID_ROW` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_KEYWORD_LANG`
--
ALTER TABLE `T_WC_TMDB_KEYWORD_LANG`
  MODIFY `ID_ROW` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_LIST_LANG`
--
ALTER TABLE `T_WC_TMDB_LIST_LANG`
  MODIFY `ID_ROW` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_LIST_TYPE`
--
ALTER TABLE `T_WC_TMDB_LIST_TYPE`
  MODIFY `ID_LIST_TYPE` int(5) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_MOVIE_COMPANY`
--
ALTER TABLE `T_WC_TMDB_MOVIE_COMPANY`
  MODIFY `ID_ROW` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_MOVIE_GENRE`
--
ALTER TABLE `T_WC_TMDB_MOVIE_GENRE`
  MODIFY `ID_ROW` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_MOVIE_IMAGE`
--
ALTER TABLE `T_WC_TMDB_MOVIE_IMAGE`
  MODIFY `ID_ROW` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_MOVIE_KEYWORD`
--
ALTER TABLE `T_WC_TMDB_MOVIE_KEYWORD`
  MODIFY `ID_ROW` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_MOVIE_LANG`
--
ALTER TABLE `T_WC_TMDB_MOVIE_LANG`
  MODIFY `ID_ROW` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_MOVIE_LANG_META`
--
ALTER TABLE `T_WC_TMDB_MOVIE_LANG_META`
  MODIFY `ID_ROW` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_MOVIE_LEMME`
--
ALTER TABLE `T_WC_TMDB_MOVIE_LEMME`
  MODIFY `ID_ROW` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_MOVIE_LIST`
--
ALTER TABLE `T_WC_TMDB_MOVIE_LIST`
  MODIFY `ID_TMDB_MOVIE_LIST` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_MOVIE_PRODUCTION_COUNTRY`
--
ALTER TABLE `T_WC_TMDB_MOVIE_PRODUCTION_COUNTRY`
  MODIFY `ID_ROW` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_MOVIE_SPOKEN_LANGUAGE`
--
ALTER TABLE `T_WC_TMDB_MOVIE_SPOKEN_LANGUAGE`
  MODIFY `ID_ROW` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_MOVIE_TITLE`
--
ALTER TABLE `T_WC_TMDB_MOVIE_TITLE`
  MODIFY `ID_MOVIE_TITLE` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_MOVIE_VIDEO`
--
ALTER TABLE `T_WC_TMDB_MOVIE_VIDEO`
  MODIFY `ID_ROW` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_NETWORK_IMAGE`
--
ALTER TABLE `T_WC_TMDB_NETWORK_IMAGE`
  MODIFY `ID_ROW` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_PERSON_IMAGE`
--
ALTER TABLE `T_WC_TMDB_PERSON_IMAGE`
  MODIFY `ID_ROW` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_PERSON_MOVIE`
--
ALTER TABLE `T_WC_TMDB_PERSON_MOVIE`
  MODIFY `ID_TMDB_PERSON_MOVIE` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_PERSON_SEARCH`
--
ALTER TABLE `T_WC_TMDB_PERSON_SEARCH`
  MODIFY `ID_ROW` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_PERSON_SERIE`
--
ALTER TABLE `T_WC_TMDB_PERSON_SERIE`
  MODIFY `ID_TMDB_PERSON_SERIE` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_SERIE_COMPANY`
--
ALTER TABLE `T_WC_TMDB_SERIE_COMPANY`
  MODIFY `ID_ROW` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_SERIE_GENRE`
--
ALTER TABLE `T_WC_TMDB_SERIE_GENRE`
  MODIFY `ID_ROW` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_SERIE_IMAGE`
--
ALTER TABLE `T_WC_TMDB_SERIE_IMAGE`
  MODIFY `ID_ROW` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_SERIE_KEYWORD`
--
ALTER TABLE `T_WC_TMDB_SERIE_KEYWORD`
  MODIFY `ID_ROW` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_SERIE_LANG`
--
ALTER TABLE `T_WC_TMDB_SERIE_LANG`
  MODIFY `ID_ROW` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_SERIE_LIST`
--
ALTER TABLE `T_WC_TMDB_SERIE_LIST`
  MODIFY `ID_TMDB_SERIE_LIST` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_SERIE_NETWORK`
--
ALTER TABLE `T_WC_TMDB_SERIE_NETWORK`
  MODIFY `ID_ROW` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_SERIE_PRODUCTION_COUNTRY`
--
ALTER TABLE `T_WC_TMDB_SERIE_PRODUCTION_COUNTRY`
  MODIFY `ID_ROW` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_SERIE_SPOKEN_LANGUAGE`
--
ALTER TABLE `T_WC_TMDB_SERIE_SPOKEN_LANGUAGE`
  MODIFY `ID_ROW` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `T_WC_TMDB_SERIE_VIDEO`
--
ALTER TABLE `T_WC_TMDB_SERIE_VIDEO`
  MODIFY `ID_ROW` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
