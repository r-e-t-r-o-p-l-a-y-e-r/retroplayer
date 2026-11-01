#!/usr/bin/env bash
# Re-run MT until all locales succeed, sleeping when MyMemory daily quota resets.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG="${ROOT}/.mt_l10n_retry.log"
cd "$ROOT"

if [[ -z "${MYMEMORY_EMAIL:-}" ]]; then
  echo "Set MYMEMORY_EMAIL (higher MyMemory word limit)." >&2
  exit 1
fi

quota_sleep_seconds() {
  python3 - "$LOG" <<'PY'
import re
import sys
from pathlib import Path

log = Path(sys.argv[1]).read_text(encoding="utf-8", errors="replace")
matches = list(
    re.finditer(
        r"NEXT AVAILABLE IN\s+(\d+)\s+HOURS\s+(\d+)\s+MINUTES"
        r"(?:\s+(\d+)\s+SECONDS)?",
        log,
        re.IGNORECASE,
    )
)
if not matches:
    print(3600)
else:
    h, m, s = matches[-1].groups()
    print(int(h) * 3600 + int(m) * 60 + int(s or 0) + 300)
PY
}

while true; do
  echo "[$(date -Iseconds)] mt_l10n_arbs.py …" | tee -a "$LOG"
  if python3 scripts/mt_l10n_arbs.py --backend mymemory --email "$MYMEMORY_EMAIL" 2>&1 | tee -a "$LOG"; then
    echo "[$(date -Iseconds)] All locales done." | tee -a "$LOG"
    flutter gen-l10n 2>&1 | tee -a "$LOG"
    exit 0
  fi

  if ! grep -q "MYMEMORY WARNING" "$LOG"; then
    echo "[$(date -Iseconds)] Failed without MyMemory quota hint; stopping." | tee -a "$LOG"
    exit 1
  fi

  sleep_for="$(quota_sleep_seconds)"
  if (( sleep_for > 7200 )); then
    echo "[$(date -Iseconds)] Quota reset in ~$((sleep_for / 60)) min." | tee -a "$LOG"
    echo "Stopped: use --backend google-cloud or azure to finish remaining locales (see doc/L10N_MT_CLOUD.md)." | tee -a "$LOG"
    exit 1
  fi
  echo "[$(date -Iseconds)] Quota wait: sleeping ${sleep_for}s …" | tee -a "$LOG"
  sleep "$sleep_for"
done
