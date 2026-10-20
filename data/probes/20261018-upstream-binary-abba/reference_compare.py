"""Resolve normalized-away RIP references in the existing four Cholesky leaves."""
import hashlib
import json
from pathlib import Path
import re
import struct
import subprocess

out = Path(__file__).resolve().parent
ids = json.loads((out / 'identities.json').read_text())['binaries']
leaves = json.loads((out / 'code-comparison.json').read_text())
images = {k: Path(v['path']).read_bytes() for k, v in ids.items()}
segments, relocations = {}, {}
for label, image in images.items():
    assert image[:6] == b'\x7fELF\x02\x01', 'requires native little-endian ELF64'
    phoff = struct.unpack_from('<Q', image, 32)[0]
    entsize, count = struct.unpack_from('<HH', image, 54)
    segments[label] = []
    for i in range(count):
        kind, flags, offset, address, _, size, _, _ = struct.unpack_from('<IIQQQQQQ', image, phoff+i*entsize)
        if kind == 1:
            segments[label].append((address, address+size, offset))
    text = subprocess.check_output(['readelf', '-rW', ids[label]['path']], text=True)
    relocations[label] = {int(m[1], 16): int(m[2], 16)
                          for m in re.finditer(r'^([0-9a-f]+)\s+\S+\s+R_X86_64_RELATIVE\s+([0-9a-f]+)\s*$', text, re.M)}

def memory(label, address, size):
    for lo, hi, offset in segments[label]:
        if lo <= address and address+size <= hi:
            start = offset+address-lo
            return images[label][start:start+size]
    raise ValueError((label, hex(address), size))

def refs(index, label):
    text = (out / f'leaf{index}-{label}.asm').read_text()
    return [m.groups() for m in re.finditer(r'^\s*[0-9a-f]+:\s*(.*?)\[rip[^]]*\].*?#\s*([0-9a-f]+)', text, re.M)]

results = []
for index, leaf in enumerate(leaves):
    a, b = refs(index, 'A'), refs(index, 'B')
    assert len(a) == len(b) and len(a) > 0
    resolved = []
    for (op_a, address_a), (op_b, address_b) in zip(a, b):
        assert op_a == op_b
        addresses = {'A': int(address_a,16), 'B': int(address_b,16)}
        if op_a.strip().startswith('lea') and all(
                int(leaf[f'{k}_address'],16) <= v < int(leaf[f'{k}_address'],16)+leaf[f'{k}_size']
                for k,v in addresses.items()):
            values = {k: hex(v-int(leaf[f'{k}_address'],16)) for k,v in addresses.items()}
            kind = 'local-code-offset'
        elif op_a.strip().startswith('lea'):
            values = {k: dict(address=hex(v),first32_bytes=memory(k,v,32).hex(),
                              relocations={hex(p-v):hex(target) for p,target in relocations[k].items()
                                           if v <= p < v+32}) for k,v in addresses.items()}
            kind = 'external-address-and-first32-bytes-not-whole-object'
        elif all(v in relocations[k] for k,v in addresses.items()):
            values = {k: hex(relocations[k][v]) for k,v in addresses.items()}
            kind = 'relative-relocation-target'
        else:
            width = next(n for s,n in [('YMMWORD',32),('XMMWORD',16),('QWORD',8),('DWORD',4),('WORD',2),('BYTE',1)] if s+' PTR' in op_a)
            values = {k: memory(k,v,width).hex() for k,v in addresses.items()}
            kind = 'referenced-bytes'
        resolved.append(dict(operation=op_a.strip(), addresses={k:hex(v) for k,v in addresses.items()},
                             kind=kind, values=values, equal=values['A']==values['B']))
    results.append(dict(leaf=index, reference_count=len(resolved), references=resolved,
                        all_equal=all(r['equal'] for r in resolved)))

# The indirect partial-load/store dispatch table referenced through the GOT.
# Its symbol/size is recorded by nm: pulp::x86::LD_ST at0x5462f0,size0x1100.
lo, hi = 0x5462f0, 0x5462f0+0x1100
tables = {k: {hex(p):hex(v) for p,v in relocs.items() if lo <= p < hi}
          for k,relocs in relocations.items()}
targets = [int(v,16) for v in tables['A'].values()]
assert targets and tables['A'] == tables['B']
helper_lo, helper_hi = min(targets), max(targets)+64
helper_hashes = {k:hashlib.sha256(memory(k,helper_lo,helper_hi-helper_lo)).hexdigest() for k in ids}
report = dict(leaves=results, partial_load_store_table=dict(address=hex(lo),size=hi-lo,
              raw_bytes_equal=memory('A',lo,hi-lo)==memory('B',lo,hi-lo),
              relocation_count=len(targets),relocations_equal=tables['A']==tables['B']),
              helper_region=dict(start=hex(helper_lo),end=hex(helper_hi),sha256=helper_hashes,
                                 equal=helper_hashes['A']==helper_hashes['B']),
              limitation='Bounded static equivalence, not an isolation of instruction alignment, predictor, allocation, caller or whole-program effects.')
(out / 'reference-comparison.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({k:v for k,v in report.items() if k!='leaves'},indent=2))
print('Leaf reference equality:', [(r['leaf'],r['reference_count'],r['all_equal']) for r in results])
