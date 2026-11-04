#!/usr/bin/env bash
# Build the native test version (debug, app id app.retroplayer.debug) and install it on a device.
# It installs next to a release build; data and folder grants are separate.
#
# Usage (from anywhere):
#   scripts/install-test-build.sh              # pick device if several
#   scripts/install-test-build.sh -d SERIAL    # use this adb serial
#   scripts/install-test-build.sh --no-launch  # install only
#   ANDROID_SERIAL=... scripts/install-test-build.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=_android_env.sh
source "${ROOT}/scripts/_android_env.sh"

APP_ID="app.retroplayer.debug"
APK_PATH="${ROOT}/app/build/outputs/apk/debug/app-debug.apk"
DEVICE="${ANDROID_SERIAL:-}"
LAUNCH=1

usage() { sed -n '2,9s/^# \{0,1\}//p' "$0"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d | --device)
      DEVICE="${2:-}"
      [[ -n "${DEVICE}" ]] || { echo "error: $1 requires a serial" >&2; exit 1; }
      shift 2
      ;;
    --no-launch) LAUNCH=0; shift ;;
    -h | --help) usage; exit 0 ;;
    *) echo "error: unknown argument: $1" >&2; usage >&2; exit 1 ;;
  esac
done

DEVICE="$(pick_adb_device "${DEVICE}")"
echo "Device: ${DEVICE}"

cd "${ROOT}"
echo "Building test APK..."
./gradlew -q :app:assembleDebug
[[ -f "${APK_PATH}" ]] || { echo "error: APK not found at ${APK_PATH}" >&2; exit 1; }

echo "Installing on ${DEVICE}..."
adb -s "${DEVICE}" install -r "${APK_PATH}"

if [[ "${LAUNCH}" -eq 1 ]]; then
  adb -s "${DEVICE}" shell am start -n "${APP_ID}/app.retroplayer.MainActivity" >/dev/null
  echo "Launched ${APP_ID}."
fi
echo "Done."
