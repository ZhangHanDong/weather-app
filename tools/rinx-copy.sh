#!/usr/bin/env bash
# Make an unsigned copy of bundle/ for Rinx's local mini-app import.
# Rinx's local import accepts only unsigned bundles ("no signature verifier is
# installed"); the App Hub copy in bundle/ is signed. Code and assets are
# identical: only the manifest's signature is removed and the digest restamped.
#   tools/rinx-copy.sh [out_dir]        (default: ./rinx-bundle)    needs `hub` on PATH
set -euo pipefail
cd "$(dirname "$0")/.."
OUT=${1:-rinx-bundle}
rm -rf "$OUT"; cp -R bundle "$OUT"
python3 - "$OUT/manifest.json" <<'PY'
import json, sys
p = sys.argv[1]; m = json.load(open(p))
def strip(o): return {k: strip(v) for k, v in o.items() if k != "signature"} if isinstance(o, dict) else o
json.dump(strip(m), open(p, "w"), indent=2)
PY
hub stamp "$OUT" >/dev/null
hub check "$OUT" --allow-unsigned | head -1
echo "import this folder in Rinx: $(cd "$OUT" && pwd)"
