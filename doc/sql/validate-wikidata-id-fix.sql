-- ===========================================================================
-- VALIDATION DU DEPLOIEMENT wikidata_id, 2026-09-15
--
-- Lecture seule, aucun effet de bord. Rien a purger apres.
--
-- A LANCER :
--   ~/docker/tools/runsqlvaugouindb.sh \
--     ~/docker/tmdb-crawler/doc/sql/validate-wikidata-id-fix.sql
--   -> ecrit validate-wikidata-id-fix-AAAAMMJJ.txt a cote, pret a committer.
--   Ce script passe --force de lui-meme, donc un bloc en erreur n'emporte pas
--   les suivants, et les erreurs sont recopiees en fin de resultat.
--
-- CE QUE CE FICHIER VALIDE, deux correctifs livres le 2026-09-14 :
--
--   8ba00de  Les processus 23, 29 et 30 lisent Wikidata V2 et non la V1 gelee.
--            Le 23 interrogeait T_WC_WIKIDATA_MOVIE_V1, dont les colonnes de
--            faits ne bougent plus depuis l'arret des crawlers SPARQL, donc il
--            ne pouvait redecouvrir aucune entite gagnee depuis. Les 29 et 30,
--            series et personnes, n'existaient pas.
--
--   587842d  Un jour de /changes abandonne en route ne fait plus avancer le
--            curseur. boolapifailed etait pose et lu nulle part : le jour etait
--            declare traite et tout ce qui suivait la page fautive etait perdu.
--
-- POURQUOI DES IDENTIFIANTS FIGES DANS LES BLOCS 1, 2 ET 4. Ce sont les deux
-- populations observees lors du passage du robot du 2026-09-14, releves dans
-- logs/selenium-tmdb-wikidata_id-20260914.log de selenium-tmdb. Elles ne se
-- recalculent pas en SQL, la base ne gardant pas trace de ce que le robot a vu
-- a l'ecran. Ce fichier est donc une validation datee, pas une requete de
-- surveillance : c'est le bloc 3, lui, qui se relit a tout moment.
-- ===========================================================================

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- 0. Le nouveau code tourne-t-il vraiment ?
--    La valeur doit contenir 29 ET 30. Si seul 23 y est, l'image n'a pas ete
--    reconstruite et tout ce qui suit ne mesure rien.
-- ---------------------------------------------------------------------------
SELECT VAR_NAME, VAR_VALUE
FROM T_WC_SERVER_VARIABLE
WHERE VAR_NAME IN ('strtmdbcrawlerprocessesexecuted',
                   'strtmdbcrawlerprocess23wikidatamovieidfixcount',
                   'strtmdbcrawlerprocess29wikidataserieidfixcount',
                   'strtmdbcrawlerprocess30wikidatapersonidfixcount',
                   'strtmdbcrawlerchangesmoviedate');

-- ---------------------------------------------------------------------------
-- 1. LE CONTROLE DES 235. C'est le test du correctif V2.
--    Ces fiches portaient deja le bon QID sur TMDb le 2026-09-14, et notre
--    copie etait vide depuis le 2026-09-02. Le processus 23 devait les relire.
--
--    AVEC_QID proche de 235 -> repare, la boucle est refermee.
--    SANS_QID encore elevé  -> le processus 23 ne les a pas vues, il faut
--                              regarder son nombre de lignes dans les journaux.
-- ---------------------------------------------------------------------------
SELECT COUNT(*)                                     AS TOTAL,
       SUM(ID_WIKIDATA REGEXP '^Q[0-9]+$')          AS AVEC_QID,
       SUM(ID_WIKIDATA IS NULL OR ID_WIKIDATA = '') AS SANS_QID,
       MIN(TIM_CREDITS_COMPLETED)                   AS PLUS_ANCIENNE_RELECTURE,
       MAX(TIM_CREDITS_COMPLETED)                   AS PLUS_RECENTE_RELECTURE
