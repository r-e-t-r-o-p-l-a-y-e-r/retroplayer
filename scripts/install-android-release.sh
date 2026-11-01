#!/usr/bin/env bash
# Build a release APK and install it on a connected Android device.
#
# Usage:
#   ./scripts/install-android-release.sh              # pick device if several
#   ./scripts/install-android-release.sh -d SERIAL    # use this adb serial
#   ./scripts/install-android-release.sh --no-launch  # install only
#   ANDROID_SERIAL=... ./scripts/install-android-release.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_android_env.sh
source "${SCRIPT_DIR}/_android_env.sh"

APP_ID="app.retroplayer"
APK_PATH="${PROJECT_ROOT}/build/app/outputs/flutter-apk/app-release.apk"
DEVICE=""
LAUNCH=1

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Build Retro Player as a release APK and install it via adb.

Options:
  -d, --device SERIAL   adb device serial (skip interactive picker)
  --no-launch           do not start the app after install
  -h, --help            show this help

Environment:
  ANDROID_SERIAL        same as --device (if --device is omitted)

If several devices are connected and no serial is given, you are prompted.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d | --device)
      DEVICE="${2:-}"
      if [[ -z "${DEVICE}" ]]; then
        echo "error: ${1} requires a serial" >&2
        exit 1
      fi
      shift 2
      ;;
    --no-launch)
      LAUNCH=0
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "${DEVICE}" && -n "${ANDROID_SERIAL:-}" ]]; then
  DEVICE="${ANDROID_SERIAL}"
fi

cd "${PROJECT_ROOT}"

if ! command -v flutter >/dev/null 2>&1; then
  echo "error: flutter not found on PATH" >&2
  exit 1
fi

DEVICE="$(pick_adb_device "${DEVICE}")"

echo "Project: ${PROJECT_ROOT}"
echo "JAVA_HOME: ${JAVA_HOME:-"(unset)"}"
echo "Device: ${DEVICE}"

echo "Stamping build info..."
dart run scripts/stamp_build_info.dart

echo "flutter pub get..."
flutter pub get

echo "Refreshing Android release config..."
refresh_android_release_plugins

echo "Building release APK..."
flutter build apk --release

if [[ ! -f "${APK_PATH}" ]]; then
  echo "error: APK not found at ${APK_PATH}" >&2
  exit 1
fi

BUILD_STAMP="$(date '+%Y-%m-%d %H:%M:%S %z')"
echo "Build finished at ${BUILD_STAMP}"
echo "APK: ${APK_PATH}"

echo "Installing ${APK_PATH} on ${DEVICE}..."
adb -s "${DEVICE}" install -r "${APK_PATH}"
echo "Installed ${APP_ID}"

if [[ "${LAUNCH}" -eq 1 ]]; then
  echo "Launching ${APP_ID}..."
  adb -s "${DEVICE}" shell am start -n "${APP_ID}/.MainActivity" >/dev/null
fi

echo "Done."
