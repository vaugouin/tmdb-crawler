"""
Run-once purge: drop the neighbour rows TMDb stopped returning long ago.

TMDB-CRAWLER-029, the companion of TMDB-CRAWLER-028. Until -028 the four neighbour
writers (movie/serie x similar/recommendations) upserted one row per (owner, neighbour)
and never deleted anything, so each table accumulated the UNION of every top-20 TMDb had
ever returned for a title. Measured 2026-07-28, with MAX(DISPLAY_ORDER) = 20 everywhere,
which proves a single page is ever fetched and therefore that every neighbour past the
twentieth is accumulated history:

    T_WC_TMDB_MOVIE_SIMILAR         2 612 116 rows / 63 445 movies = 41.2 each
    T_WC_TMDB_SERIE_SIMILAR           862 314 rows / 17 290 series = 49.9 each
    T_WC_TMDB_SERIE_RECOMMENDATION    724 367 rows / 31 794 series = 22.8 each

-028 stops the growth but only cleans a title when that title is re-crawled, so cold
titles would keep their dead rows for months. This script does the catch-up in one pass.

HOW THE DEAD ROWS ARE IDENTIFIED
--------------------------------
``TIM_UPDATED``. Verified in ``citizenphil.f_sqlupdatearray``: the field is rewritten on
EVERY upsert, on update as well as on insert. So a neighbour still inside TMDb's top 20 is
rewritten at every crawl and carries a recent date, while a neighbour that dropped out
keeps the date of the last crawl that still listed it. The two populations separate
cleanly.

THE ONE-HOUR WINDOW, AND WHY IT IS NOT A DETAIL
-----------------------------------------------
A row is dead when its ``TIM_UPDATED`` is older than ``MAX(TIM_UPDATED)`` for its owner
MINUS one hour. The window is load-bearing: the rows of a single crawl are written a few
seconds apart, so a strict ``< MAX`` would delete rows belonging to the very last crawl.
Two crawls of the same title are days apart, so an hour sits comfortably inside the gap
without ever reaching into the previous crawl. Do not tighten it without re-measuring.

Consequence worth stating: every title keeps at least its last crawl, so no title can end
up with zero neighbours. That is checked and reported at the end.

NULL ``TIM_UPDATED`` rows are LEFT ALONE. They cannot be dated, and deleting what you
cannot date is how a purge turns into data loss. They are counted and reported instead.

USAGE
-----
Dry run first (default, touches nothing), then the real thing::

    docker run --rm --network="host" --env-file .env \
        tmdb-crawler-python-app python ./purge_stale_neighbours.py
    docker run --rm --network="host" --env-file .env \
        tmdb-crawler-python-app python ./purge_stale_neighbours.py --apply

Deletes run in chunks of owner ids (``--chunk``, default 5000), one commit per chunk, same
reasoning as the chunked passes in tmdb-movie-preprocess: these tables hold millions of
rows and a single transaction would hold a write lock far too long.

DEPLOY -028 FIRST. The order matters, the delay does not: purging while the old code is
still crawling gives you a clean database for a few hours, then the next crawl restarts the
accumulation from scratch and the purge has to be repeated for ever. Bailing out a boat
without plugging the leak. The two are otherwise independent, this script relies only on
TIM_UPDATED, which the old code wrote too, so -028 can be deployed in the morning and this
run in the afternoon.

There IS one good reason to wait a little, and it is about trusting the fix rather than the
purge: check that -028 actually works before an irreversible mass delete. That needs one
title to have been re-crawled, not several days. House of the Dragon (ID_SERIE 94997) sat at
392 neighbours on 2026-07-28 and is popular enough to be crawled often; if that count falls
to around 20 on its own, -028 is doing its job.
"""

import argparse
import sys

import citizenphil as cp