FROM T_WC_TMDB_MOVIE
WHERE ID_MOVIE IN (
  483090, 505460, 505473, 505488, 505511, 505611, 505640, 505704, 505790, 505832,
  505860, 505895, 505901, 505924, 506169, 506172, 506204, 506218, 506238, 506322,
  506400, 506730, 506732, 506826, 507022, 507034, 507095, 507161, 507190, 507206,
  507299, 507322, 507476, 507502, 507716, 507742, 507781, 507809, 507872, 507938,
  507970, 507987, 508065, 508093, 508204, 508401, 508515, 508528, 508568, 508631,
  508632, 508687, 508709, 508729, 508892, 508921, 509017, 509180, 509213, 509361,
  509370, 509409, 509515, 509529, 509624, 509723, 509739, 509870, 509950, 509975,
  510105, 510189, 510255, 510314, 510535, 510567, 510656, 510657, 510698, 510721,
  510819, 510859, 510942, 511076, 511127, 511270, 511354, 511367, 511685, 511700,
  511702, 511789, 511848, 511882, 511895, 511928, 512027, 512033, 512090, 512112,
  512186, 512533, 512545, 512748, 512755, 512891, 512922, 513046, 513092, 513172,
  513224, 513236, 513286, 513295, 513320, 513323, 513487, 513520, 513536, 513729,
  514222, 514350, 514507, 514637, 514755, 514801, 514851, 514879, 514925, 514955,
  514968, 515013, 515045, 515177, 515300, 515320, 515370, 515392, 515574, 515594,
  515597, 515638, 515677, 515840, 515883, 515946, 516027, 516259, 516304, 516511,
  516593, 516602, 516708, 516713, 516810, 516879, 516907, 516949, 516977, 516986,
  517101, 517113, 517184, 517358, 517461, 517463, 517510, 517628, 517636, 517677,
  517715, 517792, 517847, 517931, 518038, 518075, 518142, 518198, 518240, 518335,
  518411, 518413, 518454, 518462, 518486, 518597, 518727, 518737, 518751, 518793,
  518852, 518893, 519032, 519139, 519157, 519221, 519271, 519591, 519598, 519674,
  519748, 519828, 519893, 519965, 520054, 520103, 520145, 520268, 520343, 520400,
  520403, 520409, 520644, 520696, 520712, 520731, 520836, 520969, 520980, 521010,
  521116, 521154, 521273, 521394, 521413, 521438, 521449, 521639, 521695, 521902,
  521988, 522089, 522116, 522295, 522360
);

-- ---------------------------------------------------------------------------
-- 2. LE CONTROLE DES 174. C'est le test du chemin normal, le flux /changes.
--    Le robot leur a pose le QID le 2026-09-14 entre 08:42 et 08:53 UTC, et le
--    crawler avait lu le flux du jour a 05:54, donc avant. Seul le recul de
--    2 jours pouvait les rattraper.
--
--    AVEC_QID proche de 174 -> le recul a joue son role.
--    SANS_QID elevé         -> reproduction en direct du defaut du curseur,
--                              et cette fois les journaux existent.
-- ---------------------------------------------------------------------------
SELECT COUNT(*)                                     AS TOTAL,
       SUM(ID_WIKIDATA REGEXP '^Q[0-9]+$')          AS AVEC_QID,
       SUM(ID_WIKIDATA IS NULL OR ID_WIKIDATA = '') AS SANS_QID,
       MIN(TIM_CREDITS_COMPLETED)                   AS PLUS_ANCIENNE_RELECTURE,
       MAX(TIM_CREDITS_COMPLETED)                   AS PLUS_RECENTE_RELECTURE
