"""Development pre-filter, NOT performance/equivalence approval. A B output-directory.

Reuse this project's bounded analyzer functions without executing its old driver
or touching historical outputs. No source build, kernel run or timing occurs.
"""
import ast
import difflib
import hashlib
import json
import sys
from pathlib import Path


def main():
    root = Path(__file__).resolve().parents[3]
    source = root / 'data/probes/20261018-upstream-binary-abba/code_compare.py'
    tree = ast.parse(source.read_text())
    functions = [n for n in tree.body if isinstance(n, (ast.Import, ast.ImportFrom, ast.FunctionDef))]
    scope = {}
    # Only trusted existing repository analyzer imports/functions; not its driver.
    exec(compile(ast.Module(body=functions, type_ignores=[]), str(source), 'exec'), scope)  # noqa: S102
    binaries = dict(zip(('A', 'B'), sys.argv[1:3], strict=True))
    out = Path(sys.argv[3])
    out.mkdir()  # No overwrite, including a failed pre-filter.
    raw = {s: scope['symbols'](p) for s, p in binaries.items()}
    demangled = {s: scope['symbols'](p, True) for s, p in binaries.items()}
    names_b = {name: key for key, name in raw['B'].items()}
    selected = {s: {key: name for key, name in names.items() if '::matmul::matmul_imp' in name}
                for s, names in demangled.items()}
    results = []
    for (address, size), name in selected['A'].items():
        mangled = raw['A'][(address, size)]
        other = names_b.get(mangled)
        entry = {'name': name, 'mangled': mangled, 'matched': other is not None}
        if other is not None:
            ba, bs = other
            text_a, a = scope['instructions'](binaries['A'], address, size)
            text_b, b = scope['instructions'](binaries['B'], ba, bs)
            diff = list(difflib.unified_diff(a, b))
            index = len(results)
            (out / f'fn{index}-A.asm').write_text(text_a)
            (out / f'fn{index}-B.asm').write_text(text_b)
            (out / f'fn{index}-normalized.diff').write_text('\n'.join(diff) + '\n')
            entry.update(A_size=size, B_size=bs, A_address=hex(address), B_address=hex(ba),
                         normalized_diff_lines=len(diff), equal=size == bs and a == b)
        results.append(entry)
    passed = len(selected['A']) == len(selected['B']) == len(results) == 4 and all(r.get('equal', False) for r in results)
    report = {'prefilter_pass': passed, 'adoption': False, 'binaries': {
        s: {'path': str(Path(p).resolve()), 'sha256': hashlib.sha256(Path(p).read_bytes()).hexdigest()}
        for s, p in binaries.items()}, 'functions': results,
        'source_analyzer_sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
        'limitation': 'RIP references normalized; not reference/caller/kernel/worker/whole-program equivalence, causality, controls or performance acceptance.'}
    (out / 'comparison.json').write_text(json.dumps(report, indent=2) + '\n')
    print('prefilter', 'PASS (not adoption)' if passed else 'HOLD: do not time this candidate')
    print([(r['name'], r.get('normalized_diff_lines'), r.get('equal')) for r in results])
    raise SystemExit(0 if passed else 1)


if __name__ == '__main__':
    main()
