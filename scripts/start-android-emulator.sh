#!/usr/bin/env bash
# Start the Android emulator and wait until it is ready for adb.
#
# Usage:
#   ./scripts/start-android-emulator.sh [AVD_ID]
#
# Environment:
#   ANDROID_AVD_ID   Default AVD when no argument is given
#   ANDROID_HOME     Android SDK root (auto-detected from local.properties)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_android_env.sh
source "${SCRIPT_DIR}/_android_env.sh"

AVD_ID="${1:-${ANDROID_AVD_ID:-}}"

usage() {
  cat <<EOF
Usage: $(basename "$0") [AVD_ID]

Start an Android Virtual Device and wait until boot completes.

Examples:
  $(basename "$0")
  $(basename "$0") routePlannerApi34
  ANDROID_AVD_ID=routePlannerApi34 $(basename "$0")

Available AVDs:
EOF
  if command -v emulator >/dev/null 2>&1; then
    emulator -list-avds | sed 's/^/  /' || true
  else
    echo "  (emulator binary not found — check ANDROID_HOME)"
  fi
}

if [[ "${AVD_ID}" == "-h" || "${AVD_ID}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ -z "${AVD_ID}" ]]; then
  echo "error: no AVD id. Pass one as an argument or set ANDROID_AVD_ID." >&2
  usage >&2
  exit 1
fi

if ! command -v adb >/dev/null 2>&1; then
  echo "error: adb not found. ANDROID_HOME=${ANDROID_HOME}" >&2
  exit 1
fi

if adb devices 2>/dev/null | awk 'NR>1 && $2=="device" {found=1} END {exit !found}'; then
  echo "Android device already connected:"
  adb devices -l
  exit 0
fi

if ! command -v emulator >/dev/null 2>&1; then
  echo "error: emulator not found on PATH. ANDROID_HOME=${ANDROID_HOME}" >&2
  exit 1
fi
echo "Launching emulator '${AVD_ID}'..."
emulator -avd "${AVD_ID}" -no-snapshot-load -no-snapshot-save -gpu host &

echo "Waiting for adb device..."
adb wait-for-device

echo "Waiting for boot to complete..."
boot_completed=""
for _ in $(seq 1 120); do
  boot_completed="$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r' || true)"
  if [[ "${boot_completed}" == "1" ]]; then
    break
  fi
  sleep 2
done

if [[ "${boot_completed}" != "1" ]]; then
  echo "warning: boot may not be finished yet (sys.boot_completed != 1)" >&2
else
  echo "Emulator ready."
fi

adb devices -l
