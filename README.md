# Tamper-Evident Logs – Alpha/Beta Integrated Release

Python-based HMAC-chained log format for CECS 478.

## Vertical slice

1. `scripts/write_log.py` writes events to `artifacts/release/app.log`.
2. `scripts/verify_log.py` verifies the chain and writes `verify_summary.json`.
3. `scripts/summarize_log.py` exports JSON + CSV metrics.

## Quick start

```bash
make bootstrap
make test
make demo
