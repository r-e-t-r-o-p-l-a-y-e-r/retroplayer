# Vendored `just_audio_media_kit`

This directory is an **in-tree fork** of [just_audio_media_kit](https://github.com/Pato05/just_audio_media_kit), pinned via `pubspec.yaml` `dependency_overrides.path`.

## Why it lives here

- Linux (and related) playback needs **MPV / media_kit** behavior that differs from pub.dev releases at the time of pinning.
- Local patches can be tested with the full Retro Player suite before upstreaming.

## Upstream

- Repository: https://github.com/Pato05/just_audio_media_kit  
- License: see [LICENSE](LICENSE) in this folder (upstream is public domain / Unlicense-style — verify file before release).

## Maintenance

When updating: diff against upstream tag, run `flutter test` and Linux/Android playback smoke tests, document changes in the commit message.
