import argparse, os
from telogs import TELogger

def parse_kv(args):
    extra = {}
    for item in args:
        if item.startswith("--") and "=" in item:
            k, v = item[2:].split("=", 1)
            extra[k] = v
    return extra

def main():
    p = argparse.ArgumentParser(description="Append a chained log entry.")
    p.add_argument("message")
    p.add_argument("--log", default="artifacts/release/app.log")
    p.add_argument("--level", default="INFO")
    p.add_argument("--secret", default=None)
    args, rest = p.parse_known_args()

    secret = args.secret or os.getenv("TELOGS_SECRET")
    extra = parse_kv(rest)

    logger = TELogger(args.log, secret=secret)
    logger.write(args.level, args.message, **extra)
    print(f"Wrote entry to {args.log}")

if __name__ == "__main__":
    main()