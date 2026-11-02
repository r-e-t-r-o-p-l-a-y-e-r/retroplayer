# Agent guide: native Android Retro Player

Read this file completely before changing anything under `android-native/`.
Then open [PLAN.md](PLAN.md), take the first task whose status is `todo` and
whose dependencies are `done`, and follow its steps in order.

## What this is

A native Kotlin/Compose rewrite of the Flutter Retro Player for Android only
(app id `app.retroplayer`). The Flutter app in the repo root (`lib/`, `test/`)
is the behaviour spec, together with [doc/REQUIREMENTS.md](../doc/REQUIREMENTS.md)
(use cases UC-01 to UC-18). When a task says "as in Flutter", read the named
Flutter file and copy its behaviour, not its structure.

Hard rules (never break these):

- No Google Play services, Firebase, analytics or network libraries. The
  release manifest must not contain `INTERNET`. `./gradlew check` enforces it
  (`verifyReleasePrivacy` in `app/build.gradle.kts`).
- Storage only through the Storage Access Framework (`content://` tree URIs).
  No `READ_MEDIA_*` or `MANAGE_EXTERNAL_STORAGE` permissions.
- Store only non-default settings: writing a value equal to its default removes
  the key or row (see `SettingsStore.put`). Every new setting needs a test
  "set to default leaves no entry".
- No new translations. Translated strings come from the Flutter ARB files.
- No Android Studio. Everything runs through `./gradlew`.
- Do not add a dependency that is not already in `gradle/libs.versions.toml`
  unless the task explicitly names it.

## Modules

| Module | Kind | Contents |
| --- | --- | --- |
| `:domain` | pure Kotlin/JVM | models, sorting, grouping, fallbacks, M3U, resume and transport rules, settings model |
| `:data` | Android library | SAF scanner, metadata reader, Room (`RetroDatabase`, `LibraryStore`), DataStore (`SettingsStore`), `LibraryRepository`, `PlaylistFiles`; shared fakes in `src/testFixtures` |
| `:playback` | Android library | `PlaybackService` (Media3 `MediaLibraryService`), `RetroPlayer`, queue building, progress saving |
| `:app` | application | Compose UI, ViewModels, Hilt modules, `PlayerConnection` (MediaController) |

Source roots: `domain|data|playback/src/main/kotlin/...` but
`app/src/main/java/...` (Kotlin files in a `java` folder; keep it that way).
Package root: `app.retroplayer`.

Where new code goes:

- Pure rules (no Android types) go to `:domain` with a JUnit test. Prefer this:
  it is the fastest and most reliable to test.
- Anything touching `ContentResolver`, Room or DataStore goes to `:data`.
- Anything touching ExoPlayer or the media session goes to `:playback`.
- Screens: `app/.../ui/<feature>/<Feature>Screen.kt` + `<Feature>ViewModel.kt`.

## Commands

Run from `android-native/`.

| Purpose | Command |
| --- | --- |
| one test class | `./gradlew :app:testDebugUnitTest --tests '*AlbumViewModelTest*'` |
| one test method | `./gradlew :app:testDebugUnitTest --tests '*AlbumViewModelTest.tag order*'` |
| domain tests | `./gradlew :domain:test` |
| module tests | `./gradlew :data:testDebugUnitTest` (same for `:playback`, `:app`) |
| everything (tests, lint, privacy) | `./gradlew check` |
| release build check | `./gradlew check assembleRelease` |
| debug APK | `./gradlew :app:assembleDebug` (output `app/build/outputs/apk/debug/app-debug.apk`) |
| ARB to strings | `python3 ../scripts/arb_to_android.py` (`--check` in CI) |

Agent sandbox notes (Cursor):

- Robolectric tests (`:data`, `:playback`, `:app`) fail inside the sandbox with
  `Couldn't create lock file ~/.robolectric-download-lock`. Run Gradle test
  commands with `required_permissions: ["all"]`. That error is never a code bug.
- `git commit` needs `required_permissions: ["git_write"]`.
- The emulator needs `["all"]` (KVM).
- To read failures: `build/test-results/testDebugUnitTest/*.xml` (search for
  `<failure`), or `build/reports/tests/testDebugUnitTest/index.html`.

## TDD loop (mandatory, every behaviour)

1. Write ONE test for the next behaviour from the task's test list. Use the
   exact test name given in PLAN.md.
2. Run only that test. It must fail on an assertion (red). A compile error
   counts as red only for a brand-new class or function; add an empty stub,
   rerun, and see the assertion fail before implementing.
