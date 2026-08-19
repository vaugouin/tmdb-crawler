import unittest
from unittest import mock

import tmdb_functions as tf


class FakeCursor:
    def __init__(self, fail_on_executemany=False):
        self.fail_on_executemany = fail_on_executemany
        self.execute_calls = []
        self.executemany_calls = []

    def execute(self, sql, params=None):
        self.execute_calls.append((sql, params))

    def executemany(self, sql, rows):
        if self.fail_on_executemany:
            raise RuntimeError("simulated insert failure")
        self.executemany_calls.append((sql, rows))


class FakeConnection:
    def __init__(self, fail_on_executemany=False):
        self.cursor_instance = FakeCursor(fail_on_executemany)
        self.begin_count = 0
        self.commit_count = 0
        self.rollback_count = 0

    def cursor(self):
        return self.cursor_instance

    def begin(self):
        self.begin_count += 1

    def commit(self):
        self.commit_count += 1

    def rollback(self):
        self.rollback_count += 1


class AvailabilityParsingTests(unittest.TestCase):
    def test_release_dates_keep_every_source_field(self):
        payload = {
            "results": [{
                "iso_3166_1": "FR",
                "release_dates": [{
                    "certification": "12",
                    "descriptors": ["Violence"],
                    "iso_639_1": "fr",
                    "note": "Festival premiere",
                    "release_date": "2026-08-19T21:30:00.000Z",
                    "type": 1,
                }, {
                    "certification": "",
                    "descriptors": [],
                    "iso_639_1": None,
                    "note": "",
                    "release_date": "2026-08-20T00:00:00.000+02:00",
                    "type": 3,
                }],
            }]
        }

        rows = tf._f_tmdbbuildmoviereleasedaterows(42, payload, "2026-08-19 22:00:00")

        self.assertEqual(2, len(rows))
        self.assertEqual("FR", rows[0][1])
        self.assertEqual("fr", rows[0][2])
        self.assertEqual("12", rows[0][3])
        self.assertEqual("Festival premiere", rows[0][4])
        self.assertEqual("2026-08-19T21:30:00.000Z", rows[0][5])
        self.assertEqual("2026-08-19 21:30:00", rows[0][6])
        self.assertEqual(1, rows[0][7])
        self.assertEqual('["Violence"]', rows[0][8])
        self.assertEqual("2026-08-19 22:00:00", rows[1][6])

    def test_watch_providers_keep_country_mode_provider_and_tmdb_link(self):
        payload = {
            "results": {
                "FR": {
                    "link": "https://www.themoviedb.org/movie/42/watch?locale=FR",
                    "flatrate": [{
                        "logo_path": "/logo.jpg",
                        "provider_id": 8,
                        "provider_name": "Netflix",
                        "display_priority": 1,
                    }],
                    "rent": [{
                        "logo_path": "/rent.jpg",
                        "provider_id": 2,
                        "provider_name": "Rental",
                        "display_priority": 4,
                    }],
                }
            }
        }

        rows = tf._f_tmdbbuildwatchproviderrows(42, payload, "2026-08-19 22:00:00")

        self.assertEqual(2, len(rows))
        self.assertEqual((42, "FR", "flatrate", 8), rows[0][:4])
        self.assertEqual("https://www.themoviedb.org/movie/42/watch?locale=FR", rows[0][7])
        self.assertEqual("rent", rows[1][2])

    def test_incomplete_payload_is_rejected_before_database_replacement(self):
        with self.assertRaises(ValueError):
            tf._f_tmdbbuildmoviereleasedaterows(42, {"id": 42}, "2026-08-19 22:00:00")
        with self.assertRaises(ValueError):
            tf._f_tmdbbuildwatchproviderrows(42, {"results": []}, "2026-08-19 22:00:00")

    def test_provider_catalog_separates_identity_membership_and_region_priority(self):
        payload = {
            "results": [{
                "display_priorities": {"FR": 1, "CA": 6},
                "logo_path": "/netflix.jpg",
                "provider_name": "Netflix",
                "provider_id": 8,
            }, {
                "display_priorities": {},
                "logo_path": None,
                "provider_name": "A provider without a regional priority",
                "provider_id": 999,
            }]
        }

        catalog_rows, region_rows = tf._f_tmdbbuildwatchprovidercatalogrows(
            "movie", payload, "2026-08-19 22:00:00")

        self.assertEqual(2, len(catalog_rows))
        self.assertEqual((8, "movie", "Netflix", "/netflix.jpg"), catalog_rows[0][:4])
        self.assertEqual(2, len(region_rows))
        self.assertEqual((8, "movie", "FR", 1), region_rows[0][:4])
        self.assertEqual((8, "movie", "CA", 6), region_rows[1][:4])

    def test_empty_or_duplicate_provider_catalog_is_rejected(self):
        with self.assertRaises(ValueError):
            tf._f_tmdbbuildwatchprovidercatalogrows(
                "movie", {"results": []}, "2026-08-19 22:00:00")
        duplicate_payload = {"results": [{
            "provider_id": 8, "provider_name": "Netflix", "logo_path": "/one.jpg",
            "display_priorities": {"FR": 1},
        }, {
            "provider_id": 8, "provider_name": "Netflix", "logo_path": "/two.jpg",
            "display_priorities": {"US": 2},
        }]}
        with self.assertRaises(ValueError):
            tf._f_tmdbbuildwatchprovidercatalogrows(
                "serie", duplicate_payload, "2026-08-19 22:00:00")


