"""
Run-once migration: pin each content's main image to DISPLAY_ORDER 0.

For every TMDb image table this script enforces two invariants for the "main"
image referenced by the master record (e.g. T_WC_TMDB_MOVIE.POSTER_PATH):

  1. The main image always sits at DISPLAY_ORDER = 0.
  2. The main image is never deleted: it is undeleted (DELETED = 0) and
     inserted if it is missing from the image table entirely.

It also frees position 0 for the main image by renumbering any *other*
(non-main) row that currently occupies DISPLAY_ORDER 0 to the end of that
content's ordering.

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
# image path. ``extra_fields`` lists additional NOT NULL id columns that must be
# copied from the master table when inserting a missing main-image row.
IMAGE_TABLE_CONFIG = [
    {
        "master_table": "T_WC_TMDB_MOVIE",
        "image_table": "T_WC_TMDB_MOVIE_IMAGE",
        "id_field": "ID_MOVIE",
        "main_field": "POSTER_PATH",
        "main_type": "poster",
        "extra_fields": [],
    },
    {
        "master_table": "T_WC_TMDB_PERSON",
        "image_table": "T_WC_TMDB_PERSON_IMAGE",
        "id_field": "ID_PERSON",
        "main_field": "PROFILE_PATH",
        "main_type": "profile",
        "extra_fields": [],
    },
    {
        "master_table": "T_WC_TMDB_SERIE",
        "image_table": "T_WC_TMDB_SERIE_IMAGE",
        "id_field": "ID_SERIE",
        "main_field": "POSTER_PATH",
        "main_type": "poster",
        "extra_fields": [],
    },
    {
        "master_table": "T_WC_TMDB_COLLECTION",
        "image_table": "T_WC_TMDB_COLLECTION_IMAGE",
        "id_field": "ID_COLLECTION",
        "main_field": "POSTER_PATH",
        "main_type": "poster",
        "extra_fields": [],
    },
    {
        "master_table": "T_WC_TMDB_COMPANY",
        "image_table": "T_WC_TMDB_COMPANY_IMAGE",
        "id_field": "ID_COMPANY",
        "main_field": "LOGO_PATH",
        "main_type": "logo",
        "extra_fields": [],
    },
    {
        "master_table": "T_WC_TMDB_NETWORK",
        "image_table": "T_WC_TMDB_NETWORK_IMAGE",
        "id_field": "ID_NETWORK",
        "main_field": "LOGO_PATH",
        "main_type": "logo",
        "extra_fields": [],
    },
    {
        "master_table": "T_WC_TMDB_SEASON",
        "image_table": "T_WC_TMDB_SEASON_IMAGE",
        "id_field": "ID_SEASON",
        "main_field": "POSTER_PATH",
        "main_type": "poster",
        "extra_fields": ["ID_SERIE"],
    },
    {
        "master_table": "T_WC_TMDB_EPISODE",
        "image_table": "T_WC_TMDB_EPISODE_IMAGE",
        "id_field": "ID_EPISODE",
        "main_field": "STILL_PATH",
        "main_type": "still",
        "extra_fields": ["ID_SEASON", "ID_SERIE"],
    },
]


def f_renumber_colliding_zero_rows(cursor, config):
    """Move non-main rows currently at DISPLAY_ORDER 0 to the end of their group.

    Only content rows that actually have a main image are touched, so position 0
    is freed precisely where the main image will be pinned. The new order value
    is MAX(DISPLAY_ORDER) + ID_ROW, which is guaranteed to be unique within the
    group and beyond every existing position.
    """
    image_table = config["image_table"]
    master_table = config["master_table"]
    id_field = config["id_field"]
    main_field = config["main_field"]
    main_type = config["main_type"]

    strsql = f"""
UPDATE {image_table} i
JOIN {master_table} m ON m.{id_field} = i.{id_field}
JOIN (
    SELECT {id_field} AS gid, MAX(DISPLAY_ORDER) AS maxord
    FROM {image_table}
    GROUP BY {id_field}
) g ON g.gid = i.{id_field}
SET i.DISPLAY_ORDER = g.maxord + i.ID_ROW,
    i.TIM_UPDATED = NOW()
WHERE i.DISPLAY_ORDER = 0
  AND m.{main_field} IS NOT NULL
  AND m.{main_field} <> ''
  AND NOT (i.TYPE_IMAGE = '{main_type}' AND i.IMAGE_PATH = m.{main_field})
"""
    cursor.execute(strsql)
    return cursor.rowcount


def f_pin_existing_main_image(cursor, config):
    """Force every existing main-image row to DISPLAY_ORDER 0 and undelete it."""
    image_table = config["image_table"]
    master_table = config["master_table"]
    id_field = config["id_field"]
    main_field = config["main_field"]
    main_type = config["main_type"]

    strsql = f"""
UPDATE {image_table} i
JOIN {master_table} m ON m.{id_field} = i.{id_field}
SET i.DISPLAY_ORDER = 0,
    i.DELETED = 0,
    i.TIM_UPDATED = NOW()
WHERE m.{main_field} IS NOT NULL
  AND m.{main_field} <> ''
  AND i.TYPE_IMAGE = '{main_type}'
  AND i.IMAGE_PATH = m.{main_field}
"""
    cursor.execute(strsql)
    return cursor.rowcount


def f_insert_missing_main_image(cursor, config):
    """Insert the main image at DISPLAY_ORDER 0 when it is absent from the table."""
    image_table = config["image_table"]
    master_table = config["master_table"]
    id_field = config["id_field"]
    main_field = config["main_field"]
    main_type = config["main_type"]
    extra_fields = config["extra_fields"]

    strextracols = "".join(f", {col}" for col in extra_fields)
    strextraselect = "".join(f", m.{col}" for col in extra_fields)

    strsql = f"""
INSERT INTO {image_table}
    ({id_field}{strextracols}, IMAGE_PATH, TYPE_IMAGE, DISPLAY_ORDER, DELETED, DAT_CREAT, TIM_UPDATED, LANG)
SELECT m.{id_field}{strextraselect}, m.{main_field}, '{main_type}', 0, 0, CURDATE(), NOW(), 'en'
FROM {master_table} m
LEFT JOIN {image_table} i
  ON i.{id_field} = m.{id_field}
 AND i.TYPE_IMAGE = '{main_type}'
 AND i.IMAGE_PATH = m.{main_field}
WHERE m.{main_field} IS NOT NULL
  AND m.{main_field} <> ''
  AND i.ID_ROW IS NULL
"""
    cursor.execute(strsql)
    return cursor.rowcount


def f_process_table(connection, config):
    """Apply all three fixes to one image table inside a single transaction."""
    image_table = config["image_table"]
    print(f"\n=== {image_table} ===")
    cursor = connection.cursor()

    lngrenumbered = f_renumber_colliding_zero_rows(cursor, config)
    print(f"  Renumbered non-main rows away from position 0 : {lngrenumbered}")

    lngpinned = f_pin_existing_main_image(cursor, config)
    print(f"  Pinned existing main images to position 0      : {lngpinned}")

    lnginserted = f_insert_missing_main_image(cursor, config)
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
