#!/usr/bin/env python3
"""Describe each measured row separately; never pool processes or select minima.

Usage: python3 scripts/summarize_samples.py run*.csv > distributions.csv
`record` is the 1-based data-row index in that file, preserving duplicate cases
and execution order. `sample_count` counts timed calls, not independent processes.
The legacy report's total_ms remains best-of; this is a separate descriptive view.
"""
import argparse
import csv
import json
import math
import statistics
import sys


def describe(raw):
    values = json.loads(raw)
    if not isinstance(values, list) or not values:
        raise ValueError("samples_ms must be a nonempty JSON array")
    if any(type(v) not in (int, float) or not math.isfinite(v) or v < 0 for v in values):
        raise ValueError("samples_ms must contain finite, nonnegative times")
    variance = statistics.variance(values) if len(values) > 1 else None
    return [len(values), statistics.mean(values), statistics.median(values),
            variance, math.sqrt(variance) if variance is not None else None,
            min(values), max(values)]


def summarize(paths, output):
    writer = csv.writer(output)
    keys = ["regime", "family", "dtype", "order", "m", "n", "k", "batch", "row", "threads"]
    writer.writerow(["file", "record", *keys, "sample_count", "mean_ms", "median_ms",
                     "sample_variance_ms2", "sample_sd_ms", "min_ms", "max_ms"])
    for path in paths:
        with open(path, newline="") as handle:
            for index, row in enumerate(csv.DictReader(handle), 1):
                if row["status"] == "skipped":
                    continue
                if row["status"] != "ok":
                    raise ValueError(f"{path}:{index}: failed measurement: {row.get('note', '')}")
                if not row.get("samples_ms"):
                    raise ValueError(f"{path}:{index}: no raw samples (historical best-only CSV?)")
                writer.writerow([str(path), index, *(row[k] for k in keys), *describe(row["samples_ms"])])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("csv", nargs="+")
    args = parser.parse_args()
    try:
        summarize(args.csv, sys.stdout)
    except (ValueError, KeyError) as error:
        parser.exit(2, f"{error}\n")


if __name__ == "__main__":
    main()
