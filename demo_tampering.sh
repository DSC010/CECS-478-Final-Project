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
sed -i '0,/"msg": "login"/s//"msg": "hacked"/' artifacts/tamper/tamper_msg.log || true
python3 scripts/verify_log.py --log artifacts/tamper/tamper_msg.log || true
echo

########################################
# Test 2 — Change level
########################################
echo "=== Test 2: Change level (tamper_level.log) ==="
cp artifacts/tamper/clean.log artifacts/tamper/tamper_level.log
# Change only the first INFO to ERROR
sed -i '0,/"level": "INFO"/s//"level": "ERROR"/' artifacts/tamper/tamper_level.log || true
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
# Test 4 — Insert a fake entry
########################################
echo "=== Test 4: Insert fake entry at end (tamper_insert.log) ==="
cp artifacts/tamper/clean.log artifacts/tamper/tamper_insert.log
# Append a JSON object that does not participate correctly in the chain
sed -n '2p' artifacts/tamper/clean.log >> artifacts/tamper/tamper_insert.log
python3 scripts/verify_log.py --log artifacts/tamper/tamper_insert.log || true
echo

########################################
# Test 5 — Reorder entries
########################################
echo "=== Test 5: Reorder lines 2 and 3 (tamper_reorder.log) ==="
cp artifacts/tamper/clean.log artifacts/tamper/tamper_reorder.log
awk 'NR==1{print $0} NR==3{print $0} NR==2{print $0}' artifacts/tamper/clean.log > artifacts/tamper/tamper_reorder.log
python3 scripts/verify_log.py --log artifacts/tamper/tamper_reorder.log || true
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
