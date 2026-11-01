#!/usr/bin/env bash
# Headless GitHub Actions runners have no sound card; MPV needs a default output.
set -euo pipefail

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/retroplayer-ci-xdg-runtime}"
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

if ! command -v pulseaudio >/dev/null || ! command -v pactl >/dev/null; then
  echo 'pulseaudio/pactl not installed; skip virtual audio setup' >&2
  exit 0
fi

if ! pulseaudio --check 2>/dev/null; then
  pulseaudio -D \
    --exit-idle-time=-1 \
    --realtime=false \
    --disable-shm=true \
    --log-level=error \
    --log-target=stderr
fi

# Null sink so mpv/ALSA "default" opens without hardware.
pactl load-module module-null-sink \
  sink_name=retroplayer_ci \
  sink_properties=device.description=RetroPlayerCI >/dev/null 2>&1 || true
pactl set-default-sink retroplayer_ci 2>/dev/null || true

pactl info | head -5