3. Write the smallest production change that makes it pass (green).
4. Run the whole module's tests. All green.
5. Refactor if needed, rerun module tests.
6. Next behaviour. At the end of the task: `./gradlew check` (with `["all"]`),
   then commit (see "Commits").

Never weaken or delete an existing test to get green. If an existing test
breaks, your change is wrong or the test documents a rule you must keep.
If you are stuck on the same failure three times, stop, write what you tried
into the task's "Notes" in PLAN.md, set the task to `blocked`, and move on to
the next independent task.

## Test recipes (copy these, do not invent new harnesses)

ViewModel test: copy the structure of
`app/src/test/java/app/retroplayer/ui/album/AlbumViewModelTest.kt`.

- `@RunWith(RobolectricTestRunner::class)`; the SDK (35) comes from
  `src/test/resources/robolectric.properties` (each Robolectric module has one).
- `@get:Rule val main = MainDispatcherRule()` and `@get:Rule val tmp = TemporaryFolder()`.
- `TestLibrary(tmp, metadata)` gives a real Room DB, DataStore, scanner and
  repository over `FakeDocumentSource`. Call `lib.addRoot()`, use `lib.p("A/B")`
  for paths, `lib.close()` in `@After`.
- `FakePlayback` (in `TestLibrary.kt`) records calls. When `PlaybackControls`
  gains a method, add it to `FakePlayback` in the same commit.
- Wrap the body in `main.runVmTest { ... }` (10 s timeout) instead of `runTest`.
- Collect `StateFlow`s with Turbine (`viewModel.state.test { ... }`) or wait
  with `viewModel.state.first { it is Ready }`.

Compose UI test: copy `app/src/test/java/app/retroplayer/ui/album/AlbumContentTest.kt`.

- Test the stateless `<Feature>Content(state, actions)` composable, not the
  Hilt-wired `<Feature>Screen`.
- `@get:Rule val compose = createComposeRule()`, then
  `compose.setContent { RetroTheme { FeatureContent(...) } }`.
- Find nodes by test tag (`Modifier.testTag("...")`) or by string resource text
  (`context.getString(R.string.x)`), never by hard-coded English.
- Nodes inside buttons, list items and FABs are merged: use
  `onNodeWithText(..., useUnmergedTree = true)` when a lookup fails.
- When a text appears more than once, use `onAllNodesWithText(x).assertCountEquals(n)`.

Playback test: copy `playback/src/test/.../ProgressSaverTest.kt` or `RetroPlayerTest.kt`.

- Build players with `TestExoPlayerBuilder(context).build()` and
  `FakeMediaSourceFactory`.
- After any player call, idle with
  `TestPlayerRunHelper.advance(player).untilPendingCommandsAreFullyHandled()`
  and then `shadowOf(Looper.getMainLooper()).idle()`. Listener callbacks
  (`onEvents`) are asynchronous; asserting without idling gives flaky tests.
- Positions: compare against `player.currentPosition`; the fake timeline does
  not start at 0.

Data test: copy `data/src/test/.../LibraryRepositoryTest.kt`; fakes live in
`data/src/testFixtures/kotlin/app/retroplayer/data/library/FakeDocuments.kt`
and are available to other modules via `testImplementation(testFixtures(project(":data")))`.

## Strings

- `app/src/main/res/values*/strings_arb.xml` are GENERATED from
  `lib/l10n/app_*.arb`. Never edit them by hand. Names are the ARB keys in
  snake_case (`playPlaylist` becomes `play_playlist`). ICU plurals become
  `name_eq0`, `name_eq1`, `name_other`; pick the variant in Kotlin
  (`when (n) { 1 -> R.string.x_eq1; else -> R.string.x_other }`).
- Native-only strings go to `app/src/main/res/values/strings.xml` (English
  only, file has `tools:ignore="MissingTranslation"`). Before adding one,
  search `strings_arb.xml` for an existing string that fits.
- Never put English literals in composables, except test tags and
  `contentDescription = null` for decorative icons.

## UI conventions

- Material 3 with `RetroTheme` (`ui/theme/RetroTheme.kt`). Use
  `MaterialTheme.colorScheme` or `LocalRetroPalette.current`; never hard-code colors.
- One ViewModel per screen (`@HiltViewModel`), state as one sealed
  `UiState` exposed as `StateFlow`, actions as plain functions.
- The screen composable collects state and passes it to a stateless
  `Content` composable plus an `Actions` data class of lambdas (see
  `FolderScreen.kt`, `AlbumScreen.kt`).
- Text that may be long: `maxLines` + `TextOverflow.Ellipsis` in rows;
  buttons and chips in `FlowRow` so they wrap instead of clipping.
