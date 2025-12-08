# Tamper-Evident Logging & Verification System

A lightweight, Python-based logging system with cryptographic integrity verification.  
Each log entry depends on the previous one via **HMAC hash chaining**, allowing the system to **detect any tampering** (editing, deletion, insertion, or reordering).

This is the **Alpha–Beta Integrated Release** for CECS 478 — fully runnable end-to-end inside Docker with automated testing and evidence artifacts.

---

## Vertical Slice Overview
**request -> log -> verify -> summarize**

1. **Application** appends JSON log entries  
2. Each entry includes the **`prev_hmac`** from the previous line  
3. A verifier script **replays the log** and detects the first break in the chain  
4. A summarizer exports **JSON + CSV metrics** for evaluation

No plaintext secrets ever written to disk.  
Any modification of historical entries becomes immediately detectable.

---

## Quick Start Instructions

Clone the repo and run:

```bash
make bootstrap      # once – install Python deps in venv
make up             # build + start Docker container
make demo           # exercise the full vertical slice