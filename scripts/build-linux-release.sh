#!/usr/bin/env bash
# Release Linux bundle with a fresh Dart AOT compile.
#
# `rm -rf build/linux` alone is not enough: Flutter keeps Linux AOT under
# .dart_tool/flutter_build and may skip recompiling Dart when only the CMake
# tree was deleted. Use this script after lib/ changes.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

CLEAN=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --clean)
      CLEAN=1
      shift
      ;;
    -h | --help)
      echo "Usage: $(basename "$0") [--clean]" >&2
      echo "  --clean  run flutter clean before build (slowest, most reliable)" >&2
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

if [[ "$CLEAN" -eq 1 ]]; then
  flutter clean
else
  rm -rf build/linux
  # Drop Linux release AOT stamps so Dart is recompiled even without full clean.
  find .dart_tool/flutter_build -maxdepth 2 -name 'linux_aot_bundle.stamp' -delete 2>/dev/null || true
  find .dart_tool/flutter_build -maxdepth 2 -name 'aot_elf_release.stamp' -delete 2>/dev/null || true
  find .dart_tool/flutter_build -maxdepth 2 -name 'app.so' -delete 2>/dev/null || true
fi

flutter pub get
flutter build linux --release

BUNDLE="$ROOT/build/linux/x64/release/bundle"
LIBAPP="$BUNDLE/lib/libapp.so"
echo ""
echo "Built: $BUNDLE/retroplayer"
if [[ -f "$LIBAPP" ]]; then
  echo "libapp.so: $(stat -c '%y' "$LIBAPP" 2>/dev/null || stat -f '%Sm' "$LIBAPP")"
fi
echo "Run: $BUNDLE/retroplayer"
echo "Install menu entry: ./scripts/install-linux-desktop.sh"