- Navigation: type-safe `@Serializable` routes in `ui/navigation/Routes.kt`;
  every folder is its own destination (`FolderRoute(path)`), which gives the
  predictive back preview of the real parent folder.
- Durations and speeds: `formatDuration`, `formatSpeed` in `ui/Format.kt`.

## Look and feel (must match the user guide)

Reference screenshots: [doc/images/tutorial/](../doc/images/tutorial/)
(`01-library`, `02-mini-player`, `03-expanded-player`, `04-album-detail`,
`05-playlist`, `06-settings`). Flutter sources of truth:
`lib/ui/core/theme.dart`, `lib/ui/core/retro/*`, `lib/ui/core/widgets/retro_list_tile.dart`.
Every UI task ends with a side-by-side check against the matching screenshot
in light mode AND a dark-mode screenshot (`adb shell cmd uimode night yes`,
back with `night no`). Differences are bugs unless PLAN.md says otherwise.

Tokens (already in `RetroPalette` / `RetroTheme`; never hard-code):

| Token | Use |
| --- | --- |
| `screen` | page background (`Scaffold` container) |
| `screenElevated` | top app bar, mini player, cards, slider thumb |
| `chrome` at 55 % alpha | breadcrumb strip |
| `iconChip` | 40 dp rounded (8 dp) square behind row icons; transport skip buttons |
| `accent` | primary buttons, FAB, current crumb, playing row strip + title, slider active track |
| `accentSecondary` | selected segmented button (theme, EQ preset) |
| `playingHighlight` | background of the playing row |
| `textMuted` | section headers, subtitles, time labels |
| `divider` | dividers, inactive slider track, drag handle |

