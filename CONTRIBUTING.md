# Contributing

Thank you for helping improve Retro Player.

## Setup

Use Flutter **3.47.8** stable (see [`doc/FLUTTER_VERSION.md`](doc/FLUTTER_VERSION.md)).

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart run scripts/stamp_build_info.dart
flutter test
dart analyze
```

`lib/build_info.dart` is generated locally and gitignored — run the stamp script after every fresh clone.

## Expectations

- Prefer tests for domain logic and regressions ([`doc/AUTOMATED_TESTING.md`](doc/AUTOMATED_TESTING.md)).
- Keep the app **local-first**: no network SDKs, no telemetry in release builds ([`test/privacy/`](test/privacy/)).
- Match existing UI and naming conventions (`app.retroplayer`, package `retroplayer`).

## Pull requests

- Describe user-visible behavior and how you tested (`flutter test`, relevant device checks).
- Update docs when behavior or setup changes.

By contributing, you agree that your contributions are licensed under the same terms as the project ([GPL-3.0-or-later](LICENSE)).
