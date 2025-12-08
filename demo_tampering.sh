#!/usr/bin/env bash
set -e

echo "=== Tamper Demo Starting ==="

# Environment for telogs imports and HMAC key
export TELOGS_SECRET=${TELOGS_SECRET:-demo-key}
export PYTHONPATH=src

echo "TELOGS_SECRET=$TELOGS_SECRET"
echo "PYTHONPATH=$PYTHONPATH"
echo

# Make sure tamper artifacts directory exists
mkdir -p artifacts/tamper

echo "Cleaning old tamper logs in artifacts/tamper/..."
rm -f artifacts/tamper/*.log
echo "Done."
echo

########################################
# Build a clean baseline log
########################################
echo "=== Building clean.log (3 entries) in artifacts/tamper ==="

python3 scripts/write_log.py "demo start" --level INFO --log artifacts/tamper/clean.log
python3 scripts/write_log.py "login" --level INFO user=42 --log artifacts/tamper/clean.log
python3 scripts/write_log.py "done" --level INFO --log artifacts/tamper/clean.log

echo
echo "Verifying clean.log (should be OK=True)..."
python3 scripts/verify_log.py --log artifacts/tamper/clean.log || true
echo

########################################
# Test 1 — Modify message text
########################################
echo "=== Test 1: Modify message text (tamper_msg.log) ==="
cp artifacts/tamper/clean.log artifacts/tamper/tamper_msg.log
# Change the 'login' message to 'hacked'
sed -i '0,/"msg":"login"/s//"msg":"hacked"/' artifacts/tamper/tamper_msg.log || true
python3 scripts/verify_log.py --log artifacts/tamper/tamper_msg.log || true
echo

########################################
# Test 2 — Change level
########################################
echo "=== Test 2: Change level (tamper_level.log) ==="
cp artifacts/tamper/clean.log artifacts/tamper/tamper_level.log
# Change first INFO to ERROR
sed -i '0,/"level":"INFO"/s//"level":"ERROR"/' artifacts/tamper/tamper_level.log || true
python3 scripts/verify_log.py --log artifacts/tamper/tamper_level.log || true
echo

########################################
# Test 3 — Delete an entry
########################################
echo "=== Test 3: Delete line 2 (tamper_delete.log) ==="
cp artifacts/tamper/clean.log artifacts/tamper/tamper_delete.log
# Delete the second JSONL entry
sed -i '2d' artifacts/tamper/tamper_delete.log || true
python3 scripts/verify_log.py --log artifacts/tamper/tamper_delete.log || true
echo

########################################
# Test 4 — Insert a fake/duplicate entry
########################################
echo "=== Test 4: Insert extra entry at end (tamper_insert.log) ==="
cp artifacts/tamper/clean.log artifacts/tamper/tamper_insert.log
# Append a duplicate of line 2 — chain no longer valid
sed -n '2p' artifacts/tamper/clean.log >> artifacts/tamper/tamper_insert.log
python3 scripts/verify_log.py --log artifacts/tamper/tamper_insert.log || true
echo

########################################
# Test 5 — Modify metadata field via Python
########################################
echo "=== Test 5: Modify extra field (tamper_extra.log) ==="
cp artifacts/tamper/clean.log artifacts/tamper/tamper_extra.log

python3 - << 'EOF'
import json
from pathlib import Path

path = Path("artifacts/tamper/tamper_extra.log")
lines = path.read_text().splitlines()

# Tamper with the second entry (index 1)
obj = json.loads(lines[1])
extra = obj.get("extra", {})
extra["tampered"] = True   # add or change a metadata field
obj["extra"] = extra

# Re-encode with canonical-style JSON (sorted keys, tight separators)
lines[1] = json.dumps(obj, sort_keys=True, separators=(",", ":"))

path.write_text("\n".join(lines) + "\n")
EOF

python3 scripts/verify_log.py --log artifacts/tamper/tamper_extra.log || true
echo

########################################
# Test 6 — Truncate tail
########################################
echo "=== Test 6: Truncate last bytes (tamper_truncate.log) ==="
cp artifacts/tamper/clean.log artifacts/tamper/tamper_truncate.log
truncate -s -20 artifacts/tamper/tamper_truncate.log || true
python3 scripts/verify_log.py --log artifacts/tamper/tamper_truncate.log || true
echo

echo "=== Tamper Demo Finished ==="
