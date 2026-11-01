# Cold-start timing baseline

Manual median timings for the **23-track album** scenario (track 12, ~45 s in, process killed before launch). Repository tests in `test/ui/core/cold_start_bootstrap_test.dart` and `test/data/repositories/playback_repository_restore_perf_test.dart` verify **structure**; this doc records **device** medians.

## Scenario (fixed)

- Folder album with **23** local files under one directory
- Saved playback: **track 12**, **position ~45 s**, paused
- Cold start: force-stop app, then launch from icon (release build unless noted)
- **5 runs** per row; drop min/max; record **median**

## Metrics

| ID | Meaning |
|----|---------|
| T0 | App tap → library shell visible |
| T1 | Player chrome shows **correct title** (and expanded restore: art + seek + transport visible from snapshot; see `cold_start_player_chrome_test.dart`) |
| T2 | Tap Play → audio starts (from T0) |

Report **ΔT1 = T1 − T0**, **ΔT2 = T2 − T0** (milliseconds or seconds).

## Results

| Date | Commit | Build | Device | Median ΔT1 | Median ΔT2 | Notes |
|------|--------|-------|--------|------------|------------|-------|
| | `main` / branch tip before Phase 1 | release / debug | | | | Baseline (~4–5 s ΔT1 reported) |
| | After Phase 0 | release | Google Pixel 8 | 1-2 | 3-4 | Harness only; expect same as baseline - basically, from App tap to mini player shows up/play is then imediatelly possible |
| | After Phase 1 | release | Google Pixel 8 | 0-1 | 1-2 | Much better performance, just the reload inside an album after complete scan is a bit annoying |
| | After Phase 2 | release | Google Pixel 8 | 0-1 | 1-2 | Much better performance, just the reload inside an album after complete scan is a bit annoying |
| | After Phase 3 | | | | | |
| | After Phase 4 | | | | | |

## Repository verification (same commits)

Run `flutter test` — cold-start tests must pass. After each phase, proxy assertions in those tests should reflect the planned improvements (see plan *Cold-start load speed*).
