VENV := .venv
PY := $(VENV)/bin/python
PIP := $(VENV)/bin/pip

.PHONY: bootstrap test coverage demo up clean

bootstrap:
	python3 -m venv $(VENV)
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt

test:
	$(PY) -m pytest -q

coverage:
	$(PY) -m pytest --cov=src/telogs --cov-report=term-missing

demo:
	TELOGS_SECRET=$${TELOGS_SECRET:-dev-secret} $(PY) scripts/write_log.py "demo start" --level INFO
	TELOGS_SECRET=$${TELOGS_SECRET:-dev-secret} $(PY) scripts/write_log.py "login" --level INFO --user=alice
	TELOGS_SECRET=$${TELOGS_SECRET:-dev-secret} $(PY) scripts/write_log.py "done" --level INFO
	$(PY) scripts/verify_log.py
	$(PY) scripts/summarize_log.py

up:
	docker compose up -d --build

clean:
	rm -rf $(VENV) artifacts/release/*.*