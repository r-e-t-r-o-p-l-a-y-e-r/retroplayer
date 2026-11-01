# Retro Player

Local audio player for music and audiobooks. Cross-platform (Android, iOS, Linux).

**Status:** v1.0.0 — local files only, no analytics in release builds.

## Features

- Play local audio files from user-selected folders
- Directory-aware audiobook grouping (chapters in folders become one book)
- Metadata-based sorting (title, artist, album, date added, track number, duration)
- Read-only view of your folders: the app never moves, renames or rewrites your files (only playlists you create in the app are written)
- Gapless album playback with resume position
- Playback speed control for audiobooks
- Background playback with system media controls (continues when locked or in another app; stops when you fully close the app)

## Supported formats (P0)

| Format | Android | iOS | Linux |
|--------|---------|-----|-------|
| MP3    | Yes     | Yes | Yes   |
| M4A    | Yes     | Yes | Yes   |
| M4B    | Yes     | Yes | Yes   |
| FLAC   | Yes     | Yes | Yes   |
| WAV    | Yes     | Yes | Yes   |

OGG/Opus is supported on Android and Linux only (not iOS).

## Privacy

- **No network access** — the app is designed for local files only (no streaming URLs, MPV `file` protocol only)
- **No ads** — no advertising SDKs
- **No telemetry** — no analytics or crash reporting in v1
- **No in-app monetization** — no in-app purchases (optional support via GitHub Sponsors on the repository page only)

Your audio files stay on your device. Library folders are accessed only when you explicitly add them.

**Enforcement:** Release Android builds omit the `INTERNET` permission; CI tests under `test/privacy/` guard the manifest, dependency denylist, MPV whitelist, and remote playlist rejection. Android **debug/profile** builds still declare `INTERNET` so Flutter hot reload / DevTools can reach the Dart VM Service — that is tooling only, not app telemetry. Linux desktop has no OS-level network jail in this repo (use Flatpak/firejail yourself if you need a process sandbox). Optional on your machine: `flutter config --disable-analytics` (Flutter CLI stats; unrelated to the shipped app).

## Development

Use Flutter **3.47.8** stable ([FVM](https://fvm.app) recommended — see [`doc/FLUTTER_VERSION.md`](doc/FLUTTER_VERSION.md)).

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart run scripts/stamp_build_info.dart   # writes gitignored lib/build_info.dart for Settings → About
flutter test
dart analyze
```

`lib/build_info.dart` is generated and gitignored (build time / git hash change every stamp). Always run the stamp script after a fresh clone before `flutter test` or a device build.

Test-driven development: domain logic is covered by unit tests; UI by widget tests.

See [`doc/README.md`](doc/README.md) for documentation index, [`doc/ARCHITECTURE.md`](doc/ARCHITECTURE.md) for system design, and [`doc/AUTOMATED_TESTING.md`](doc/AUTOMATED_TESTING.md) for test coverage. [`doc/DEVELOPMENT_PLAN.md`](doc/DEVELOPMENT_PLAN.md) holds the full roadmap. To put a build on a physical Android phone, see [`doc/ANDROID_DEVICE_SETUP.md`](doc/ANDROID_DEVICE_SETUP.md).

### Verifying playback persistence (Linux)

**Automated harness (real SQLite file, no UI):**

```bash
# One-shot smoke test (save → close DB → reopen → verify resume)
dart run bin/persistence_harness.dart demo

# Or compile a standalone binary:
dart build cli -o build/persistence_harness
./build/persistence_harness/bundle/bin/persistence_harness demo

# Two separate runs (simulates quitting and relaunching the app):
dart run bin/persistence_harness.dart save --db /tmp/rpc-persist.db
dart run bin/persistence_harness.dart verify --db /tmp/rpc-persist.db
```

**Full app (manual):**

1. Play an album or folder for ~30 seconds, then pause (or wait 10s for auto-save).
2. Quit the app fully (`q` in `flutter run`) — hot restart does not test persistence.
3. Relaunch and play the same item; playback should resume mid-track.
4. Optional: inspect `retroplayer.db` under application support (often `~/.local/share/app.retroplayer/` on Linux):

```bash
sqlite3 ~/.local/share/app.retroplayer/retroplayer.db "SELECT * FROM playback_states;"
```

**Linux taskbar icon:** On GNOME/KDE (Wayland), the shell uses `~/.local/share/applications/app.retroplayer.desktop` and hicolor PNGs. The app installs launcher and icons from the bundle on startup. If the taskbar icon looks wrong after a rebuild, run `./scripts/install-linux-desktop.sh` (prefers a release bundle), then fully quit and relaunch.

## License

**GPL-3.0-or-later** — see [LICENSE](LICENSE). Dependency licenses are listed in Settings → Open source licenses.
