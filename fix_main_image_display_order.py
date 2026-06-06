"""
Run-once migration: pin each content's main image(s) to DISPLAY_ORDER 0.

For every TMDb image table this script enforces two invariants for the "main"
image(s) referenced by the master record (e.g. T_WC_TMDB_MOVIE.POSTER_PATH) and
by the per-language table when one exists (e.g. the French POSTER_PATH in
T_WC_TMDB_MOVIE_LANG):

  1. Every main image always sits at DISPLAY_ORDER = 0 (both the base/English
     image and each localized image).
  2. Each main image is never deleted: it is undeleted (DELETED = 0) and
     inserted if it is missing from the image table entirely.

It also frees position 0 by renumbering any *other* (non-main) row that
currently occupies DISPLAY_ORDER 0 to the end of that content's ordering.

The script is idempotent and safe to re-run. It is intended to be executed
once inside the project's Docker container, e.g.:

    docker run --rm --network="host" --env-file .env \
        tmdb-crawler-python-app python ./fix_main_image_display_order.py

Database connection settings are read from the same environment variables as
the crawler (DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME).
"""

import pymysql

import citizenphil as cp


# Each entry describes one image table and the master column holding its main
# image path. ``lang_table`` (optional) names a per-language table carrying the
# same column for localized main images (keyed by id_field, with a LANG column).
# ``extra_fields`` lists additional NOT NULL id columns that must be copied from
# the source table when inserting a missing main-image row.
IMAGE_TABLE_CONFIG = [
    {
        "master_table": "T_WC_TMDB_MOVIE",
        "image_table": "T_WC_TMDB_MOVIE_IMAGE",
        "id_field": "ID_MOVIE",
        "main_field": "POSTER_PATH",
        "main_type": "poster",
        "extra_fields": [],
        "lang_table": "T_WC_TMDB_MOVIE_LANG",
    },
    {
        "master_table": "T_WC_TMDB_PERSON",
        "image_table": "T_WC_TMDB_PERSON_IMAGE",
        "id_field": "ID_PERSON",
        "main_field": "PROFILE_PATH",
        "main_type": "profile",
        "extra_fields": [],
        "lang_table": None,
    },
    {
        "master_table": "T_WC_TMDB_SERIE",
        "image_table": "T_WC_TMDB_SERIE_IMAGE",
        "id_field": "ID_SERIE",
        "main_field": "POSTER_PATH",
        "main_type": "poster",
        "extra_fields": [],
        "lang_table": "T_WC_TMDB_SERIE_LANG",
    },
    {
        "master_table": "T_WC_TMDB_COLLECTION",
        "image_table": "T_WC_TMDB_COLLECTION_IMAGE",
        "id_field": "ID_COLLECTION",
        "main_field": "POSTER_PATH",
        "main_type": "poster",
        "extra_fields": [],
        "lang_table": "T_WC_TMDB_COLLECTION_LANG",
    },
    {
        "master_table": "T_WC_TMDB_COMPANY",
        "image_table": "T_WC_TMDB_COMPANY_IMAGE",
        "id_field": "ID_COMPANY",
        "main_field": "LOGO_PATH",
        "main_type": "logo",
        "extra_fields": [],
        "lang_table": None,
    },
    {
        "master_table": "T_WC_TMDB_NETWORK",
        "image_table": "T_WC_TMDB_NETWORK_IMAGE",
        "id_field": "ID_NETWORK",
        "main_field": "LOGO_PATH",
        "main_type": "logo",
        "extra_fields": [],
        "lang_table": None,
    },
    {
        "master_table": "T_WC_TMDB_SEASON",
        "image_table": "T_WC_TMDB_SEASON_IMAGE",
        "id_field": "ID_SEASON",
        "main_field": "POSTER_PATH",
        "main_type": "poster",
        "extra_fields": ["ID_SERIE"],
        "lang_table": None,
    },
    {
        "master_table": "T_WC_TMDB_EPISODE",
        "image_table": "T_WC_TMDB_EPISODE_IMAGE",
        "id_field": "ID_EPISODE",
        "main_field": "STILL_PATH",
        "main_type": "still",
        "extra_fields": ["ID_SEASON", "ID_SERIE"],
        "lang_table": None,
    },
]


def f_main_image_sources(config):
    """Return the list of (source_table, lang_sql) providing main image paths.

    The master record always provides the base/English image. A per-language
    table (when configured) provides localized images, tagged with its own LANG
    column. ``lang_sql`` is the SQL expression used for the LANG value on insert.
    """
    sources = [(config["master_table"], "'en'")]
    if config.get("lang_table"):
        sources.append((config["lang_table"], "s.LANG"))
    return sources


