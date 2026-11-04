# Tutorial screenshots

PNG files referenced from [`doc/USAGE.md`](../../USAGE.md), captured from the
native Android app ([`android-native/`](../../../android-native/README.md)) on
an emulator in light mode, with the system bars cropped off:

| File | Scene |
|------|--------|
| `01-library.png` | Library root with the `RetroPlayerSamples` source |
| `02-mini-player.png` | Library root with the collapsed mini player (Demo Album, paused) |
| `03-expanded-player.png` | Expanded player sheet ("Opening" from Demo Album) |
| `04-album-detail.png` | Demo Album track list |
| `05-playlist.png` | `Demo Mix.m3u`, a playlist the app did not create (read-only) |
| `06-settings.png` | Settings overview |

## Re-capture

1. Push the sample audio
   ([`scripts/push-sample-audio-to-emulator.sh`](../../../scripts/push-sample-audio-to-emulator.sh))
   and a playlist next to it:

   ```bash
   printf '#EXTM3U\nDemo Artist/Demo Album/01-opening.mp3\nDemo Artist/Demo Album/03-finale.mp3\n' > /tmp/demo-mix.m3u
   adb push /tmp/demo-mix.m3u "/sdcard/Music/RetroPlayerSamples/Demo Mix.m3u"
   ```

2. `adb shell cmd uimode night no`, install a fresh build
   (`android-native/scripts/install-test-build.sh`), add `Music/RetroPlayerSamples`
   through **Add folder**.
3. Take each screen with `android-native/scripts/ui.sh shot <file>` and crop the
   status and navigation bars (on a 1080 × 2400 emulator: rows 128 to 2337).
   For 02 and 03, play Demo Album, pause, and press previous so the time shows
   00:00.

The Flutter app has its own capture scripts
([`scripts/capture-tutorial-screenshots-adb.sh`](../../../scripts/capture-tutorial-screenshots-adb.sh),
[`scripts/capture-tutorial-screenshots.sh`](../../../scripts/capture-tutorial-screenshots.sh));
both apps look the same on these screens. Commit PNGs after review for stable
GitHub rendering in USAGE.md.
