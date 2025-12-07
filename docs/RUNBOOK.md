# Runbook – Tamper-Evident Logging System

This runbook describes how to rebuild and run the system from a fresh clone in the lab environment.

## 1. Prerequisites

- Git
- Docker + Docker Compose (for `make up && make demo`)
- Python 3.10+ with `python3`, `python3-venv`, and `pip`
- `make` installed

## 2. Fresh Clone Setup

From a clean machine:

```bash
git clone https://github.com/DSC010/CECS-478-Final-Project.git
cd CECS-478-Final-Project