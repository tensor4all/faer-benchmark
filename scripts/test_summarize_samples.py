import csv
import io
import pathlib
import tempfile
import unittest

from summarize_samples import describe, summarize


class SamplesTest(unittest.TestCase):
    def test_descriptive_statistics_and_invalid_data(self):
        self.assertEqual(describe('[3, 1, 2]'), [3, 2, 2, 1, 1, 1, 3])
        self.assertEqual(describe('[1]'), [1, 1, 1, None, None, 1, 1])
        for invalid in ('[]', '[NaN]', '[true]', '[-1]', '"bad"'):
            with self.assertRaises(ValueError):
                describe(invalid)

    def test_duplicate_cases_remain_separate(self):
        keys = ['regime', 'family', 'dtype', 'order', 'm', 'n', 'k', 'batch', 'row', 'threads', 'status', 'samples_ms']
        with tempfile.TemporaryDirectory() as temp:
            path = pathlib.Path(temp) / 'run.csv'
            with path.open('w', newline='') as handle:
                writer = csv.writer(handle)
                writer.writerow(keys)
                for sample in ('[3, 1, 2]', '[9, 9, 9]'):
                    writer.writerow(['probe', 'gemm', 'f64', 'c', 2, 2, 2, 1, 'faer-fork', 1, 'ok', sample])
            output = io.StringIO()
            summarize([path], output)
            rows = list(csv.DictReader(io.StringIO(output.getvalue())))
            self.assertEqual([r['record'] for r in rows], ['1', '2'])
            self.assertEqual([float(r['mean_ms']) for r in rows], [2, 9])
            self.assertEqual([int(r['sample_count']) for r in rows], [3, 3])
            self.assertEqual([int(r['n']) for r in rows], [2, 2])


if __name__ == '__main__':
    unittest.main()
