#!/usr/bin/env bash
# Push RetroPlayerSamples plus a LongList folder for T09 index-bar smoke (>30 rows).
#
# Usage: scripts/push-smoke-fixtures.sh
#
# Requires: adb, ffmpeg, booted emulator/device. Calls repo push-sample-audio-to-emulator.sh
# first, then adds LongList/ with 31 audio tracks + Sub/ subfolder.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=/dev/null
source "${ROOT}/scripts/_android_env.sh"

DEVICE_LONG="/sdcard/Music/RetroPlayerSamples/LongList"
SAMPLE_LONG="${TMPDIR:-/tmp}/retroplayer-longlist"

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "error: ffmpeg not found" >&2
  exit 1
fi

"${ROOT}/scripts/push-sample-audio-to-emulator.sh"

generate_tone() {
  local output="$1" frequency="$2" duration="$3" title="$4" track="${5:-1}"
  ffmpeg -y -loglevel error \
    -f lavfi -i "sine=frequency=${frequency}:duration=${duration}" \
    -metadata title="${title}" \
    -metadata artist="Long List" \
    -metadata album="LongList" \
    -metadata track="${track}" \
    "${output}"
}

echo "Generating LongList fixtures in ${SAMPLE_LONG}..."
rm -rf "${SAMPLE_LONG}"
mkdir -p "${SAMPLE_LONG}/Sub"

generate_tone "${SAMPLE_LONG}/alpha.mp3" 440 2 "alpha" 1
for i in $(seq 0 28); do
  freq=$((400 + i * 10))
  generate_tone "${SAMPLE_LONG}/track${i}.mp3" "${freq}" 2 "track${i}" $((i + 2))
done
generate_tone "${SAMPLE_LONG}/zebra.mp3" 880 2 "zebra" 32
touch "${SAMPLE_LONG}/Sub/.keep"

echo "Pushing LongList to ${DEVICE_LONG}..."
adb shell mkdir -p "${DEVICE_LONG}"
adb push "${SAMPLE_LONG}/." "${DEVICE_LONG}/"

adb shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE \
  -d "file://${DEVICE_LONG}" >/dev/null 2>&1 || true

echo "LongList ready (31 audio tracks + Sub/ folder for index-bar smoke)."
