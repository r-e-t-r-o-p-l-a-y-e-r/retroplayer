#!/usr/bin/env bash
# Package flutter linux release bundle as a tarball (+ optional sha256).
#
# Usage:
#   ./scripts/package-linux-release.sh [VERSION]
#
# VERSION defaults to pubspec version (e.g. 1.0.0).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
BUNDLE="${PROJECT_ROOT}/build/linux/x64/release/bundle"

version="${1:-}"
if [[ -z "${version}" ]]; then
  version="$(grep '^version:' "${PROJECT_ROOT}/pubspec.yaml" | sed 's/version: *//' | cut -d+ -f1)"
fi

if [[ ! -d "${BUNDLE}" || ! -x "${BUNDLE}/retroplayer" ]]; then
  echo "error: missing ${BUNDLE} — run: flutter build linux --release" >&2
  exit 1
fi

out_name="retroplayer-${version}-linux-x64"
out_dir="${PROJECT_ROOT}/build/release"
mkdir -p "${out_dir}"

tarball="${out_dir}/${out_name}.tar.gz"
tar -C "${PROJECT_ROOT}/build/linux/x64/release" -czf "${tarball}" bundle

sha="${tarball}.sha256"
if command -v sha256sum >/dev/null 2>&1; then
  sha256sum "${tarball}" > "${sha}"
elif command -v shasum >/dev/null 2>&1; then
  shasum -a 256 "${tarball}" > "${sha}"
fi

echo "Created ${tarball}"
[[ -f "${sha}" ]] && echo "Created ${sha}"
