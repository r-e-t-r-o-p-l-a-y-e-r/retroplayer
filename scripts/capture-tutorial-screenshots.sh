#!/usr/bin/env bash
# Capture tutorial PNGs for doc/USAGE.md (widget test with real fonts).
#
# Usage:
#   ./scripts/capture-tutorial-screenshots.sh
#
# For store-quality shots from a real phone/emulator, prefer:
#   ./scripts/capture-tutorial-screenshots-adb.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUT="${PROJECT_ROOT}/doc/images/tutorial"
GOLDENS="${PROJECT_ROOT}/test/ui/doc/goldens"
cd "${PROJECT_ROOT}"
mkdir -p "${OUT}" "${GOLDENS}"

flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart run scripts/stamp_build_info.dart

echo "Rendering tutorial frames (412×915 logical @ 3×, fonts loaded) ..."
flutter test test/ui/doc/tutorial_screenshots_test.dart

if compgen -G "${OUT}/01-library.png" > /dev/null; then
  echo "Screenshots copied to ${OUT}"
  ls -la "${OUT}"/*.png
else
  echo "error: run with --update to generate goldens first" >&2
  exit 1
fi
