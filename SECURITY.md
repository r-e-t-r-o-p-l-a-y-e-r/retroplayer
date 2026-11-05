# Security

Retro Player is a **local audio player** for Android. It reads folders you
choose and has no network access, accounts or cloud sync.

## Threat model

- **In scope:** malicious or malformed **local files** (audio, tags, chapters,
  playlists), path handling in playlists, and privacy of library data on the
  device.
- **Out of scope:** server-side attacks; the app has no `INTERNET` permission.

## Reporting

Use a private **security advisory** on
[r-e-t-r-o-p-l-a-y-e-r/retroplayer](https://github.com/r-e-t-r-o-p-l-a-y-e-r/retroplayer)
(Security → Report a vulnerability). Please include the app version, where you
installed it from, the Android version and steps to reproduce.

## What we do not ship

No analytics, crash reporting, ads or in-app purchases. See
[PRIVACY.md](PRIVACY.md).
