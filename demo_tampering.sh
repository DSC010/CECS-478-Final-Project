#!/usr/bin/env bash
set -e

echo "=== Tamper Demo Starting ==="

# Make sure env is set correctly for telogs import
export TELOGS_SECRET=${TELOGS_SECRET:-demo-key}
export PYTHONPATH=src

echo "TELOGS_SECRET=$TELOGS_SECRET"
echo "PYTHONPATH=$PYTHONPATH"
echo

echo "Cleaning old logs..."
rm -f app.log clean.log tamper_*.log
echo "Done."
echo

echo "=== Building clean.log (3 entries) ==="
python3 scripts/write_log.py "demo start" --level INFO
python3 scripts/write_log.py "login" --level INFO user=42
python3 scripts/write_log.py "done" --level INFO
cp app.log clean.log

echo
echo "Verifying clean.log (should be OK=True)..."
python3 scripts/verify_log.py --log clean.log
echo

########################################
# Test 1 — Modify message text
########################################
echo "=== Test 1: Modify message text (tamper_msg.log) ==="
cp clean.log tamper_msg.log
sed -i 's/"msg": "login"/"msg": "hacked"/' tamper_msg.log || true
python3 scripts/verify_log.py --log tamper_msg.log || true
echo

########################################
# Test 2 — Change level
########################################
echo "=== Test 2: Change level (tamper_level.log) ==="
cp clean.log tamper_level.log
sed -i 's/"level": "INFO"/"level": "ERROR"/' tamper_level.log || true
python3 scripts/verify_log.py --log tamper_level.log || true
echo

########################################
# Test 3 — Delete an entry
########################################
echo "=== Test 3: Delete line 2 (tamper_delete.log) ==="
cp clean.log tamper_delete.log
sed -i '2d' tamper_delete.log || true
python3 scripts/verify_log.py --log tamper_delete.log || true
echo

########################################
# Test 4 — Insert a fake entry
########################################
echo "=== Test 4: Insert fake entry at end (tamper_insert.log) ==="
cp clean.log tamper_insert.log
echo '{"msg":"evil insert"}' >> tamper_insert.log
python3 scripts/verify_log.py --log tamper_insert.log || true
echo

########################################
# Test 5 — Reorder entries
########################################
echo "=== Test 5: Reorder lines 2 and 3 (tamper_reorder.log) ==="
cp clean.log tamper_reorder.log
awk 'NR==1{print $0} NR==3{print $0} NR==2{print $0}' clean.log > tamper_reorder.log
python3 scripts/verify_log.py --log tamper_reorder.log || true
echo

########################################
# Test 6 — Truncate tail
########################################
echo "=== Test 6: Truncate last bytes (tamper_truncate.log) ==="
cp clean.log tamper_truncate.log
truncate -s -20 tamper_truncate.log
python3 scripts/verify_log.py --log tamper_truncate.log || true
echo

echo "=== Tamper Demo Finished ==="