class AvailabilityTransactionTests(unittest.TestCase):
    def test_snapshot_replace_deletes_inserts_marks_and_commits_once(self):
        fake_connection = FakeConnection()
        rows = [(42, "FR")]
        with mock.patch.object(tf, "connectioncp", fake_connection), \
             mock.patch.object(tf, "f_tmdbavailabilityensuretables", return_value=True):
            result = tf._f_tmdbreplaceadditivesnapshot(
                "T_WC_TMDB_TEST", "ID_MOVIE", 42, ("ID_MOVIE", "COUNTRY_CODE"), rows,
                "T_WC_TMDB_MOVIE", "TIM_TEST_COMPLETED", "test snapshot")

        self.assertTrue(result)
        self.assertEqual(1, fake_connection.begin_count)
        self.assertEqual(1, fake_connection.commit_count)
        self.assertEqual(0, fake_connection.rollback_count)
        self.assertIn("DELETE FROM `T_WC_TMDB_TEST`", fake_connection.cursor_instance.execute_calls[0][0])
        self.assertEqual(rows, fake_connection.cursor_instance.executemany_calls[0][1])
        self.assertIn("TIM_TEST_COMPLETED", fake_connection.cursor_instance.execute_calls[-1][0])

    def test_database_error_rolls_back_and_preserves_snapshot(self):
        fake_connection = FakeConnection(fail_on_executemany=True)
        with mock.patch.object(tf, "connectioncp", fake_connection), \
             mock.patch.object(tf, "f_tmdbavailabilityensuretables", return_value=True):
            result = tf._f_tmdbreplaceadditivesnapshot(
                "T_WC_TMDB_TEST", "ID_MOVIE", 42, ("ID_MOVIE",), [(42,)],
                "T_WC_TMDB_MOVIE", "TIM_TEST_COMPLETED", "test snapshot")

        self.assertFalse(result)
        self.assertEqual(0, fake_connection.commit_count)
        self.assertEqual(1, fake_connection.rollback_count)

    def test_successful_empty_snapshot_clears_old_rows_and_marks_completion(self):
        fake_connection = FakeConnection()
        with mock.patch.object(tf, "connectioncp", fake_connection), \
             mock.patch.object(tf, "f_tmdbavailabilityensuretables", return_value=True):
            result = tf._f_tmdbreplaceadditivesnapshot(
                "T_WC_TMDB_TEST", "ID_MOVIE", 42, ("ID_MOVIE",), [],
                "T_WC_TMDB_MOVIE", "TIM_TEST_COMPLETED", "empty snapshot")

        self.assertTrue(result)
        self.assertEqual([], fake_connection.cursor_instance.executemany_calls)
        self.assertEqual(2, len(fake_connection.cursor_instance.execute_calls))
        self.assertIn("DELETE FROM `T_WC_TMDB_TEST`", fake_connection.cursor_instance.execute_calls[0][0])
        self.assertIn("TIM_TEST_COMPLETED", fake_connection.cursor_instance.execute_calls[1][0])
        self.assertEqual(1, fake_connection.commit_count)

    def test_provider_catalog_replace_is_atomic_and_rebuilds_identity(self):
        fake_connection = FakeConnection()
        catalog_rows = [(8, "movie", "Netflix", "/netflix.jpg", 1,
                         "2026-08-19 22:00:00", 0, "2026-08-19", "2026-08-19 22:00:00")]
        region_rows = [(8, "movie", "FR", 1, 1,
                        "2026-08-19 22:00:00", 0, "2026-08-19", "2026-08-19 22:00:00")]
        with mock.patch.object(tf, "connectioncp", fake_connection), \
             mock.patch.object(tf, "f_tmdbavailabilityensuretables", return_value=True):
            result = tf._f_tmdbreplacewatchprovidercatalog(
                "movie", catalog_rows, region_rows, "2026-08-19 22:00:00")

        self.assertTrue(result)
        self.assertEqual(1, fake_connection.begin_count)
        self.assertEqual(1, fake_connection.commit_count)
        self.assertEqual(0, fake_connection.rollback_count)
        self.assertEqual(2, len(fake_connection.cursor_instance.executemany_calls))
        executed_sql = "\n".join(call[0] for call in fake_connection.cursor_instance.execute_calls)
        self.assertIn("DELETE FROM `T_WC_TMDB_WATCH_PROVIDER_REGION`", executed_sql)
        self.assertIn("DELETE FROM `T_WC_TMDB_WATCH_PROVIDER_CATALOG`", executed_sql)
        self.assertIn("T_WC_TMDB_WATCH_PROVIDER_CATALOG_STATE", executed_sql)
        self.assertIn("ON DUPLICATE KEY UPDATE", executed_sql)

    def test_provider_catalog_database_error_preserves_previous_catalog(self):
        fake_connection = FakeConnection(fail_on_executemany=True)
        catalog_rows = [(8, "movie", "Netflix", "/netflix.jpg", 1,
                         "2026-08-19 22:00:00", 0, "2026-08-19", "2026-08-19 22:00:00")]
        with mock.patch.object(tf, "connectioncp", fake_connection), \
             mock.patch.object(tf, "f_tmdbavailabilityensuretables", return_value=True):
            result = tf._f_tmdbreplacewatchprovidercatalog(
                "movie", catalog_rows, [], "2026-08-19 22:00:00")

        self.assertFalse(result)
        self.assertEqual(0, fake_connection.commit_count)
        self.assertEqual(1, fake_connection.rollback_count)


