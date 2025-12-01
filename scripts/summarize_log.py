#!/usr/bin/env python3
import argparse, json, os, csv

def main():
    p = argparse.ArgumentParser(description="Summarize TEL log.")
    p.add_argument("--log", default="artifacts/release/app.log")
    p.add_argument("--json_out", default="artifacts/release/log_summary.json")
    p.add_argument("--csv_out", default="artifacts/release/log_summary.csv")
    args = p.parse_args()

    count = 0
    levels = {}

    if os.path.exists(args.log):
        with open(args.log, "r") as f:
            for line in f:
                if not line.strip():
                    continue
                obj = json.loads(line)
                count += 1
                lvl = obj.get("level", "UNKNOWN")
                levels[lvl] = levels.get(lvl, 0) + 1

    os.makedirs(os.path.dirname(args.json_out) or ".", exist_ok=True)
    with open(args.json_out, "w") as f:
        json.dump({"entries": count, "levels": levels}, f, indent=2)

    with open(args.csv_out, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["level", "count"])
        for lvl, c in sorted(levels.items()):
            w.writerow([lvl, c])

    print("Wrote JSON and CSV summaries.")

if __name__ == "__main__":
    raise SystemExit(main())
