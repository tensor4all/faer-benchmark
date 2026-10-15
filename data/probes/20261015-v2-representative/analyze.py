#!/usr/bin/env python3
"""Describe all retained pilot samples; do not trim or turn calls into replicates."""
import csv
import json
import statistics
from collections import defaultdict
from pathlib import Path

import yaml
from campaign_toolkit import timing_evidence

HERE = Path(__file__).resolve().parent


def main():
    metadata = json.loads((HERE / 'metadata.json').read_text())
    contracts = sorted(HERE.glob('*/*t/control-contract.yaml'))
    if not metadata.get('complete') or len(contracts) != 6:
        raise SystemExit('incomplete pilot; preserve partial artifacts without claiming success')
    within, between = [], []
    for contract in contracts:
        manifest = yaml.safe_load(contract.read_text())
        directory = contract.parent
        timing_evidence.validate(manifest, directory)
        groups = defaultdict(list)
        for filename in manifest['result_files']:
            with (directory / filename).open(newline='') as file:
                for row in csv.DictReader(file):
                    if row['status'] != 'ok':
                        continue  # preserved declared skips have no fabricated samples
                    samples = timing_evidence.samples(row, 30)
                    record = {'vendor': manifest['vendor']['name'], 'file': filename,
                              **dict(zip(timing_evidence.BASE + ('note',), timing_evidence.cell(row))),
                              'sample_count': len(samples), 'median_ms': statistics.median(samples),
                              'mean_ms': statistics.mean(samples), 'sample_sd_ms': statistics.stdev(samples),
                              'sample_variance_ms2': statistics.variance(samples),
                              'min_ms': min(samples), 'max_ms': max(samples)}
                    within.append(record)
                    groups[timing_evidence.cell(row)].append(record)
        for key, records in groups.items():
            medians = [record['median_ms'] for record in records]
            center = statistics.median(medians)
            relative_range = (max(medians) - min(medians)) / center
            between.append({'vendor': manifest['vendor']['name'],
                **dict(zip(timing_evidence.BASE + ('note',), key)), 'process_count': len(records),
                'files': json.dumps([record['file'] for record in records]),
                'process_medians_ms': json.dumps(medians), 'median_ms': center,
                'sample_sd_of_process_medians_ms': statistics.stdev(medians),
                'median_within_process_sample_sd_ms': statistics.median(record['sample_sd_ms'] for record in records),
                'relative_process_median_range': relative_range, 'range_over_5_percent': relative_range > 0.05})
    if not within:
        raise SystemExit('no completed controls; do not interpret partial progress as a successful pilot')
    for name, rows in [('within-process.csv', within), ('between-process.csv', between)]:
        with (HERE / name).open('w', newline='') as file:
            writer = csv.DictWriter(file, fieldnames=list(rows[0]))
            writer.writeheader()
            writer.writerows(rows)
    print(f'{len(within)} process rows; {len(between)} cells; '
          f'{sum(row["range_over_5_percent"] for row in between)} descriptive range warnings')


if __name__ == '__main__':
    main()
