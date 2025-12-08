PYTHON = python3
VENV = .venv/bin
PYTHONPATH = src

clean:
	rm -rf artifacts/tamper artifacts/release
	mkdir -p artifacts/tamper artifacts/release

up: bootstrap

bootstrap:
	$(PYTHON) -m venv .venv
	$(VENV)/pip install -r requirements.txt

demo:
	export PYTHONPATH=$(PYTHONPATH); \
	./demo_tampering.sh
