# Tamper-Evident Logging & Verification System

A lightweight, Python-based logging system with cryptographic integrity verification.  
Each log entry depends on the previous one via **HMAC hash chaining**, allowing the system to **detect any tampering** (editing, deletion, insertion, or corruption).

This is the **Alpha–Beta Integrated Release** for CECS 478 — runnable end-to-end with a single `make` command and accompanied by frozen evidence artifacts and a final report.

---

## Vertical Slice Overview

**request -> log -> verify -> summarize**

1. An application appends JSON log entries using `write_log.py`.  
2. Each entry includes the previous entry’s HMAC (`prev_hmac`), forming a hash chain.  
3. `verify_log.py` replays the log and detects the **first break in the chain**.  
4. `summarize_log.py` exports **JSON + CSV metrics** for evaluation.

No plaintext secrets are written to disk.  
Any modification of historical entries becomes immediately detectable.

---

## Quick Start (Grading / Reproducibility Command)

From a clean clone of the repo:

```bash
make clean && make up && make demo
