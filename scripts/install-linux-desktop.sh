#!/usr/bin/env bash
# Install Retro Player .desktop entry and hicolor icons for GNOME/KDE taskbar.
#
# Icon policy (keep in sync with linux/runner/my_application.cc):
# - Copy only app.retroplayer.png under hicolor/*/apps/
# - Never write ~/.local/share/icons/hicolor/index.theme (shadows system theme)
# - Never run gtk-update-icon-cache on the user hicolor root
# - Remove stale index.theme and icon-theme.cache on install
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_ID="app.retroplayer"
FORCE=0

usage() {
  echo "Usage: $0 [--force] [path/to/bundle/dir]" >&2
  echo "  Default bundle: release if present, else debug." >&2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      FORCE=1
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      break
      ;;
  esac
done

if [[ $# -ge 1 ]]; then
  BUNDLE="$1"
else
  RELEASE="$ROOT/build/linux/x64/release/bundle"
  DEBUG="$ROOT/build/linux/x64/debug/bundle"
  if [[ -x "$RELEASE/retroplayer" ]]; then
    BUNDLE="$RELEASE"
  else
    BUNDLE="$DEBUG"
  fi
fi

EXEC="$BUNDLE/retroplayer"

if [[ ! -x "$EXEC" ]]; then
  echo "Bundle binary not found: $EXEC" >&2
  usage
  exit 1
fi

BUNDLE_INDEX_THEME="$BUNDLE/share/icons/hicolor/index.theme"
if [[ -f "$BUNDLE_INDEX_THEME" && "$FORCE" -eq 0 ]]; then
  echo "Bundle contains a packaged hicolor/index.theme (pre-741c9cb build)." >&2
  echo "Rebuild with: flutter build linux" >&2
  echo "Or pass --force to install anyway (index.theme is never copied to ~/.local)." >&2
  exit 1
fi

DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
DESKTOP_DIR="$DATA_HOME/applications"
ICON_ROOT="$DATA_HOME/icons/hicolor"
INSTALLED_ICON_256="$ICON_ROOT/256x256/apps/$APP_ID.png"

mkdir -p "$DESKTOP_DIR" "$ICON_ROOT"

REMOVED_STUB=0
if [[ -f "$ICON_ROOT/index.theme" || -f "$ICON_ROOT/icon-theme.cache" ]]; then
  REMOVED_STUB=1
fi
rm -f "$ICON_ROOT/index.theme" "$ICON_ROOT/icon-theme.cache"

for size in 48 128 256 512 1024; do
  src="$BUNDLE/share/icons/hicolor/${size}x${size}/apps/$APP_ID.png"
  [[ -f "$src" ]] || continue
  dest_dir="$ICON_ROOT/${size}x${size}/apps"
  mkdir -p "$dest_dir"
  cp "$src" "$dest_dir/$APP_ID.png"
done

if [[ ! -f "$INSTALLED_ICON_256" ]]; then
  echo "No icons copied from $BUNDLE/share/icons/hicolor/*/apps/$APP_ID.png" >&2
  exit 1
fi

cat >"$DESKTOP_DIR/$APP_ID.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Retro Player
Comment=Local audio player for music and audiobooks
Exec=$EXEC
Icon=$APP_ID
Terminal=false
Categories=AudioVideo;Audio;Player;
StartupNotify=true
StartupWMClass=$APP_ID
EOF

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$DESKTOP_DIR" >/dev/null 2>&1 || true
fi

echo "Installed $DESKTOP_DIR/$APP_ID.desktop"
echo "Icons under $ICON_ROOT"
if [[ "$REMOVED_STUB" -eq 1 ]]; then
  echo "Removed user hicolor/index.theme or icon-theme.cache (see README if other app icons were blank)."
fi
echo "Restart the app (or log out/in) if the taskbar icon does not update."