FROM T_WC_TMDB_MOVIE
WHERE ID_MOVIE IN (
  3488, 32543, 49900, 50954, 51094, 53575, 60602, 65121, 67889, 71092,
  77769, 84518, 85826, 87810, 88682, 98344, 103868, 103974, 110026, 112712,
  113334, 113630, 120004, 124020, 131493, 139726, 140640, 144410, 144982, 159768,
  164974, 176176, 186514, 190856, 191069, 191453, 201549, 203970, 207972, 210290,
  210291, 213119, 217433, 225360, 231136, 231469, 236998, 239730, 246250, 250047,
  253219, 254642, 254666, 255488, 255515, 257719, 258557, 259158, 260777, 263671,
  263856, 266975, 267966, 268550, 270030, 272299, 273438, 274142, 274229, 275124,
  276788, 281302, 281353, 284847, 284877, 285171, 285178, 285386, 286831, 286854,
  286966, 287850, 288202, 288489, 288650, 288684, 289172, 289236, 290219, 291541,
  291618, 293453, 293804, 294421, 294426, 296008, 296504, 296545, 298067, 300115,
  306724, 307867, 318061, 319648, 321362, 326873, 332477, 355147, 364904, 368417,
  368746, 370820, 380854, 381386, 386816, 393579, 406400, 409781, 410252, 421265,
  423883, 435885, 437973, 438604, 438702, 439632, 440516, 440524, 440545, 441691,
  446983, 446996, 447338, 448018, 448495, 448505, 448598, 448614, 448616, 448637,
  448693, 448695, 448770, 451323, 451432, 453650, 453735, 453753, 453812, 453828,
  453850, 453867, 453869, 454092, 454105, 454116, 454125, 454127, 454174, 454205,
  458772, 464159, 475035, 476027, 483723, 483797, 492365, 495082, 497101, 497136,
  497804, 502696, 502762, 520798
);

-- ---------------------------------------------------------------------------
-- 3. Le reste-a-faire par type. SEUL BLOC REUTILISABLE de ce fichier,
--    a relancer quand on veut, il ne depend d'aucun identifiant fige.
--    Reference du 2026-09-14 : 1 873 films, 412 series, 720 personnes.
--    Une baisse nette du cote films est la signature de la reparation.
--
--    ⚠ LE PREFIXE IMDb DIFFERE SELON LE TYPE, 'tt' pour un titre et 'nm' pour
--    une personne. Le resultat du 2026-09-15 annonce 0 personne a reparer :
--    c'est FAUX, ce bloc portait alors 'tt%' pour les trois, et le processus 30
--    du crawler la meme erreur. Corrige ici et dans f_wikidataidfixsql.
-- ---------------------------------------------------------------------------
SET STATEMENT max_statement_time=300 FOR
SELECT 'films' AS TYPE, COUNT(*) AS RESTE_A_REPARER FROM (
SELECT DISTINCT T1.ID_MOVIE
  FROM T_WC_WIKIDATA_MOVIE W
  INNER JOIN T_WC_WIKIDATA_STATEMENT si ON si.ID_WIKIDATA = W.ID_WIKIDATA
         AND si.ID_PROPERTY = 'P345'
         AND (si.`RANK` IS NULL OR si.`RANK` <> 'deprecated')
  INNER JOIN T_WC_WIKIDATA_EXTERNAL_ID_VALUE imdb ON imdb.ID_STATEMENT = si.ID_STATEMENT
  INNER JOIN T_WC_TMDB_MOVIE T1 ON imdb.VALUE_EXTERNAL_ID = T1.ID_IMDB
  WHERE imdb.VALUE_EXTERNAL_ID LIKE 'tt%'
    AND (T1.ID_WIKIDATA IS NULL OR T1.ID_WIKIDATA = ''
         OR T1.ID_WIKIDATA NOT REGEXP '^Q[0-9]+$')
) c
UNION ALL
SELECT 'series' AS TYPE, COUNT(*) AS RESTE_A_REPARER FROM (
SELECT DISTINCT T1.ID_SERIE
  FROM T_WC_WIKIDATA_SERIE W
  INNER JOIN T_WC_WIKIDATA_STATEMENT si ON si.ID_WIKIDATA = W.ID_WIKIDATA
         AND si.ID_PROPERTY = 'P345'
         AND (si.`RANK` IS NULL OR si.`RANK` <> 'deprecated')
  INNER JOIN T_WC_WIKIDATA_EXTERNAL_ID_VALUE imdb ON imdb.ID_STATEMENT = si.ID_STATEMENT
  INNER JOIN T_WC_TMDB_SERIE T1 ON imdb.VALUE_EXTERNAL_ID = T1.ID_IMDB
  WHERE imdb.VALUE_EXTERNAL_ID LIKE 'tt%'
    AND (T1.ID_WIKIDATA IS NULL OR T1.ID_WIKIDATA = ''
         OR T1.ID_WIKIDATA NOT REGEXP '^Q[0-9]+$')
) c
UNION ALL
SELECT 'personnes' AS TYPE, COUNT(*) AS RESTE_A_REPARER FROM (
SELECT DISTINCT T1.ID_PERSON
  FROM T_WC_WIKIDATA_PERSON W
  INNER JOIN T_WC_WIKIDATA_STATEMENT si ON si.ID_WIKIDATA = W.ID_WIKIDATA
         AND si.ID_PROPERTY = 'P345'
         AND (si.`RANK` IS NULL OR si.`RANK` <> 'deprecated')
  INNER JOIN T_WC_WIKIDATA_EXTERNAL_ID_VALUE imdb ON imdb.ID_STATEMENT = si.ID_STATEMENT
  INNER JOIN T_WC_TMDB_PERSON T1 ON imdb.VALUE_EXTERNAL_ID = T1.ID_IMDB
  WHERE imdb.VALUE_EXTERNAL_ID LIKE 'nm%'
    AND (T1.ID_WIKIDATA IS NULL OR T1.ID_WIKIDATA = ''
         OR T1.ID_WIKIDATA NOT REGEXP '^Q[0-9]+$')
) c;

