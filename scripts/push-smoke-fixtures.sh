#!/usr/bin/env bash
# Push RetroPlayerSamples plus a LongList folder for the index-bar device test.
#
# Usage: scripts/push-smoke-fixtures.sh
#
# Requires: adb, ffmpeg, booted emulator/device. Calls repo push-sample-audio-to-emulator.sh
# first, then adds LongList/ with 31 subfolders (alpha, track00..track28, zebra) of one
# track each: the index bar counts rows, and loose tracks would group into one album.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
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
    -metadata track="${track}" \
    "${output}"
}

echo "Generating LongList fixtures in ${SAMPLE_LONG}..."
rm -rf "${SAMPLE_LONG}"
mkdir -p "${SAMPLE_LONG}"

names=(alpha $(seq -f 'track%02g' 0 28) zebra)
for i in "${!names[@]}"; do
  mkdir -p "${SAMPLE_LONG}/${names[$i]}"
  generate_tone "${SAMPLE_LONG}/${names[$i]}/tone.mp3" $((400 + i * 10)) 1 "${names[$i]}" 1
done

echo "Pushing LongList to ${DEVICE_LONG}..."
adb shell mkdir -p "${DEVICE_LONG}"
adb push "${SAMPLE_LONG}/." "${DEVICE_LONG}/"

adb shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE \
  -d "file://${DEVICE_LONG}" >/dev/null 2>&1 || true

echo "LongList ready (31 one-track folders for the index bar)."
