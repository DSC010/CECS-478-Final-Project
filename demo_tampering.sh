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
# Change the 'login' message to 'hacked' (no spaces in JSON)
sed -i '0,/"msg":"login"/s//"msg":"hacked"/' artifacts/tamper/tamper_msg.log || true
python3 scripts/verify_log.py --log artifacts/tamper/tamper_msg.log || true
echo

########################################
# Test 2 — Change level
########################################
echo "=== Test 2: Change level (tamper_level.log) ==="
cp artifacts/tamper/clean.log artifacts/tamper/tamper_level.log
# Change only the first INFO to ERROR (no spaces in JSON)
sed -i '0,/"level":"INFO"/s//"level":"ERROR"/' artifacts/tamper/tamper_level.log || true
python3 scripts/verify_log.py --log artifacts/tamper/tamper_level.log || true
echo

########################################
# Test 3 — Delete an entry
########################################
echo "=== Test 3: Delete line 2 (tamper_delete.log) ==="
cp artifacts/tamper/clean.log artifacts/tamper/tamper_delete.log
# Delete the second line from the log
sed -i '2d' artifacts/tamper/tamper_delete.log || true
python3 scripts/verify_log.py --log artifacts/tamper/tamper_delete.log || true
echo

########################################
# Test 4 — Insert a fake/duplicate entry
########################################
echo "=== Test 4: Insert extra entry at end (tamper_insert.log) ==="
cp artifacts/tamper/clean.log artifacts/tamper/tamper_insert.log
# Append a duplicate of line 2 (but the chain expects 3 entries, not 4)
sed -n '2p' artifacts/tamper/clean.log >> artifacts/tamper/tamper_insert.log
python3 scripts/verify_log.py --log artifacts/tamper/tamper_insert.log || true
echo

########################################
# Test 5 — Modify extra metadata
########################################
echo "=== Test 5: Modify extra field (tamper_extra.log) ==="
cp artifacts/tamper/clean.log artifacts/tamper/tamper_extra.log
# Change user=42 to user=999 in the JSON extra field
sed -i '0,/"user":42/s//"user":999/' artifacts/tamper/tamper_extra.log || true
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
