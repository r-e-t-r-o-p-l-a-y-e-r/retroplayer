#!/usr/bin/env bash
# Generate short sample audio files and push them to a connected Android emulator/device.
#
# Usage:
#   ./scripts/push-sample-audio-to-emulator.sh
#
# In the app: Add folder → Music → RetroPlayerSamples

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_android_env.sh
source "${SCRIPT_DIR}/_android_env.sh"

DEVICE_PATH="/sdcard/Music/RetroPlayerSamples"
SAMPLE_ROOT="${TMPDIR:-/tmp}/retroplayer-samples"

usage() {
  cat <<EOF
Usage: $(basename "$0")

Creates demo MP3/WAV files and pushes them to:
  ${DEVICE_PATH}

Then in Retro Player:
  1. Tap "Add folder"
  2. Open Music → RetroPlayerSamples
  3. Select the RetroPlayerSamples folder

Requires: adb, ffmpeg, and a connected Android device/emulator.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if ! command -v adb >/dev/null 2>&1; then
  echo "error: adb not found" >&2
  exit 1
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "error: ffmpeg not found (install ffmpeg to generate sample audio)" >&2
  exit 1
fi

if ! adb devices 2>/dev/null | awk 'NR>1 && $2=="device" {found=1} END {exit !found}'; then
  echo "error: no Android device/emulator connected." >&2
  echo "Run: ${SCRIPT_DIR}/start-android-emulator.sh" >&2
  exit 1
fi

generate_tone() {
  local output="$1"
  local frequency="$2"
  local duration="$3"
  local title="$4"
  ffmpeg -y -loglevel error \
    -f lavfi -i "sine=frequency=${frequency}:duration=${duration}" \
    -metadata title="${title}" \
    -metadata artist="Demo Artist" \
    -metadata album="Demo Album" \
    -metadata track="${5:-1}" \
    "${output}"
}

echo "Generating sample audio in ${SAMPLE_ROOT}..."
rm -rf "${SAMPLE_ROOT}"
mkdir -p "${SAMPLE_ROOT}/Demo Artist/Demo Album"

generate_tone "${SAMPLE_ROOT}/Demo Artist/Demo Album/01-opening.mp3" 440 8 "Opening" 1
generate_tone "${SAMPLE_ROOT}/Demo Artist/Demo Album/02-middle.mp3" 523 8 "Middle" 2
generate_tone "${SAMPLE_ROOT}/Demo Artist/Demo Album/03-finale.mp3" 659 8 "Finale" 3
generate_tone "${SAMPLE_ROOT}/loose-demo.wav" 880 5 "Loose Track"

echo "Removing old samples on device (if any)..."
adb shell rm -rf "${DEVICE_PATH}" 2>/dev/null || true

echo "Pushing to device at ${DEVICE_PATH}..."
adb shell mkdir -p "${DEVICE_PATH}"
adb push "${SAMPLE_ROOT}/." "${DEVICE_PATH}/"

echo "Refreshing media index..."
adb shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d "file://${DEVICE_PATH}" >/dev/null 2>&1 || true

cat <<EOF

Sample audio installed on the emulator.

Folder on device:
  ${DEVICE_PATH}

Contents:
  Demo Artist/Demo Album/  (3 MP3 chapters)
  loose-demo.wav           (single loose track)

In the app:
  1. Tap "Add folder"
  2. Navigate to Music → RetroPlayerSamples
  3. Select RetroPlayerSamples
EOF
