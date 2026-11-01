#!/usr/bin/env bash
# Wait for Google rate-limit cooldown, then run MT (two attempts max).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG="${ROOT}/.mt_l10n_retry.log"
cd "$ROOT"

log() {
  echo "[$(date -Iseconds)] $*"
}

run_mt() {
  log "Running python3 scripts/mt_l10n_arbs.py --backend mymemory …"
  if python3 scripts/mt_l10n_arbs.py --backend mymemory ${MYMEMORY_EMAIL:+--email "$MYMEMORY_EMAIL"} >>"$LOG" 2>&1; then
    log "MT succeeded; running flutter gen-l10n …"
    flutter gen-l10n >>"$LOG" 2>&1
    log "Done."
    return 0
  fi
  log "MT failed (see log)."
  return 1
}

log "Scheduled retry: first attempt in 60 minutes."
sleep 3600

if run_mt; then
  exit 0
fi

log "First attempt failed; waiting 300 minutes before final attempt."
sleep 18000

run_mt || exit 1
