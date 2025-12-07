
---

### `docs/SECURITY.md`

```markdown
# Security Invariants & Threat Model

## 1. Threat Model

- **Attacker capabilities**
  - Can read and modify the log file on disk.
  - Can attempt to delete, insert, or reorder log entries to hide activity.
- **Assumptions**
  - Attacker cannot read or modify the HMAC secret key.
  - OS permissions for the secret remain intact.
  - Full system compromise (root + key theft) is out of scope.

## 2. Assets

- Integrity of log contents.
- Integrity of event ordering (chronological chain of events).

## 3. Core Security Invariants

1. **Append-Only at Interface Level**  
   - The `TELogger` API only appends entries; it never edits past entries.
   - Any change to earlier lines must come from an attacker or external corruption.

2. **HMAC-Chained Entries**  
   - Each entry includes:
     - `prev_hmac` = HMAC of the previous entry.
     - `hmac`      = HMAC over the current entry’s canonical JSON.
   - Breaking the chain at line *i* causes verification to fail at or before line *i*.

3. **Tamper-Detection, Not Prevention**  
   - The system **detects** tampering but does not stop writes.
   - Verification is an explicit step via `verify_log.py`.

4. **Secret Key Handling**
   - The HMAC key is provided via `TELOGS_SECRET` environment variable.
   - The key is **never written to disk** and never logged.
   - Logs are safe to share without exposing the secret.

5. **Canonical JSON Format**
   - The HMAC is computed over a canonical JSON representation:
     - Sorted keys
     - Tight separators
   - This prevents attackers from exploiting formatting differences to bypass the HMAC.

## 4. Limitations & Scope

- **No Confidentiality**  
  - Log contents are plaintext for debugging and auditing.
  - The system does not encrypt logs, only protects integrity.

- **System Compromise**  
  - If an attacker acquires the HMAC secret key, they can forge valid chains.
  - In that case, integrity guarantees are void; this is explicitly out of scope.

- **Partial Tail Corruption**  
  - A truncated or corrupted tail of the log is treated as a failure condition.
  - The verifier reports a JSON parse error or mismatch at the first bad index.

## 5. Operational Recommendations

- Store `TELOGS_SECRET` in environment variables or a secrets manager.
- Restrict filesystem permissions on:
  - Log directory (`artifacts/release/`)
  - Any scripts that set the secret
- Run verification regularly (e.g., via cron) to detect tampering quickly.
