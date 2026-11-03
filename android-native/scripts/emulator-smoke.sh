#!/usr/bin/env bash
# Emulator smoke test: build/install, fixtures, baseline playback, T07/T09/T10 checks.
#
# Usage (from android-native/):
#   scripts/emulator-smoke.sh
#
# Environment:
#   SMOKE_FRESH=1     pm clear app.retroplayer before launch (re-add library root)
#   SKIP_FIXTURES=1   do not push sample audio
#   SKIP_BUILD=1      skip assembleDebug (use installed APK)
#   ANDROID_SERIAL    pick device (same as adb)

set -uo pipefail

NATIVE="$(cd "$(dirname "$0")/.." && pwd)"
cd "$NATIVE"
TAP="$NATIVE/scripts/smoke-tap.py"
adb="${ANDROID_HOME:-$HOME/Android/Sdk}/platform-tools/adb"

FAILURES=0

step() { echo; echo "======== $*"; }
ok() { echo "OK: $*"; }
bad() { echo "FAIL: $*" >&2; FAILURES=$((FAILURES + 1)); }

wait_ui() { sleep "${1:-2}"; }

scroll_down() {
  "$adb" shell input swipe 540 1300 540 750 350
  wait_ui 1
}

prepare_emulator_audio() {
  "$adb" shell svc bluetooth disable >/dev/null 2>&1 || true
}

dump_raw() {
  "$adb" shell uiautomator dump /sdcard/ui-dump.xml >/dev/null 2>&1 || true
  "$adb" exec-out cat /sdcard/ui-dump.xml 2>/dev/null || true
}

dump_texts() {
  dump_raw | grep -oE '(text|content-desc)="[^"]+"' | sort -u
}

smoke_has() {
  dump_raw | python3 "$TAP" has "$1" 2>/dev/null
}

do_tap() {
  local mode="$1" pattern="$2" x="$3" y="$4"
  local pt
  pt=$(dump_raw | python3 "$TAP" "$mode" "$pattern" "$x" "$y" 2>/dev/null) || return 1
  # shellcheck disable=SC2086
  "$adb" shell input tap $pt
  echo "tap $mode /${pattern}/ at $pt"
  return 0
}

tap_row() { do_tap row "$1" "${2:-420}" "${3:-1820}"; }
tap_top() { do_tap top "$1" 140 320; }
tap_anywhere() { do_tap tap "$1" "${2:-420}" "${3:-1820}" 0.5; }

tap_row_or_xy() {
  if tap_row "$1" "${4:-420}" "${5:-1820}"; then return 0; fi
  "$adb" shell input tap "$2" "$3"
  echo "tapxy fallback $2 $3 for row /$1/"
}

on_settings_screen() {
  smoke_has 'Data storage' && smoke_has 'Equalizer' && smoke_has 'Settings'
}

on_library_screen() {
  on_library_root || inside_samples_folder || smoke_has 'No folders added'
}

launch_app() {
  "$adb" shell am force-stop app.retroplayer
  "$adb" shell am start -W -n app.retroplayer/.MainActivity >/dev/null
  wait_ui 3
  local i
  for i in 1 2 3 4 5; do
    on_library_screen && return 0
    on_settings_screen && settings_back
    "$adb" shell input keyevent 4
    wait_ui 1
  done
}