# One entry per neighbour table: the owner column the rows hang off, and the neighbour
# column that completes the pair. Order is deliberate, the two largest tables first, so a
# run interrupted midway has already dealt with the bulk.
NEIGHBOUR_TABLES = [
    {"table": "T_WC_TMDB_MOVIE_SIMILAR", "owner": "ID_MOVIE", "neighbour": "ID_MOVIE_SIMILAR"},
    {"table": "T_WC_TMDB_SERIE_SIMILAR", "owner": "ID_SERIE", "neighbour": "ID_SERIE_SIMILAR"},
    {"table": "T_WC_TMDB_MOVIE_RECOMMENDATION", "owner": "ID_MOVIE", "neighbour": "ID_MOVIE_RECOMMENDED"},
    {"table": "T_WC_TMDB_SERIE_RECOMMENDATION", "owner": "ID_SERIE", "neighbour": "ID_SERIE_RECOMMENDED"},
]

WINDOW = "INTERVAL 1 HOUR"


def f_tablesnapshot(cursor, strtable, strowner):
    """Row count, distinct owners, average per owner and max rank for one table."""
    cursor.execute(
        f"""
        SELECT COUNT(*) AS LIGNES,
               COUNT(DISTINCT {strowner}) AS PROPRIETAIRES,
               MAX(DISPLAY_ORDER) AS RANG_MAX,
               SUM(TIM_UPDATED IS NULL) AS SANS_DATE
        FROM {strtable}
        WHERE DELETED IS NULL OR DELETED = 0
        """
    )
    row = cursor.fetchone() or {}
    lnglignes = row.get("LIGNES") or 0
    lngproprietaires = row.get("PROPRIETAIRES") or 0
    return {
        "lignes": lnglignes,
        "proprietaires": lngproprietaires,
        "moyenne": (lnglignes / lngproprietaires) if lngproprietaires else 0,
        "rang_max": row.get("RANG_MAX"),
        "sans_date": row.get("SANS_DATE") or 0,
    }


def f_countstale(cursor, strtable, strowner):
    """How many rows the purge would remove, without removing anything."""
    cursor.execute(
        f"""
        SELECT COUNT(*) AS A_SUPPRIMER
        FROM {strtable} nb
        INNER JOIN (
            SELECT {strowner} AS OWNER_ID, MAX(TIM_UPDATED) AS DERNIER_CRAWL
            FROM {strtable}
            GROUP BY {strowner}
        ) dernier ON dernier.OWNER_ID = nb.{strowner}
        WHERE nb.TIM_UPDATED IS NOT NULL
          AND nb.TIM_UPDATED < dernier.DERNIER_CRAWL - {WINDOW}
        """
    )
    row = cursor.fetchone() or {}
    return row.get("A_SUPPRIMER") or 0


def f_ownerrange(cursor, strtable, strowner):
    cursor.execute(f"SELECT MIN({strowner}) AS MINI, MAX({strowner}) AS MAXI FROM {strtable}")
    row = cursor.fetchone() or {}
    return (row.get("MINI") or 0), (row.get("MAXI") or 0)


def f_purgetable(connection, cursor, strtable, strowner, lngchunk, blnapply):
    """Delete the stale rows of one table, in chunks of owner ids."""
    lngmini, lngmaxi = f_ownerrange(cursor, strtable, strowner)
    if lngmaxi <= 0:
        print(f"  {strtable}: empty, nothing to do")
        return 0
    lngdeleted = 0
    for lngstart in range(lngmini, lngmaxi + 1, lngchunk):
        lngend = min(lngstart + lngchunk - 1, lngmaxi)
        # The derived MAX is restricted to the same id range as the delete. That is safe
        # because an owner never straddles two ranges, so its per-owner maximum is the same
        # whether computed on the range or on the whole table, and it keeps the subquery
        # from scanning millions of rows on every chunk.
        strsql = f"""
DELETE nb FROM {strtable} nb
INNER JOIN (
    SELECT {strowner} AS OWNER_ID, MAX(TIM_UPDATED) AS DERNIER_CRAWL
    FROM {strtable}
    WHERE {strowner} BETWEEN %s AND %s
    GROUP BY {strowner}
) dernier ON dernier.OWNER_ID = nb.{strowner}
WHERE nb.{strowner} BETWEEN %s AND %s
  AND nb.TIM_UPDATED IS NOT NULL
  AND nb.TIM_UPDATED < dernier.DERNIER_CRAWL - {WINDOW}
"""
        if not blnapply:
            continue
        cursor.execute(strsql, (lngstart, lngend, lngstart, lngend))
        lngchunkdeleted = cursor.rowcount or 0
        connection.commit()
        lngdeleted += lngchunkdeleted
        if lngchunkdeleted:
            print(f"  {strtable}: {lngstart}-{lngend} -> {lngchunkdeleted} row(s) removed")
    return lngdeleted


