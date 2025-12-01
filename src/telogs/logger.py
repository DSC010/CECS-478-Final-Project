import json, time, os, hmac, hashlib
from dataclasses import dataclass, asdict
from typing import Any, Dict, Tuple, Union

_FIRST_PREV = "0" * 64

def _secret_bytes(secret: Union[str, bytes, None]) -> bytes:
    if secret is None:
        secret = os.getenv("TELOGS_SECRET", "dev-secret")
    if isinstance(secret, str):
        secret = secret.encode("utf-8")
    return secret

@dataclass
class LogEntry:
    ts: float
    level: str
    msg: str
    extra: Dict[str, Any]
    prev_hmac: str
    hmac: str = ""

    def canonical_bytes(self) -> bytes:
        obj = {
            "ts": self.ts,
            "level": self.level,
            "msg": self.msg,
            "extra": self.extra,
            "prev_hmac": self.prev_hmac,
        }
        return json.dumps(obj, sort_keys=True, separators=(",", ":")).encode("utf-8")

class TELogger:
    """Tamper-evident append-only logger."""
    def __init__(self, path: str, secret: Union[str, bytes, None] = None):
        self.path = path
        self.secret = _secret_bytes(secret)
        os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
        if not os.path.exists(path):
            with open(path, "w", encoding="utf-8"):
                pass

    def _last_hmac(self) -> str:
        last = _FIRST_PREV
        with open(self.path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    obj = json.loads(line)
                except json.JSONDecodeError:
                    break
                last = obj.get("hmac", last)
        return last

    def write(self, level: str, msg: str, **extra: Any) -> None:
        prev = self._last_hmac()
        entry = LogEntry(ts=time.time(), level=level, msg=msg, extra=extra, prev_hmac=prev)
        digest = hmac.new(self.secret, entry.canonical_bytes(), hashlib.sha256).hexdigest()
        entry.hmac = digest
        with open(self.path, "a", encoding="utf-8") as f:
            f.write(json.dumps(asdict(entry), sort_keys=True, separators=(",", ":")) + "\n")

def verify(path: str, secret: Union[str, bytes, None] = None) -> Tuple[bool, int, str]:
    secret_b = _secret_bytes(secret)
    prev = _FIRST_PREV
    index = -1
    with open(path, "r", encoding="utf-8") as f:
        for index, line in enumerate(f):
            if not line.strip():
                continue
            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                return False, index, "json parse error"
            if obj.get("prev_hmac") != prev:
                return False, index, "prev_hmac mismatch"
            temp = dict(obj)
            temp.pop("hmac", None)
            canon = json.dumps(temp, sort_keys=True, separators=(",", ":")).encode("utf-8")
            expect = hmac.new(secret_b, canon, hashlib.sha256).hexdigest()
            if obj.get("hmac") != expect:
                return False, index, "hmac mismatch"
            prev = obj.get("hmac", "")
    return True, index, "ok"