class ProviderCatalogFetchTests(unittest.TestCase):
    @staticmethod
    def _payload(provider_id):
        return {"results": [{
            "provider_id": provider_id,
            "provider_name": f"Provider {provider_id}",
            "logo_path": f"/{provider_id}.jpg",
            "display_priorities": {"FR": 1},
        }]}

    def test_global_movie_and_tv_catalog_endpoints_are_both_fetched(self):
        fetched_urls = []

        def fake_fetch(url, _context):
            fetched_urls.append(url)
            return self._payload(8 if url.endswith("/movie?language=en-US") else 9)

        with mock.patch.object(tf, "strtmdbapidomainurl", "https://api.themoviedb.org"), \
             mock.patch.object(tf, "f_tmdbfetchjson", side_effect=fake_fetch), \
             mock.patch.object(tf, "_f_tmdbreplacewatchprovidercatalog", return_value=True), \
             mock.patch.object(tf.cp, "f_setservervariable"):
            result = tf.f_tmdbwatchprovidercatalogstosql()

        self.assertTrue(result)
        self.assertEqual([
            "https://api.themoviedb.org/3/watch/providers/movie?language=en-US",
            "https://api.themoviedb.org/3/watch/providers/tv?language=en-US",
        ], fetched_urls)

    def test_one_invalid_catalog_does_not_block_refreshing_the_other(self):
        with mock.patch.object(tf, "strtmdbapidomainurl", "https://api.themoviedb.org"), \
             mock.patch.object(tf, "f_tmdbfetchjson",
                               side_effect=[{"results": []}, self._payload(9)]), \
             mock.patch.object(tf, "_f_tmdbreplacewatchprovidercatalog", return_value=True) as replace, \
             mock.patch.object(tf.cp, "f_setservervariable"):
            result = tf.f_tmdbwatchprovidercatalogstosql()

        self.assertFalse(result)
        self.assertEqual(1, replace.call_count)
        self.assertEqual("serie", replace.call_args.args[0])


if __name__ == "__main__":
    unittest.main()