def f_orphancheck(cursor, strtable, strowner):
    """Owners left with zero neighbours. Must stay at whatever it was before the purge:
    the window guarantees each owner keeps its last crawl, so this should not move."""
    cursor.execute(f"SELECT COUNT(DISTINCT {strowner}) AS PROPRIETAIRES FROM {strtable}")
    row = cursor.fetchone() or {}
    return row.get("PROPRIETAIRES") or 0


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[1])
    parser.add_argument("--apply", action="store_true",
                        help="actually delete; without it the script only measures")
    parser.add_argument("--chunk", type=int, default=5000,
                        help="owner-id range per transaction (default 5000)")
    parser.add_argument("--table", action="append", default=None,
                        help="restrict to one table, repeatable")
    args = parser.parse_args()

    arrtables = NEIGHBOUR_TABLES
    if args.table:
        arrtables = [t for t in NEIGHBOUR_TABLES if t["table"] in args.table]
        if not arrtables:
            print(f"No known neighbour table among {args.table}")
            return 1

    connection = cp.f_getconnection()
    cursor = connection.cursor()

    print("=" * 78)
    print("BEFORE" if args.apply else "DRY RUN (nothing will be deleted)")
    print("=" * 78)
    arrbefore = {}
    for entry in arrtables:
        snap = f_tablesnapshot(cursor, entry["table"], entry["owner"])
        stale = f_countstale(cursor, entry["table"], entry["owner"])
        owners = f_orphancheck(cursor, entry["table"], entry["owner"])
        arrbefore[entry["table"]] = {"snap": snap, "stale": stale, "owners": owners}
        print(f"{entry['table']}")
        print(f"  rows {snap['lignes']:>10}   owners {snap['proprietaires']:>8}"
              f"   avg {snap['moyenne']:>6.1f}   max rank {snap['rang_max']}")
        if snap["lignes"]:
            dblshare = 100.0 * stale / snap["lignes"]
            print(f"  stale rows to remove: {stale:>10}   ({dblshare:.1f}% of the table)")
        if snap["sans_date"]:
            print(f"  rows with a NULL TIM_UPDATED, left untouched: {snap['sans_date']}")

    if not args.apply:
        print()
        print("Dry run only. Re-run with --apply to delete, once TMDB-CRAWLER-028 has been")
        print("crawling for a few days (otherwise the accumulation restarts immediately).")
        return 0

    print()
    print("=" * 78)
    print("PURGING")
    print("=" * 78)
    for entry in arrtables:
        lngdeleted = f_purgetable(connection, cursor, entry["table"], entry["owner"],
                                  args.chunk, True)
        print(f"{entry['table']}: {lngdeleted} row(s) removed in total")

    print()
    print("=" * 78)
    print("AFTER")
    print("=" * 78)
    intfailures = 0
    for entry in arrtables:
        snap = f_tablesnapshot(cursor, entry["table"], entry["owner"])
        owners = f_orphancheck(cursor, entry["table"], entry["owner"])
        before = arrbefore[entry["table"]]
        print(f"{entry['table']}")
        print(f"  rows {before['snap']['lignes']:>10} -> {snap['lignes']:>10}"
              f"   avg {before['snap']['moyenne']:>6.1f} -> {snap['moyenne']:>6.1f}")
        # The load-bearing check: the purge must never cost a title ALL of its neighbours.
        # The one-hour window makes that impossible in theory; this proves it in practice.
        if owners < before["owners"]:
            print(f"  !! {before['owners'] - owners} owner(s) lost every neighbour."
                  f" That must not happen, investigate before running the next table.")
            intfailures += 1
        else:
            print(f"  owners with neighbours unchanged: {owners}")
    return 1 if intfailures else 0


if __name__ == "__main__":
    sys.exit(main())