Typography (`RetroTheme` typography): app bar title = `titleMedium` w600,
centered; section header = `titleSmall` 12 sp w600 letter-spacing 0.8
`textMuted`; row title w500 (w600 + accent when playing); row subtitle 13 sp
`textMuted`; track title in the player 20 sp w600; times 12 sp (11 sp
compact) in the default font with tabular figures (`fontFeatureSettings =
"tnum"`; Flutter's `monospace` falls back to Roboto on Android). Durations
are `mm:ss` / `hh:mm:ss` (`formatDuration`).

Shared components (`ui/components/`), use them instead of raw Material ones:

- `RetroTopBar(title, navigationIcon, actions)`: centered title on
  `screenElevated`, no elevation/tint. Action order, left to right: queue
  (T06), player toggle (`PlayerToggleAction`, chevron up/down), settings
  gear (T10).
- `BreadcrumbStrip(crumbs, onCrumb)`: below the top bar on library pages
  (also at the root, showing "Library") and in the expanded player; the
  current crumb is accent w600, parents `onSurfaceVariant`, chevrons muted.
- `SectionHeader(text)`.
- `RetroListRow(title, subtitle, leading, trailing, playing, onClick, onLongClick)`:
  min height 56 dp, padding 16/8, playing = `playingHighlight` background
  plus a 3 dp accent strip at the start.
- `IconChip(icon)`: leading icon for folders, roots, playlists, tracks
  without art.
- `TransportButton(icon, size, primary)`: circles; primary = accent filled
  with white icon (dark mode: `textPrimary`), others `iconChip`. Sizes:
  expanded 64/40 dp, mini 36/28 dp.
- `PlaybackProgress(positionMs, durationMs, onSeek, compact)`: 3 dp track,
  7 dp white thumb, elapsed left and total right under the bar.
- FAB: extended, accent, 24 dp corner radius, folder icon.
- Album art: rounded 4 dp frame with placeholder gradient and music-note icon.

Screen layouts (match the screenshots):

- Library (01): top bar "Library"; breadcrumb strip; section "Library
  sources"; root rows = icon chip, name, location subtitle (`/Music`),
  trailing play button (plays the root folder). Remove a root by swiping
  the row end-to-start, with confirmation. No trash icon. Roots and
  favorites reorder by long-press drag.
- Folder pages: same top bar ("Library"), breadcrumb strip with the path;
  sections Folders, Playlists, Audio; folder rows have a trailing play
  button; swipe start-to-end toggles favorite.
- Gestures everywhere (PLAN T05b): long-press = drag to reorder, only
  where a list has a user order; never a context menu. Swipe from the end
  edge = add to queue (roots: remove). Swipe from the start edge = favorite
  toggle (queue/playlist editor: remove). Use `SwipeActions` and the
  `DragOrder` pattern. ▶ never changes the stored queue: the queue is an
  unsaved playlist, not "what plays now".
- Mini player (02): drag handle, art 40 dp, title w600 + artist, progress
  bar with times, compact transport row centered; `screenElevated`
  background with a top divider.
- Expanded player (03): top bar "Now Playing" (`now_playing`) with back
  arrow (collapses) and the player toggle; breadcrumb strip of the playing
  item; drag handle; art 248 dp max with round ±15 buttons on both sides
  (T03); title, artist, progress bar, transport, speed row (T03).
- Album (04): top bar "Album" with back arrow; header row with art and bold
  title; sort chips (native addition); numbered track rows with subtitle.
- Playlist (05): top bar "Playlist" with back arrow and "Read-only" label
  when not editable; title header; rows with icon chips.
- Settings (06): segmented buttons in `accentSecondary` for theme and EQ
  presets, EQ band sliders in accent with "60 / 230 / 910 / 3.6k / 14k" and
  "0 dB" labels, rows with chevrons, About block at the end.

## Code style

- Match the surrounding code: naming, KDoc density, idiom.
- Comments only for constraints the code cannot show. No comments that
  narrate the next line or explain the change to a reviewer.
- Media3 APIs marked unstable: annotate the class `@UnstableApi` (or
  `@OptIn(UnstableApi::class)` on the function). Lint fails otherwise.
- Use `String.toUri()` (core-ktx), not `Uri.parse` (lint `UseKtx`).
- Hilt: a `StateFlow<List<X>>` constructor parameter needs
  `@JvmSuppressWildcards`, otherwise Dagger reports a MissingBinding.
- Do not create DataStore or coroutine scopes inside `runTest`'s background
  scope in tests; `TestLibrary` owns its scope for this reason.

## Commits

Branch `feat/native-android`. One commit per finished task (or per green
step for large tasks), message: first line `<area>: <what>` under 72 chars,
body lists the tests added. Always run `./gradlew check` before committing.
Update the task status in PLAN.md in the same commit.

## Manual smoke test on the emulator

Use this after each UI task (the plan says when).

```bash
# boot (headless; only -gpu host works on this machine)
$ANDROID_HOME/emulator/emulator -avd routePlannerApi34 -no-window -no-audio \
  -no-boot-anim -no-snapshot-save -gpu host &    # start detached with setsid nohup
adb shell getprop sys.boot_completed             # wait until it prints 1
./gradlew :app:assembleDebug && adb install -r app/build/outputs/apk/debug/app-debug.apk
adb shell am start -W -n app.retroplayer/.MainActivity
scripts/ui.sh shot /tmp/s.png                    # then read the PNG
scripts/ui.sh tap "use this folder"              # tap by text (system dialogs)
scripts/ui.sh tapxy 540 1200                     # tap by device pixels
adb logcat -d -b crash                           # must be empty
adb shell dumpsys media_session | grep -A6 app.retroplayer
```

- Screenshots you read are downscaled: device pixels = image pixels x 1080 /
  image width (about x2.34 for a 461 px wide image).
- uiautomator does not see most text in our Compose screens, so `tap` works
  for system UI (picker, permission dialogs) and `tapxy` for app screens.
- Test audio: `ffmpeg -f lavfi -i "sine=frequency=440:duration=20" -metadata
  title=... -metadata track=1 ... file.mp3`, then
  `adb push <dir> /sdcard/Music/`.

## Known pitfalls (already hit once; do not repeat)

- Robolectric lock-file error = sandbox, rerun with `["all"]`.
- Emulator with `-gpu swiftshader_indirect` or `-gpu guest` crashes (exit 139).
- Material `ColorScheme` slots that are not set fall back to baseline purple;
  `RetroThemeTest` guards this. When you use a new slot, map it in
  `retroColorScheme`.
- When the queue ENDS, `ProgressSaver.saveNow` must save the queue start, not
  the end position.
- `PlaybackRequests`: the UI never builds full queues. It sends one request
  `MediaItem` (`PlaybackRequests.request(itemId, startTrackId)`); the service
  expands it in `onSetMediaItems`. Keep it that way for Android Auto and the widget.
- A test that awaits a flow (`first()`, `await()`) must be bounded, or a red
  test hangs the whole Gradle run (stop it with
  `pkill -f GradleWorkerMain; ./gradlew --stop`). Inside `main.runVmTest`
  the 10 s real-time limit already does this; do NOT add `withTimeout` there
  (it counts virtual time and fires while Room works on a real thread).
  In `runBlocking` tests wrap the wait in `withTimeout(2_000)`.
- Album IDs: `AlbumIds.folder(dir)` / `AlbumIds.tag(dir, album, disc)` in
  `:domain`; folder path keeps its case.
