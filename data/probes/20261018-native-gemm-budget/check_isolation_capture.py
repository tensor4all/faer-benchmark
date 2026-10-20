"""Untimed focused smoke check of the actual nested capture function; no fbench.

AST extraction avoids invoking the live-host recording entry point or copying its
implementation. Dummy guard is intentional: this tests output/status retention,
not live topology. Optimized startup refusal is checked separately in the log.
"""
import ast
import datetime
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


def main():
    source = Path(__file__).with_name('isolate_controls.py')
    node = next(n for n in ast.walk(ast.parse(source.read_text()))
                if isinstance(n, ast.FunctionDef) and n.name == 'capture')
    with tempfile.TemporaryDirectory() as temp:
        out = Path(temp)
        namespace = {'OUT': out, 'guard': lambda: {'dummy_smoke_guard': True},
                     'datetime': datetime, 'json': json, 're': re, 'shutil': shutil, 'subprocess': subprocess}
        # Only this repository's trusted capture function, no external input.
        exec(compile(ast.Module(body=[node], type_ignores=[]), str(source), 'exec'), namespace)  # noqa: S102
        for code in (0, 3):
            name = f'exit{code}'
            command = [sys.executable, '-c',
                       f'import sys;print("captured stdout");print("captured stderr",file=sys.stderr);sys.exit({code})']
            try:
                text = namespace['capture'](name, command, os.environ)
            except subprocess.CalledProcessError as error:
                assert code == error.returncode == 3
            else:
                assert code == 0 and text == 'captured stdout\n'
            assert (out / f'{name}.stdout').read_text() == 'captured stdout\n'
            assert (out / f'{name}.log').read_text() == 'captured stderr\n'
            after = json.loads((out / f'{name}.after.json').read_text())
            assert after['returncode'] == code and after['after']['dummy_smoke_guard']
            assert json.loads((out / f'{name}.command.json').read_text())['argv'] == command
    print('PASS actual capture: success + failed command retain stdout/stderr/argv/status/before-after; no timing')


if __name__ == '__main__':
    main()