-- ---------------------------------------------------------------------------
-- 4. Les fiches encore vides parmi les 235, s'il en reste, pour enqueter.
-- ---------------------------------------------------------------------------
SELECT ID_MOVIE, ID_WIKIDATA, ID_IMDB, TIM_CREDITS_COMPLETED, TIM_UPDATED
FROM T_WC_TMDB_MOVIE
WHERE (ID_WIKIDATA IS NULL OR ID_WIKIDATA = '')
  AND ID_MOVIE IN (
  483090, 505460, 505473, 505488, 505511, 505611, 505640, 505704, 505790, 505832,
  505860, 505895, 505901, 505924, 506169, 506172, 506204, 506218, 506238, 506322,
  506400, 506730, 506732, 506826, 507022, 507034, 507095, 507161, 507190, 507206,
  507299, 507322, 507476, 507502, 507716, 507742, 507781, 507809, 507872, 507938,
  507970, 507987, 508065, 508093, 508204, 508401, 508515, 508528, 508568, 508631,
  508632, 508687, 508709, 508729, 508892, 508921, 509017, 509180, 509213, 509361,
  509370, 509409, 509515, 509529, 509624, 509723, 509739, 509870, 509950, 509975,
  510105, 510189, 510255, 510314, 510535, 510567, 510656, 510657, 510698, 510721,
  510819, 510859, 510942, 511076, 511127, 511270, 511354, 511367, 511685, 511700,
  511702, 511789, 511848, 511882, 511895, 511928, 512027, 512033, 512090, 512112,
  512186, 512533, 512545, 512748, 512755, 512891, 512922, 513046, 513092, 513172,
  513224, 513236, 513286, 513295, 513320, 513323, 513487, 513520, 513536, 513729,
  514222, 514350, 514507, 514637, 514755, 514801, 514851, 514879, 514925, 514955,
  514968, 515013, 515045, 515177, 515300, 515320, 515370, 515392, 515574, 515594,
  515597, 515638, 515677, 515840, 515883, 515946, 516027, 516259, 516304, 516511,
  516593, 516602, 516708, 516713, 516810, 516879, 516907, 516949, 516977, 516986,
  517101, 517113, 517184, 517358, 517461, 517463, 517510, 517628, 517636, 517677,
  517715, 517792, 517847, 517931, 518038, 518075, 518142, 518198, 518240, 518335,
  518411, 518413, 518454, 518462, 518486, 518597, 518727, 518737, 518751, 518793,
  518852, 518893, 519032, 519139, 519157, 519221, 519271, 519591, 519598, 519674,
  519748, 519828, 519893, 519965, 520054, 520103, 520145, 520268, 520343, 520400,
  520403, 520409, 520644, 520696, 520712, 520731, 520836, 520969, 520980, 521010,
  521116, 521154, 521273, 521394, 521413, 521438, 521449, 521639, 521695, 521902,
  521988, 522089, 522116, 522295, 522360
)
ORDER BY ID_MOVIE
LIMIT 40;
