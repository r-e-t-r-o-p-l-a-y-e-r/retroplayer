#!/usr/bin/env bash
# Real-device / emulator screenshots for doc/USAGE.md (readable UI, not widget-test renders).
#
# Usage:
#   ./scripts/capture-tutorial-screenshots-adb.sh
#
# Installs debug build + sample audio, then prompts before each screencap.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUT="${PROJECT_ROOT}/doc/images/tutorial"

# shellcheck source=_android_env.sh
source "${SCRIPT_DIR}/_android_env.sh"

cd "${PROJECT_ROOT}"
mkdir -p "${OUT}"

DEVICE="$(pick_adb_device "${ANDROID_SERIAL:-${DEVICE_SERIAL:-}}")"
export ANDROID_SERIAL="${DEVICE}"

echo "Device: ${DEVICE}"
echo "Installing app + sample library..."
"${SCRIPT_DIR}/build-android.sh" dev-samples

shot() {
  local file="$1"
  local hint="$2"
  echo ""
  echo "=== ${file} ==="
  echo "${hint}"
  read -r -p "Press Enter when the screen is ready..."
  adb -s "${DEVICE}" exec-out screencap -p > "${OUT}/${file}"
  echo "Saved ${OUT}/${file}"
}

shot "01-library.png" "Library with Demo Album visible (Add folder → Music → RetroPlayerSamples if empty)."
shot "02-mini-player.png" "Start playback; collapsed mini player at bottom."
shot "03-expanded-player.png" "Swipe or tap handle to expand Now Playing."
shot "04-album-detail.png" "Open Demo Album track list."
shot "06-settings.png" "Open Settings from the app bar."

echo "Done. Review PNGs in ${OUT}"
