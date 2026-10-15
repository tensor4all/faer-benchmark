"""Reproduce descriptive summaries. No pooling timed calls across processes."""
import csv
import json
from pathlib import Path
import statistics
import sys

out = Path(__file__).resolve().parent
sys.path.insert(0, str(out.parents[2] / 'scripts'))
from summarize_samples import summarize  # noqa: E402

meta = json.loads((out / 'metadata.json').read_text())
paths = [out / process['csv'] for process in meta['processes']]
with (out / 'distributions.csv').open('w', newline='') as handle:
    summarize(paths, handle)

with (out / 'fixed-process-distributions.csv').open('w', newline='') as handle:
    writer = csv.writer(handle)
    writer.writerow(['vendor', 'order', 'row', 'occurrence', 'process_count',
                     'medians_ms', 'mean_of_medians_ms', 'sample_sd_of_medians_ms',
                     'sample_variance_of_medians_ms2'])
    for vendor in ('mkl', 'openblas'):
        processes = [p for p in meta['processes'] if p['vendor'] == vendor
                     and p['prime_ms'] == 3000 and p['rotation'] == 0]
        assert len(processes) == 3 and all(p['returncode'] == 0 for p in processes)
        for order in ('c', 'f'):
            for row in ('faer-fork', 'faer-upstream', 'lapack-' + vendor):
                per_process = []
                for process in processes:
                    with (out / process['csv']).open() as raw:
                        matches = [r for r in csv.DictReader(raw) if r['order'] == order and r['row'] == row]
                    assert len(matches) == 2
                    per_process.append([statistics.median(json.loads(r['samples_ms'])) for r in matches])
                for occurrence in range(2):
                    medians = [values[occurrence] for values in per_process]
                    writer.writerow([vendor, order, row, occurrence + 1, len(medians),
                                     json.dumps(medians), statistics.mean(medians),
                                     statistics.stdev(medians), statistics.variance(medians)])
