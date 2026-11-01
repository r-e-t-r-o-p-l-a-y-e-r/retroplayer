#!/usr/bin/env bash
# Build the Android app (APK, app bundle, or install via flutter run).
#
# Usage:
#   ./scripts/build-android.sh [apk|appbundle|debug|run|install|dev]
#
# Defaults to release APK: build/app/outputs/flutter-apk/app-release.apk

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_android_env.sh
source "${SCRIPT_DIR}/_android_env.sh"

TARGET="${1:-apk}"
APP_ID="app.retroplayer"

usage() {
  cat <<EOF
Usage: $(basename "$0") [TARGET]

Targets:
  apk         Release APK (default)
  appbundle   Release App Bundle (.aab) for Play Store
  debug       Debug APK only (no install)
  run         flutter run on a connected device/emulator
  install     Build release APK and adb install it (prompts if several devices)
  dev         Start emulator, build debug APK, install, and launch app
  dev-samples Same as dev, then push sample audio to Music/RetroPlayerSamples

Environment:
  ANDROID_SERIAL   Prefer this adb device for install/run targets

Examples:
  $(basename "$0")
  $(basename "$0") install
  ANDROID_SERIAL=emulator-5554 $(basename "$0") install
  $(basename "$0") dev-samples
  $(basename "$0") appbundle
  $(basename "$0") run

Prefer ./scripts/install-android-release.sh for an interactive release install.
EOF
}

# Sets ADB_SERIAL for subsequent adb calls (prompts if several devices).
resolve_install_device() {
  ADB_SERIAL="$(pick_adb_device "${ANDROID_SERIAL:-${DEVICE_SERIAL:-}}")"
  export ANDROID_SERIAL="${ADB_SERIAL}"
}

install_apk() {
  local apk="$1"
  resolve_install_device
  echo "Installing ${apk} on ${ADB_SERIAL}..."
  adb -s "${ADB_SERIAL}" install -r "${apk}"
  echo "Installed ${APP_ID}"
}

launch_app() {
  resolve_install_device
  echo "Launching ${APP_ID} on ${ADB_SERIAL}..."
  adb -s "${ADB_SERIAL}" shell am start -n "${APP_ID}/.MainActivity" >/dev/null
}

if [[ "${TARGET}" == "-h" || "${TARGET}" == "--help" ]]; then
  usage
  exit 0
fi

cd "${PROJECT_ROOT}"

if ! command -v flutter >/dev/null 2>&1; then
  echo "error: flutter not found on PATH" >&2
  exit 1
fi

echo "Project: ${PROJECT_ROOT}"
flutter pub get

case "${TARGET}" in
  apk)
    echo "Refreshing Android release config..."
    refresh_android_release_plugins
    echo "Building release APK..."
    flutter build apk --release
    OUT="${PROJECT_ROOT}/build/app/outputs/flutter-apk/app-release.apk"
    echo "Built: ${OUT}"
    ;;
  appbundle)
    echo "Refreshing Android release config..."
    refresh_android_release_plugins
    echo "Building release App Bundle..."
    flutter build appbundle --release
    OUT="${PROJECT_ROOT}/build/app/outputs/bundle/release/app-release.aab"
    echo "Built: ${OUT}"
    ;;
  debug)
    echo "Building debug APK..."
    flutter build apk --debug
    OUT="${PROJECT_ROOT}/build/app/outputs/flutter-apk/app-debug.apk"
    echo "Built: ${OUT}"
    ;;
  run)
    echo "Running on Android device/emulator..."
    exec flutter run -d android
    ;;
  install)
    exec "${SCRIPT_DIR}/install-android-release.sh"
    ;;
  dev)
    "${SCRIPT_DIR}/start-android-emulator.sh"
    echo "Building debug APK..."
    flutter build apk --debug
    install_apk "${PROJECT_ROOT}/build/app/outputs/flutter-apk/app-debug.apk"
    launch_app
    echo "Done. App is running on the emulator."
    ;;
  dev-samples)
    "${SCRIPT_DIR}/start-android-emulator.sh"
    echo "Building debug APK..."
    flutter build apk --debug
    install_apk "${PROJECT_ROOT}/build/app/outputs/flutter-apk/app-debug.apk"
    launch_app
    "${SCRIPT_DIR}/push-sample-audio-to-emulator.sh"
    echo "Done. App is running with sample audio on the device."
    ;;
  *)
    echo "error: unknown target '${TARGET}'" >&2
    usage >&2
    exit 1
    ;;
esac
