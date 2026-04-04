-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : mariadb
-- Généré le : ven. 25 juil. 2025 à 15:24
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
-- Structure de la table `T_WC_IMDB_MOVIE_AKA_IMPORT`
--

CREATE TABLE `T_WC_IMDB_MOVIE_AKA_IMPORT` (
  `titleId` varchar(20) NOT NULL,
  `ordering` int(5) NOT NULL,
  `title` varchar(900) DEFAULT NULL,
  `region` varchar(20) DEFAULT NULL,
  `language` varchar(20) DEFAULT NULL,
  `types` varchar(50) DEFAULT NULL,
  `attributes` varchar(200) DEFAULT NULL,
  `isOriginalTitle` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_IMDB_MOVIE_BASIC_IMPORT`
--

CREATE TABLE `T_WC_IMDB_MOVIE_BASIC_IMPORT` (
  `tconst` varchar(20) NOT NULL,
  `titleType` varchar(20) DEFAULT NULL,
  `primaryTitle` varchar(800) DEFAULT NULL,
  `originalTitle` varchar(800) DEFAULT NULL,
  `isAdult` int(5) DEFAULT NULL,
  `startYear` varchar(4) DEFAULT NULL,
  `endYear` varchar(4) DEFAULT NULL,
  `runtimeMinutes` varchar(10) DEFAULT NULL,
  `genres` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_IMDB_MOVIE_PRINCIPAL_IMPORT`
--

CREATE TABLE `T_WC_IMDB_MOVIE_PRINCIPAL_IMPORT` (
  `tconst` varchar(20) NOT NULL,
  `ordering` int(5) NOT NULL,
  `nconst` varchar(20) DEFAULT NULL,
  `category` varchar(100) DEFAULT NULL,
  `job` varchar(500) DEFAULT NULL,
  `characters` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_IMDB_MOVIE_RATING_IMPORT`
--

CREATE TABLE `T_WC_IMDB_MOVIE_RATING_IMPORT` (
  `tconst` varchar(20) NOT NULL,
  `averageRating` double DEFAULT NULL,
  `numVotes` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_IMDB_PERSON_BASIC_IMPORT`
--

CREATE TABLE `T_WC_IMDB_PERSON_BASIC_IMPORT` (
  `nconst` varchar(20) NOT NULL,
  `primaryName` varchar(200) DEFAULT NULL,
  `birthYear` int(5) DEFAULT NULL,
  `deathYear` int(5) DEFAULT NULL,
  `primaryProfession` varchar(500) DEFAULT NULL,
  `knownForTitles` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_IMDB_PERSON_MOVIE_IMPORT`
--

CREATE TABLE `T_WC_IMDB_PERSON_MOVIE_IMPORT` (
  `tconst` varchar(20) NOT NULL,
  `directors` mediumtext DEFAULT NULL,
  `writers` mediumtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `T_WC_IMDB_SERIE_EPISODE_IMPORT`
--

CREATE TABLE `T_WC_IMDB_SERIE_EPISODE_IMPORT` (
  `tconst` varchar(20) NOT NULL,
  `parentTconst` varchar(20) NOT NULL,
  `seasonNumber` int(5) DEFAULT NULL,
  `episodeNumber` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `T_WC_IMDB_MOVIE_AKA_IMPORT`
--
ALTER TABLE `T_WC_IMDB_MOVIE_AKA_IMPORT`
  ADD PRIMARY KEY (`titleId`,`ordering`),
  ADD KEY `title` (`title`(768)),
  ADD KEY `region` (`region`),
  ADD KEY `language` (`language`),
  ADD KEY `types` (`types`),
  ADD KEY `attributes` (`attributes`),
  ADD KEY `isOriginalTitle` (`isOriginalTitle`);

--
-- Index pour la table `T_WC_IMDB_MOVIE_BASIC_IMPORT`
--
ALTER TABLE `T_WC_IMDB_MOVIE_BASIC_IMPORT`
  ADD PRIMARY KEY (`tconst`),
  ADD KEY `titleType` (`titleType`),
  ADD KEY `primaryTitle` (`primaryTitle`(768)),
  ADD KEY `originalTitle` (`originalTitle`(768)),
  ADD KEY `isAdult` (`isAdult`),
  ADD KEY `startYear` (`startYear`),
  ADD KEY `endYear` (`endYear`),
  ADD KEY `runtimeMinutes` (`runtimeMinutes`);

--
-- Index pour la table `T_WC_IMDB_MOVIE_PRINCIPAL_IMPORT`
--
ALTER TABLE `T_WC_IMDB_MOVIE_PRINCIPAL_IMPORT`
  ADD PRIMARY KEY (`tconst`,`ordering`),
  ADD KEY `nconst` (`nconst`),
  ADD KEY `category` (`category`),
  ADD KEY `job` (`job`),
  ADD KEY `characters` (`characters`);

--
-- Index pour la table `T_WC_IMDB_MOVIE_RATING_IMPORT`
--
ALTER TABLE `T_WC_IMDB_MOVIE_RATING_IMPORT`
  ADD PRIMARY KEY (`tconst`),
  ADD KEY `averageRating` (`averageRating`),
  ADD KEY `numVotes` (`numVotes`);

--
-- Index pour la table `T_WC_IMDB_PERSON_BASIC_IMPORT`
--
ALTER TABLE `T_WC_IMDB_PERSON_BASIC_IMPORT`
  ADD PRIMARY KEY (`nconst`),
  ADD KEY `primaryName` (`primaryName`),
  ADD KEY `birthYear` (`birthYear`),
  ADD KEY `deathYear` (`deathYear`),
  ADD KEY `primaryProfession` (`primaryProfession`),
  ADD KEY `knownForTitles` (`knownForTitles`);

--
-- Index pour la table `T_WC_IMDB_PERSON_MOVIE_IMPORT`
--
ALTER TABLE `T_WC_IMDB_PERSON_MOVIE_IMPORT`
  ADD PRIMARY KEY (`tconst`),
  ADD KEY `directors` (`directors`(768)),
  ADD KEY `writers` (`writers`(768));

--
-- Index pour la table `T_WC_IMDB_SERIE_EPISODE_IMPORT`
--
ALTER TABLE `T_WC_IMDB_SERIE_EPISODE_IMPORT`
  ADD PRIMARY KEY (`tconst`),
  ADD KEY `parentTconst` (`parentTconst`),
  ADD KEY `seasonNumber` (`seasonNumber`),
  ADD KEY `episodeNumber` (`episodeNumber`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
