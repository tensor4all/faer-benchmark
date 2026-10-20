#!/usr/bin/env bash
# Own prior canonical driver reused, plus approved development pre-filter check.
# No new acceptance statistics; one attempt, no outer retries or automatic stage2.
set -euo pipefail
ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
cd "$ROOT"
REL=data/probes/20261018-native-structured-floor
check_static() {
    python3 - "$ROOT" "$REL" <<'PY'
import hashlib,json,sys
from pathlib import Path
root=Path(sys.argv[1]);base=root/sys.argv[2]
cfg=json.loads((base/'commands.json').read_text())
p=json.loads((base/'static-dense/comparison.json').read_text())
if p.get('prefilter_pass') is not True or len(p['functions'])!=4:
    raise SystemExit('HOLD: four dense bodies have not passed development pre-filter')
for side,ref in cfg['sides'].items():
    binary=root/'target/faer-rev'/f'{ref[:12]}-mkl/release/fbench'
    entry=p['binaries'][side]
    if Path(entry['path'])!=binary or hashlib.sha256(binary.read_bytes()).hexdigest()!=entry['sha256']:
        raise SystemExit('HOLD: binary differs from fresh static pre-filter: '+side)
PY
}
check_static
OUT="$ROOT/$REL/runtime-stage1"
mkdir "$OUT"  # refuse to overwrite an earlier attempt
export PINNED_RETRIES=8 PINNED_IDLE_SECONDS=3 PINNED_MAX_BUSY=0.05 BENCH_BUILD_PROFILE=release
unset FBENCH_ALLOW_BOOST
git rev-parse HEAD > "$OUT/harness-commit.txt"
git -C ../campaign-toolkit rev-parse HEAD > "$OUT/toolkit-commit.txt"
for side in A B; do
    ref=$(python3 - "$REL" "$side" <<'PY'
import json,sys
from pathlib import Path
print(json.loads((Path(sys.argv[1])/'commands.json').read_text())['sides'][sys.argv[2]])
PY
)
    (
        flock -n 9
        test -z "$(git -C extern/t4a-faer status --porcelain --untracked-files=no)"
        git -C extern/t4a-faer switch --detach "$ref"
        test "$(git -C extern/upstream-faer rev-parse HEAD)" = 0539947ffb757a739d7e703a7d2fa0c792a909c1
        cargo metadata --offline --format-version 1 --features fbench/link-mkl \
            --config "patch.crates-io.t4a-faer.path=\"$ROOT/extern/t4a-faer/faer\"" \
            --config "patch.crates-io.faer.path=\"$ROOT/extern/upstream-faer/faer\"" \
            > "$OUT/$side-cargo-metadata.json"
        test -z "$(git status --porcelain --untracked-files=no)"
    ) 9> target/campaign.lock
    for group in cholesky gemm triangular_solve householder_apply; do
        check_static
        echo "START side=$side group=$group $(date -u +%FT%TZ)"
        timeout --signal=TERM --kill-after=15s 900s python3 - "$REL" "$side" "$group" <<'PY' > "$OUT/$side-$group.log" 2>&1
import json,os,sys
from pathlib import Path
cfg=json.loads((Path(sys.argv[1])/'commands.json').read_text())
entry=next(e for e in cfg['stages']['stage1'] if e['group']==sys.argv[3])
argv=entry['argv']+['--label',entry['label_template'].format(side=sys.argv[2])]
os.execv(sys.executable,[sys.executable,*argv[1:]])
PY
        check_static
        echo "DONE side=$side group=$group $(date -u +%FT%TZ)"
    done
done
echo "COMPLETE stage1 recording only; inventory/comparison/adoption NOT inferred"
