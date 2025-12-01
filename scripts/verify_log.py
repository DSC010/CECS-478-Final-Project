import argparse, os, json
from telogs import verify

def main():
    p = argparse.ArgumentParser(description="Verify log integrity.")
    p.add_argument("--log", default="artifacts/release/app.log")
    p.add_argument("--secret", default=None)
    p.add_argument("--summary", default="artifacts/release/verify_summary.json")
    args = p.parse_args()

    secret = args.secret or os.getenv("TELOGS_SECRET")
    ok, index, reason = verify(args.log, secret=secret)

    print(f"OK={ok} index={index} reason={reason}")

    os.makedirs(os.path.dirname(args.summary) or ".", exist_ok=True)
    with open(args.summary, "w") as f:
        json.dump({"ok": ok, "index": index, "reason": reason}, f, indent=2)

if __name__ == "__main__":
    raise SystemExit(main())