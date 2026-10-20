#!/usr/bin/env bash
# Operational invocation of the EXISTING recorder; no statistics or new gate.
# Run once. A failure retains all partial evidence and stops, with no outer retry.
set -euo pipefail
ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
cd "$ROOT"
OUT="$ROOT/data/probes/20261018-native-gemm-budget/runtime-stage1"
mkdir "$OUT"  # refuse to overwrite an earlier attempt
export PINNED_RETRIES=8 PINNED_IDLE_SECONDS=3 PINNED_MAX_BUSY=0.05
unset FBENCH_ALLOW_BOOST
git rev-parse HEAD > "$OUT/harness-commit.txt"
git -C ../campaign-toolkit rev-parse HEAD > "$OUT/toolkit-commit.txt"
for side in A B; do
    ref=$(python3 - "$side" <<'PY'
import json,sys
from pathlib import Path
print(json.loads(Path('data/probes/20261018-native-gemm-budget/commands.json').read_text())['sides'][sys.argv[1]])
PY
)
    # Honor the existing campaign lock BEFORE touching a checkout or Cargo graph.
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
        echo "START side=$side group=$group $(date -u +%FT%TZ)"
        # GNU timeout owns a separate process group, including recorder children.
        timeout --signal=TERM --kill-after=15s 900s python3 - "$side" "$group" <<'PY' > "$OUT/$side-$group.log" 2>&1
import json,os,sys
from pathlib import Path
cfg=json.loads(Path('data/probes/20261018-native-gemm-budget/commands.json').read_text())
entry=next(e for e in cfg['stages']['stage1'] if e['group']==sys.argv[2])
argv=entry['argv']+['--label',entry['label_template'].format(side=sys.argv[1])]
os.execv(sys.executable,[sys.executable,*argv[1:]])
PY
        echo "DONE side=$side group=$group $(date -u +%FT%TZ)"
    done
done
echo "COMPLETE stage1 recording only; inventory/comparison/adoption NOT inferred"
