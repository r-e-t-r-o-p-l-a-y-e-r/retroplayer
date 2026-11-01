#!/usr/bin/env bash
# Refresh non-English ARBs from app_en.arb using cloud MT (.env credentials).
#
# Usage (from repo root):
#   ./scripts/update_l10n_locales.sh
#   ./scripts/update_l10n_locales.sh --skip-tests
#
# Requires at least one of in .env (see .env.example):
#   DEEPL_AUTH_KEY
#   GOOGLE_CLOUD_TRANSLATE_API_KEY
#   AZURE_TRANSLATOR_KEY + AZURE_TRANSLATOR_REGION
#
# DeepL is used when --backend deepl; Google/Azure fill locales DeepL skips.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SKIP_TESTS=0
for arg in "$@"; do
  case "$arg" in
    --skip-tests) SKIP_TESTS=1 ;;
    -h | --help)
      sed -n '1,20p' "$0"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

if ! python3 - <<'PY'
import os
from pathlib import Path

def load_dotenv(path: Path) -> None:
    if not path.is_file():
        return
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        k, _, v = line.partition("=")
        v = v.strip().strip('"').strip("'")
        if k.strip() and v:
            os.environ.setdefault(k.strip(), v)

load_dotenv(Path(".env"))
has_deepl = bool(os.environ.get("DEEPL_AUTH_KEY"))
has_google = bool(os.environ.get("GOOGLE_CLOUD_TRANSLATE_API_KEY"))
has_azure = bool(
    os.environ.get("AZURE_TRANSLATOR_KEY")
    and os.environ.get("AZURE_TRANSLATOR_REGION")
)
if not (has_deepl or has_google or has_azure):
    raise SystemExit(
        "No MT credentials in .env. Copy .env.example → .env and set "
        "DEEPL_AUTH_KEY and/or Google Cloud / Azure (see doc/L10N_MT_CLOUD.md)."
    )
print(
    "Credentials:",
    "deepl" if has_deepl else "-",
    "google-cloud" if has_google else "-",
    "azure" if has_azure else "-",
)
PY
then
  exit 1
fi

echo "== sync ARB keys from app_en.arb =="
dart run scripts/sync_l10n_arbs.dart

echo "== repair corruption / placeholders =="
python3 scripts/repair_l10n_arbs.py

echo "== machine-translate (DeepL + cloud fallback) =="
python3 scripts/mt_l10n_arbs.py --backend deepl --fill-english-only
python3 scripts/mt_l10n_arbs.py --backend deepl --icu-only

echo "== flutter gen-l10n =="
flutter gen-l10n

if [[ "$SKIP_TESTS" -eq 0 ]]; then
  echo "== flutter test test/ui/l10n/ =="
  flutter test test/ui/l10n/
fi

echo "Done. Review diffs in lib/l10n/ before commit."
