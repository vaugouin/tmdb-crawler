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


if __name__ == "__main__":
    unittest.main()
