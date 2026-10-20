"""Inspect unchanged Cholesky SIMD leaves in the two fixed diagnostic binaries."""
import difflib
import json
from pathlib import Path
import re
import subprocess

out = Path(__file__).resolve().parent
ids = json.loads((out / 'identities.json').read_text())['binaries']

def symbols(binary, demangle=False):
    args = ['nm', '-S', '-n'] + (['-C'] if demangle else []) + [binary]
    result = {}
    for line in subprocess.check_output(args, text=True).splitlines():
        m = re.match(r'([0-9a-f]+) ([0-9a-f]+) [tT] (.*)', line)
        if m:
            result[(int(m[1], 16), int(m[2], 16))] = m[3]
    return result

def instructions(binary, address, size):
    text = subprocess.check_output(['objdump', '-d', '-M', 'intel', '--no-show-raw-insn',
                                  f'--start-address={address}', f'--stop-address={address+size}', binary], text=True)
    lines = []
    for line in text.splitlines():
        m = re.match(r'\s*[0-9a-f]+:\s*(.*)', line)
        if not m:
            continue
        ins = m[1].split('#')[0].rstrip()
        ins = re.sub(r'\[rip[+-]0x[0-9a-f]+\]', '[rip+CONSTANT]', ins)
        ins = re.sub(r'\b([0-9a-f]+) <([^>]+)>',
                     lambda m: f'LOCAL+{int(m[1],16)-address:x}'
                     if address <= int(m[1],16) < address+size else f'EXTERNAL<{m[2]}>', ins)
        lines.append(ins)
    return text, lines

raw = {k: symbols(v['path']) for k, v in ids.items()}
demangled = {k: symbols(v['path'], True) for k, v in ids.items()}
by_name_b = {name: key for key, name in raw['B'].items()}
results = []
for (address, size), name in demangled['A'].items():
    if 'simd_cholesky::Impl<' not in name or 'vectorize::imp' not in name:
        continue
    mangled = raw['A'][(address, size)]
    other_address, other_size = by_name_b[mangled]
    old_text, old = instructions(ids['A']['path'], address, size)
    new_text, new = instructions(ids['B']['path'], other_address, other_size)
    index = len(results)
    (out / f'leaf{index}-A.asm').write_text(old_text)
    (out / f'leaf{index}-B.asm').write_text(new_text)
    diff = list(difflib.unified_diff(old, new))
    (out / f'leaf{index}-normalized.diff').write_text('\n'.join(diff)+'\n')
    result = dict(name=name, mangled=mangled, A_address=hex(address), B_address=hex(other_address),
                  A_size=size, B_size=other_size, address_delta=other_address-address,
                  normalized_instruction_diff_lines=len(diff),
                  caveat='RIP displacements normalized; this does not prove equal referenced constant values or prove alignment causality.')
    results.append(result)
(out / 'code-comparison.json').write_text(json.dumps(results, indent=2)+'\n')
for result in results:
    print(result)
