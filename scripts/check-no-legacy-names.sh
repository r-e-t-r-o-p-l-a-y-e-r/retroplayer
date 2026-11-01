#!/usr/bin/env bash
# Fail if forbidden pre-release identifiers appear in the tree (public export gate).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PATTERN='retropodcase|retropodcaseplayer|RetroPodcase|com\.retropodcase'

if matches="$(rg -i "$PATTERN" . \
  --glob '!.git' \
  --glob '!scripts/check-no-legacy-names.sh' \
  2>/dev/null || true)"; then
  if [[ -n "$matches" ]]; then
    echo "Legacy naming found (must be zero before public export):" >&2
    echo "$matches" >&2
    exit 1
  fi
fi

echo "OK: no legacy naming matches."
