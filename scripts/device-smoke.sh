#!/usr/bin/env bash
# Device smoke test: the instrumented end-to-end tests in app/src/androidTest (DeviceSmokeTest).
#
# Usage (from the repo root, emulator booted):
#   scripts/device-smoke.sh            push fixtures if missing, then run every test
#   scripts/device-smoke.sh <method>   run one test, e.g. theQueueSavesAsAPlaylistThatCanBeDeleted
#
# Environment:
#   FIXTURES=1       push the sample audio even if it is already on the device
#   ANDROID_SERIAL   pick a device (default: the first running emulator)

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
adb="${ANDROID_HOME:-$HOME/Android/Sdk}/platform-tools/adb"

# Gradle would run on every attached device; the tests clear app data, so default to the emulator.
if [ -z "${ANDROID_SERIAL:-}" ]; then
  ANDROID_SERIAL="$("$adb" devices | awk '$1 ~ /^emulator-/ && $2 == "device" { print $1; exit }')"
  [ -n "$ANDROID_SERIAL" ] || { echo "error: no emulator running (set ANDROID_SERIAL to use a device)" >&2; exit 1; }
fi
export ANDROID_SERIAL

if [ "$("$adb" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" != "1" ]; then
  echo "error: no booted device (boot an emulator first; see AGENTS.md)" >&2
  exit 1
fi

if [ "${FIXTURES:-0}" = "1" ] || ! "$adb" shell ls /sdcard/Music/RetroPlayerSamples/LongList/zebra >/dev/null 2>&1; then
  scripts/push-smoke-fixtures.sh
fi

filter=()
if [ $# -gt 0 ]; then
  filter=("-Pandroid.testInstrumentationRunnerArguments.class=app.retroplayer.smoke.DeviceSmokeTest#$1")
fi

if ./gradlew -q :app:connectedDebugAndroidTest "${filter[@]}"; then
  echo "Device smoke passed."
else
  echo "Device smoke failed; report: app/build/reports/androidTests/connected/debug/index.html" >&2
  exit 1
fi
