#!/usr/bin/env bash
# Shared Android SDK and JDK paths for project scripts.
# shellcheck disable=SC2034

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LOCAL_PROPERTIES="${PROJECT_ROOT}/local.properties"

if [[ -f "${LOCAL_PROPERTIES}" ]]; then
  while IFS='=' read -r key value; do
    case "${key}" in
      sdk.dir) ANDROID_HOME="${value//\\:/:}" ;;
    esac
  done < <(grep -E '^sdk\.dir=' "${LOCAL_PROPERTIES}" || true)
fi

export ANDROID_HOME="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-${HOME}/Android/Sdk}}"
export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-${ANDROID_HOME}}"
export PATH="${ANDROID_HOME}/emulator:${ANDROID_HOME}/platform-tools:${PATH}"

resolve_java_home() {
  if [[ -n "${JAVA_HOME:-}" && -x "${JAVA_HOME}/bin/java" ]]; then
    echo "${JAVA_HOME}"
    return
  fi

  local candidate
  for candidate in \
    /usr/lib/jvm/java-17-temurin-jdk \
    /usr/lib/jvm/java-17-openjdk \
    /usr/lib/jvm/java-21-openjdk \
    /usr/lib/jvm/java-25-openjdk \
    /usr/lib/jvm/default-java; do
    if [[ -x "${candidate}/bin/java" ]]; then
      echo "${candidate}"
      return
    fi
  done

  if command -v java >/dev/null 2>&1; then
    dirname "$(dirname "$(readlink -f "$(command -v java)" 2>/dev/null || command -v java)")"
  fi
}

if [[ -n "${JAVA_HOME:-}" && ! -x "${JAVA_HOME}/bin/java" ]]; then
  echo "warning: JAVA_HOME is invalid (${JAVA_HOME}); auto-detecting JDK" >&2
fi

export JAVA_HOME="$(resolve_java_home)"
export PATH="${JAVA_HOME}/bin:${PATH}"

default_avd_id() {
  if command -v emulator >/dev/null 2>&1; then
    emulator -list-avds 2>/dev/null | head -n1
  fi
}

export ANDROID_AVD_ID="${ANDROID_AVD_ID:-$(default_avd_id)}"

# Prints "serial\tmodel" lines for authorized adb devices (status == device).
list_adb_devices() {
  adb devices -l 2>/dev/null | awk '
    NR > 1 && $2 == "device" {
      serial = $1
      model = ""
      for (i = 3; i <= NF; i++) {
        if ($i ~ /^model:/) {
          model = $i
          sub(/^model:/, "", model)
          gsub(/_/, " ", model)
        }
      }
      if (model == "") model = "(unknown model)"
      print serial "\t" model
    }
  '
}

# Resolve an adb serial: optional preferred id, else sole device, else interactive prompt.
# Usage: pick_adb_device [preferred_serial]
# Prints the chosen serial on stdout.
pick_adb_device() {
  local preferred="${1:-}"
  local -a serials=()
  local -a models=()
  local line serial model

  if ! command -v adb >/dev/null 2>&1; then
    echo "error: adb not found on PATH" >&2
    return 1
  fi

  while IFS=$'\t' read -r serial model; do
    [[ -z "${serial}" ]] && continue
    serials+=("${serial}")
    models+=("${model}")
  done < <(list_adb_devices)

  if [[ ${#serials[@]} -eq 0 ]]; then
    echo "error: no authorized Android device/emulator (adb status 'device')." >&2
    echo "Enable USB debugging, accept the RSA prompt, then run: adb devices" >&2
    return 1
  fi

  if [[ -n "${preferred}" ]]; then
    local s
    for s in "${serials[@]}"; do
      if [[ "${s}" == "${preferred}" ]]; then
        echo "${preferred}"
        return 0
      fi
    done
    echo "error: device '${preferred}' not found among connected devices:" >&2
    local i
    for i in "${!serials[@]}"; do
      echo "  ${serials[$i]}  ${models[$i]}" >&2
    done
    return 1
  fi

  if [[ ${#serials[@]} -eq 1 ]]; then
    echo "Using device: ${serials[0]} (${models[0]})" >&2
    echo "${serials[0]}"
    return 0
  fi

  echo "Connected Android devices:" >&2
  local i
  for i in "${!serials[@]}"; do
    printf '  %d) %s  %s\n' "$((i + 1))" "${serials[$i]}" "${models[$i]}" >&2
  done

  local choice
  while true; do
    read -r -p "Select device [1-${#serials[@]}]: " choice </dev/tty
    if [[ "${choice}" =~ ^[0-9]+$ ]] &&
      ((choice >= 1 && choice <= ${#serials[@]})); then
      echo "${serials[$((choice - 1))]}"
      return 0
    fi
    echo "Invalid choice." >&2
  done
}
