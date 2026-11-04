#!/usr/bin/env bash
# Tiny adb/uiautomator helper for manual smoke tests on an emulator or device.
#
#   scripts/ui.sh dump               list visible texts and content descriptions
#   scripts/ui.sh tap <regex>        tap the first node whose text or content-desc matches (case-insensitive)
#   scripts/ui.sh tapxy <x> <y>      tap raw coordinates
#   scripts/ui.sh shot <file.png>    save a screenshot
#
# Uses $ANDROID_HOME (default ~/Android/Sdk); set ANDROID_SERIAL to pick a device.
set -euo pipefail

adb="${ANDROID_HOME:-$HOME/Android/Sdk}/platform-tools/adb"

dump_xml() {
  "$adb" shell uiautomator dump /sdcard/ui-dump.xml >/dev/null
  "$adb" exec-out cat /sdcard/ui-dump.xml
}

usage() { sed -n '4,9s/^# \{0,1\}//p' "$0"; exit 2; }

case "${1:-}" in
  dump)
    dump_xml | grep -oE '(text|content-desc)="[^"]+"' | sort -u
    ;;
  tap)
    [ $# -eq 2 ] || usage
    xml=$(mktemp); trap 'rm -f "$xml"' EXIT
    dump_xml >"$xml"
    center=$(python3 - "$2" "$xml" <<'EOF'
import re, sys
pattern, path = sys.argv[1], sys.argv[2]
for node in re.findall(r'<node [^>]*>', open(path).read()):
    attr = lambda k: (re.search(k + r'="([^"]*)"', node) or [None, ''])[1]
    text, desc = attr(' text'), attr('content-desc')
    if any(s and re.search(pattern, s, re.IGNORECASE) for s in (text, desc)):
        x1, y1, x2, y2 = map(int, re.findall(r'\d+', attr('bounds')))
        print((x1 + x2) // 2, (y1 + y2) // 2)
        break
EOF
)
    if [ -z "$center" ]; then echo "not found: $2" >&2; exit 1; fi
    # shellcheck disable=SC2086
    "$adb" shell input tap $center
    echo "tapped '$2' at $center"
    ;;
  tapxy)
    [ $# -eq 3 ] || usage
    "$adb" shell input tap "$2" "$3"
    ;;
  shot)
    [ $# -eq 2 ] || usage
    "$adb" exec-out screencap -p >"$2"
    echo "$2"
    ;;
  *) usage ;;
esac