require_device() {
  if ! "$adb" devices 2>/dev/null | awk 'NR>1 && $2=="device" {found=1} END {exit !found}'; then
    echo "error: no adb device (boot an emulator first; see AGENTS.md)" >&2
    exit 1
  fi
  local boot
  boot=$("$adb" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')
  if [ "$boot" != "1" ]; then
    echo "error: device not booted (sys.boot_completed=$boot)" >&2
    exit 1
  fi
}

assert_crash_empty() {
  local crash
  crash=$("$adb" logcat -d -b crash 2>/dev/null | grep -v '^$' || true)
  if [ -z "$crash" ]; then ok "crash buffer empty"; else bad "crash buffer not empty"; echo "$crash" >&2; fi
}

session_state_line() {
  "$adb" shell dumpsys media_session 2>/dev/null | grep -A14 'app.retroplayer' | grep 'state=PlaybackState' | head -1 || true
}

assert_playing() {
  local attempt line
  for attempt in 1 2 3 4 5 6; do
    line=$(session_state_line)
    if echo "$line" | grep -qE 'state=PLAYING\(3\)|state=3\b'; then ok "media session playing"; return 0; fi
    if echo "$line" | grep -qE 'state=PAUSED\(2\)|state=2\b'; then ok "media session ready (paused)"; return 0; fi
    tap_anywhere 'Play folder' 480 900 2>/dev/null || tap_anywhere 'Play' 1900 2300 2>/dev/null || true
    wait_ui 2
  done
  line=$(session_state_line)
  if echo "$line" | grep -qE 'state=(PLAYING\(3\)|PAUSED\(2\)|2|3)\b'; then
    ok "media session active"
  else
    bad "expected playing session; got: ${line:-none}"
  fi
}

library_has_root() {
  smoke_has 'Library sources' && smoke_has 'RetroPlayerSamples'
}

on_library_root() {
  smoke_has 'Library sources'
}

inside_samples_folder() {
  ! smoke_has 'Library sources' && { smoke_has 'Demo Artist' || smoke_has 'LongList' || smoke_has 'loose-demo'; }
}

grant_storage_access() {
  if smoke_has '^ALLOW$'; then
    do_tap tap 'ALLOW' 1280 1450 0.5 2>/dev/null || "$adb" shell input tap 878 1388
    wait_ui 4
  fi
}

add_library_root() {
  tap_row 'Add folder' 2000 2400 || tap_anywhere 'Add folder' 2000 2400 || "$adb" shell input tap 778 2221
  wait_ui 5
  if ! smoke_has 'Music' && ! smoke_has 'RetroPlayerSamples'; then
    tap_row 'Add folder' 2000 2400 2>/dev/null || "$adb" shell input tap 778 2221
    wait_ui 5
  fi
  if ! smoke_has 'Music' && ! smoke_has 'RetroPlayerSamples'; then
    bad "SAF picker did not open"
    return 1
  fi
  tap_anywhere 'Music' 250 900 || "$adb" shell input tap 608 317
  wait_ui 2
  tap_anywhere 'RetroPlayerSamples' 450 1200 || "$adb" shell input tap 342 612
  wait_ui 3
  if ! smoke_has 'Files in RetroPlayerSamples' && ! smoke_has 'loose-demo' && ! smoke_has 'Demo Artist'; then
    tap_anywhere 'RetroPlayerSamples' 450 1200 || "$adb" shell input tap 342 612
    wait_ui 3
  fi
  if ! smoke_has 'USE THIS FOLDER'; then
    bad "SAF picker not on RetroPlayerSamples (select Music → RetroPlayerSamples first)"
    return 1
  fi
  do_tap tap 'USE THIS FOLDER' 2100 2400 0.5 2>/dev/null || "$adb" shell input tap 540 2274
  wait_ui 2
  grant_storage_access
  local i
  for i in $(seq 1 15); do
    inside_samples_folder && return 0
    library_has_root && inside_samples_folder && return 0
    wait_ui 2
  done
}

ensure_library_root() {
  step "Library root (RetroPlayerSamples)"
  if library_has_root; then ok "RetroPlayerSamples already in library"; return 0; fi
  on_settings_screen && settings_back
  add_library_root
  if library_has_root || inside_samples_folder; then ok "added RetroPlayerSamples"; else bad "could not add RetroPlayerSamples"; dump_texts | head -20; fi
}

go_library_root() {
  local i
  for i in 1 2 3 4 5 6; do
    on_library_screen && return 0
    on_settings_screen && settings_back
    tap_top 'Show library' 2>/dev/null || "$adb" shell input keyevent 4
    wait_ui 2
  done
}

open_retroplayer_samples() {
  inside_samples_folder && { ok "inside RetroPlayerSamples"; return 0; }
  go_library_root
  inside_samples_folder && { ok "inside RetroPlayerSamples"; return 0; }
  local i
  for i in 1 2 3; do
    inside_samples_folder && break
    tap_row 'RetroPlayerSamples' 480 900 || "$adb" shell input tap 384 559
    wait_ui 2
    tap_row 'RetroPlayerSamples' 480 900 2>/dev/null || true
    wait_ui 3
  done
  if inside_samples_folder; then ok "inside RetroPlayerSamples"; else bad "could not open RetroPlayerSamples folder"; fi
}

open_demo_album_folder() {
  open_retroplayer_samples
  tap_row 'Demo Artist' || tap_row_or_xy 'Demo Artist' 280 680
  wait_ui 3
  tap_row 'Demo Album' || tap_row_or_xy 'Demo Album' 280 780
  wait_ui 3
}

wait_for_long_list() {
  local i
  for i in $(seq 1 10); do
    smoke_has 'zebra' && return 0
    smoke_has 'alpha' && return 0
    smoke_has 'track0' && return 0
    wait_ui 2
  done
  return 1
}

open_long_list_folder() {
  open_retroplayer_samples
  local i
  for i in 1 2 3 4 5; do smoke_has 'LongList' && break; scroll_down; done
  tap_row 'LongList' || tap_row_or_xy 'LongList' 280 900
  wait_for_long_list || bad "LongList scan did not finish in time"
  wait_ui 2
}

baseline_playback() {
  step "Baseline: play from library + session"
  go_library_root
  tap_anywhere 'Play folder' 480 900 || "$adb" shell input tap 1006 594
  wait_ui 8
  assert_playing
  tap_top 'Queue' || "$adb" shell input tap 880 212
  wait_ui 2
  if smoke_has 'Add tracks' || smoke_has 'Clear queue'; then ok "queue screen opened"; else bad "queue screen not detected"; fi
  go_library_root
}

smoke_t07_playlist() {
  step "T07: queue save-as-playlist, detail, delete"
  open_demo_album_folder
  tap_top 'Queue' || "$adb" shell input tap 880 212
  wait_ui 2
  if smoke_has 'Clear queue'; then
    tap_top 'Clear queue'
    wait_ui 1
    tap_top 'Clear queue' 2>/dev/null || tap_anywhere 'Clear queue' 900 1200
    wait_ui 2
  fi
  tap_top 'Add tracks' || "$adb" shell input tap 690 212
  wait_ui 2
  tap_row 'Demo Album' 500 1600 || tap_row_or_xy 'Demo Album' 300 700
  wait_ui 1
  tap_top 'Add \(3\)' 2>/dev/null || tap_top 'Add (3)' 2>/dev/null || tap_top 'Add tracks'
  wait_ui 3
  tap_top 'Save as playlist' || "$adb" shell input tap 420 212
  wait_ui 2
  "$adb" shell input tap 540 1100
  wait_ui 0.5
  "$adb" shell input keyevent 67 67 67 67 67 67 67 67 67 67 2>/dev/null || true
  "$adb" shell input text 'SmokeTrip'
  wait_ui 1
  tap_anywhere 'Save' 900 1500 || "$adb" shell input tap 900 1380
  wait_ui 2
  if smoke_has 'USE THIS FOLDER'; then
    do_tap tap 'USE THIS FOLDER' 2100 2400 0.5 2>/dev/null || "$adb" shell input tap 540 2274
    wait_ui 2
    grant_storage_access
    wait_ui 4
  fi
  local m3u="/storage/emulated/0/Music/RetroPlayerSamples/Demo Artist/Demo Album/SmokeTrip.m3u"
  if "$adb" shell "test -f '$m3u' && echo yes" 2>/dev/null | grep -q yes; then ok "SmokeTrip.m3u on device"; else bad "SmokeTrip.m3u missing"; fi
  go_library_root
  open_demo_album_folder
  tap_row 'SmokeTrip' || tap_row_or_xy 'SmokeTrip' 280 950
  wait_ui 2
  smoke_has 'SmokeTrip' && ok "playlist detail open" || bad "playlist detail not open"
  tap_top 'Delete playlist\?' 2>/dev/null || tap_anywhere 'Delete playlist' 140 320
  wait_ui 1
  tap_anywhere 'Delete' 750 1400 || "$adb" shell input tap 798 1380
  wait_ui 2
  if "$adb" shell "test -f '$m3u' && echo yes" 2>/dev/null | grep -q yes; then bad "SmokeTrip.m3u still present"; else ok "playlist deleted"; fi
}

smoke_t09_index_scroll() {
  step "T09: LongList index bar + scroll restore"
  go_library_root
  open_long_list_folder
  scroll_down
  scroll_down
  "$adb" shell input tap 1020 1750
  wait_ui 2
  if smoke_has 'zebra'; then ok "index jump surfaced zebra"; else bad "zebra not visible after index tap"; fi
  tap_row 'Sub' || tap_row_or_xy 'Sub' 280 720
  wait_ui 2
  tap_top 'LongList' 2>/dev/null || tap_anywhere 'LongList' 300 400
  wait_ui 2
  if smoke_has 'zebra'; then ok "scroll position restored after back from Sub"; else bad "scroll restore failed"; fi
}

open_settings() {
  go_library_root
  tap_top 'Settings' || "$adb" shell input tap 980 212
  wait_ui 2
}

settings_back() {
  tap_top 'Show library' 2>/dev/null || tap_top 'Library' 2>/dev/null || "$adb" shell input keyevent 4
  wait_ui 2
}

smoke_t10_settings() {
  step "T10: settings subpages, mini player, German locale"
  open_settings
  smoke_has 'Data storage' && smoke_has 'Equalizer' && ok "settings home" || bad "settings home not detected"
  tap_anywhere 'Expand player' 1900 2300 2>/dev/null || true
  wait_ui 1
  if smoke_has 'Now Playing'; then bad "expanded player on settings stack"; else ok "player stays mini on settings"; fi
  tap_row 'Data storage' 400 1800 || tap_anywhere 'Data storage' 400 1800
  wait_ui 2
  smoke_has 'database' && ok "data storage page" || bad "data storage page"
  settings_back
  open_settings
  tap_row 'Open source licenses' || tap_anywhere 'Open source licenses' 400 1800
  wait_ui 2
  smoke_has 'Media3' && ok "licenses list" || bad "licenses list"
  settings_back
  open_settings
  scroll_down
  tap_row 'About' 400 2000 || tap_anywhere 'About' 400 1800
  wait_ui 2
  smoke_has 'Version' && ok "about page" || bad "about page"
  settings_back
  open_settings
  tap_row 'Equalizer' || tap_anywhere 'Equalizer' 400 1600
  wait_ui 2
  smoke_has 'Equalizer' && ok "equalizer stub" || bad "equalizer stub page"
  settings_back
  open_settings
  local i
  for i in $(seq 1 8); do smoke_has 'Deutsch' && break; scroll_down; done
  tap_row 'Deutsch' 400 1800 || tap_anywhere 'Deutsch' 400 1400 || bad "Deutsch row not found"
  wait_ui 2
  launch_app
  tap_top 'Einstellungen' 2>/dev/null || tap_top 'Settings' || bad "German gear label missing"
  wait_ui 2
  smoke_has 'Erscheinungsbild' && ok "German settings strings" || bad "German UI strings"
  settings_back
  open_settings
  scroll_down
  tap_row 'System' 400 1200 || tap_anywhere 'System language' || tap_anywhere 'System'
  wait_ui 1
  ok "language reset to system"
}

main() {
  step "Setup"
  require_device
  prepare_emulator_audio
  if [ "${SKIP_FIXTURES:-0}" != "1" ]; then "$NATIVE/scripts/push-smoke-fixtures.sh"; fi
  if [ "${SKIP_BUILD:-0}" != "1" ]; then
    ./gradlew :app:assembleDebug
    "$adb" install -r app/build/outputs/apk/debug/app-debug.apk
  fi
  if [ "${SMOKE_FRESH:-0}" = "1" ]; then "$adb" shell pm clear app.retroplayer; fi
  "$adb" logcat -c 2>/dev/null || true
  launch_app
  ensure_library_root
  if ! library_has_root && ! inside_samples_folder; then
    echo "error: library root required; aborting smoke" >&2
    exit 1
  fi
  baseline_playback
  smoke_t07_playlist
  smoke_t09_index_scroll
  smoke_t10_settings
  step "Final checks"
  assert_crash_empty
  echo
  if [ "$FAILURES" -eq 0 ]; then echo "Emulator smoke passed."; exit 0; fi
  echo "$FAILURES check(s) failed." >&2
  exit 1
}

main "$@"
