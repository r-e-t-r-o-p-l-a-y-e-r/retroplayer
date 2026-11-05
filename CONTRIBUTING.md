# Contributing

Thank you for helping improve Retro Player.

## Setup

JDK 17 and the Android SDK; no Android Studio needed. From the repo root:

```bash
./gradlew check                      # unit, Robolectric and screenshot tests, lint, privacy
scripts/install-test-build.sh        # debug build on a device (app.retroplayer.debug)
```

More commands (single tests, screenshots, device tests): [README.md](README.md#tests).
Conventions, test recipes and known pitfalls: [AGENTS.md](AGENTS.md).

## Expectations

- Test first: every behaviour gets a test (domain rules as plain JUnit tests,
  screens as Robolectric Compose tests).
- Keep the app local-only: no network permission, no Google Play services,
  analytics or network libraries (`verifyReleasePrivacy` enforces this).
- Your folders and files stay read-only; only playlists the app created are
  written (`DiskWriteGuardTest`).
- New UI text goes into `app/src/main/res/values/strings_arb.xml` with a
  translation in every `values-*/strings_arb.xml`, or into `values/strings.xml`
  for English-only Android strings.
- After an intended UI change, record the screenshots again
  (`./gradlew recordRoborazziDebug`) and commit them with the change.

## Pull requests

- Describe user-visible behaviour and how you tested it (`./gradlew check`,
  `scripts/device-smoke.sh` for UI or playback changes, device checks).
- Update docs when behaviour or setup changes.

By contributing, you agree that your contributions are licensed under the same
terms as the project ([GPL-3.0-or-later](LICENSE)).
