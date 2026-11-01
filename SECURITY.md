# Security

Retro Player is a **local audio player**. It reads folders you choose and does not implement streaming, accounts, or cloud sync.

## Threat model (v1)

- **In scope:** malicious or malformed **local files** (audio, playlists), path handling, and privacy of library data on device.
- **Out of scope for the app:** server-side attacks (release builds do not use the network for app features).

## Reporting

Until the public issue tracker is linked from the README, report sensitive issues privately to the maintainers via your usual contact channel. Once hosted on GitHub, use **Security advisories** or issues on [r-e-t-r-o-p-l-a-y-e-r/retroplayer](https://github.com/r-e-t-r-o-p-l-a-y-e-r/retroplayer).

Please include platform (Android / Linux), version, and steps to reproduce.

## What we do not ship

No analytics, crash reporting, ads, or in-app purchases in v1. See [README — Privacy](README.md#privacy).