def f_renumber_colliding_zero_rows(cursor, config):
    """Move non-main rows currently at DISPLAY_ORDER 0 to the end of their group.

    A row is considered "main" when its TYPE_IMAGE matches and its IMAGE_PATH
    matches the main path from any source (master or per-language). Only content
    rows that actually have at least one main image are touched, so position 0 is
    freed precisely where a main image will be pinned. The new order value is
    MAX(DISPLAY_ORDER) + ID_ROW, unique within the group and beyond every
    existing position.
    """
    image_table = config["image_table"]
    id_field = config["id_field"]
    main_field = config["main_field"]
    main_type = config["main_type"]
    sources = f_main_image_sources(config)

    # "This row is one of the main images" — path matches any source.
    path_match = " OR ".join(
        f"EXISTS (SELECT 1 FROM {src} s WHERE s.{id_field} = i.{id_field} "
        f"AND s.{main_field} IS NOT NULL AND s.{main_field} <> '' "
        f"AND i.IMAGE_PATH = s.{main_field})"
        for src, _lang in sources
    )
    # "This content has at least one main image" — guard against pointless churn.
    has_main = " OR ".join(
        f"EXISTS (SELECT 1 FROM {src} s WHERE s.{id_field} = i.{id_field} "
        f"AND s.{main_field} IS NOT NULL AND s.{main_field} <> '')"
        for src, _lang in sources
    )

    strsql = f"""
UPDATE {image_table} i
JOIN (
    SELECT {id_field} AS gid, MAX(DISPLAY_ORDER) AS maxord
    FROM {image_table}
    GROUP BY {id_field}
) g ON g.gid = i.{id_field}
SET i.DISPLAY_ORDER = g.maxord + i.ID_ROW,
    i.TIM_UPDATED = NOW()
WHERE i.DISPLAY_ORDER = 0
  AND ({has_main})
  AND NOT (i.TYPE_IMAGE = '{main_type}' AND ({path_match}))
"""
    cursor.execute(strsql)
    return cursor.rowcount


def f_pin_existing_main_images(cursor, config):
    """Force every existing main-image row to DISPLAY_ORDER 0 and undelete it."""
    image_table = config["image_table"]
    id_field = config["id_field"]
    main_field = config["main_field"]
    main_type = config["main_type"]

    total = 0
    for src, _lang in f_main_image_sources(config):
        strsql = f"""
UPDATE {image_table} i
JOIN {src} s ON s.{id_field} = i.{id_field}
SET i.DISPLAY_ORDER = 0,
    i.DELETED = 0,
    i.TIM_UPDATED = NOW()
WHERE s.{main_field} IS NOT NULL
  AND s.{main_field} <> ''
  AND i.TYPE_IMAGE = '{main_type}'
  AND i.IMAGE_PATH = s.{main_field}
"""
        cursor.execute(strsql)
        total += cursor.rowcount
    return total


def f_insert_missing_main_images(cursor, config):
    """Insert each main image at DISPLAY_ORDER 0 when it is absent from the table."""
    image_table = config["image_table"]
    id_field = config["id_field"]
    main_field = config["main_field"]
    main_type = config["main_type"]
    extra_fields = config["extra_fields"]

    strextracols = "".join(f", {col}" for col in extra_fields)
    strextraselect = "".join(f", s.{col}" for col in extra_fields)

    total = 0
    for src, lang_sql in f_main_image_sources(config):
        strsql = f"""
INSERT INTO {image_table}
    ({id_field}{strextracols}, IMAGE_PATH, TYPE_IMAGE, DISPLAY_ORDER, DELETED, DAT_CREAT, TIM_UPDATED, LANG)
SELECT s.{id_field}{strextraselect}, s.{main_field}, '{main_type}', 0, 0, CURDATE(), NOW(), {lang_sql}
FROM {src} s
LEFT JOIN {image_table} i
  ON i.{id_field} = s.{id_field}
 AND i.TYPE_IMAGE = '{main_type}'
 AND i.IMAGE_PATH = s.{main_field}
WHERE s.{main_field} IS NOT NULL
  AND s.{main_field} <> ''
  AND i.ID_ROW IS NULL
"""
        cursor.execute(strsql)
        total += cursor.rowcount
    return total


def f_process_table(connection, config):
    """Apply all three fixes to one image table inside a single transaction."""
    image_table = config["image_table"]
    langnote = f" (+ {config['lang_table']})" if config.get("lang_table") else ""
    print(f"\n=== {image_table}{langnote} ===")
    cursor = connection.cursor()

    lngrenumbered = f_renumber_colliding_zero_rows(cursor, config)
    print(f"  Renumbered non-main rows away from position 0 : {lngrenumbered}")

    lngpinned = f_pin_existing_main_images(cursor, config)
    print(f"  Pinned existing main images to position 0      : {lngpinned}")

    lnginserted = f_insert_missing_main_images(cursor, config)
    print(f"  Inserted missing main images at position 0     : {lnginserted}")

    connection.commit()
    return lngrenumbered, lngpinned, lnginserted


def main():
    connection = cp.f_getconnection()
    print("Starting main-image DISPLAY_ORDER migration for all image tables.")

    totals = {"renumbered": 0, "pinned": 0, "inserted": 0}
    try:
        for config in IMAGE_TABLE_CONFIG:
            lngrenumbered, lngpinned, lnginserted = f_process_table(connection, config)
            totals["renumbered"] += lngrenumbered
            totals["pinned"] += lngpinned
            totals["inserted"] += lnginserted
    except pymysql.MySQLError as e:
        connection.rollback()
        cp.f_handlemysqlerror(e, "fix_main_image_display_order")
        raise

    print("\n=== Migration complete ===")
    print(f"  Total rows renumbered off position 0 : {totals['renumbered']}")
    print(f"  Total main images pinned to 0        : {totals['pinned']}")
    print(f"  Total main images inserted at 0      : {totals['inserted']}")


if __name__ == "__main__":
    main()
