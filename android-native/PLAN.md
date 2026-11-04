# Native Android Retro Player: work plan

Read [AGENTS.md](AGENTS.md) first. It has the commands, test recipes,
conventions and pitfalls this plan relies on.

## How to use this plan

1. Pick the first task (top to bottom) with `Status: todo` whose `Depends`
   tasks are all `done`. Set it to `in progress` and commit nothing yet.
2. Do its "Tests" list in order, one red/green cycle per bullet, using the
   test names given (backticked). You may add tests; do not skip any.
3. When every item under "Done when" holds, set `Status: done`, fill in
   "Notes" (what you changed beyond the spec, anything surprising), run
   `./gradlew check`, commit (see AGENTS.md "Commits").
4. If blocked: `Status: blocked`, write why under "Notes", continue with the
   next independent task.

Owner field: `opus` means Claude Opus intends to do it first because it is
risky (new architecture, tricky APIs). If it is still `todo` when you are
another model, you may take it: the spec below is complete enough. `any`
means any model.

Spec sources: [doc/REQUIREMENTS.md](../doc/REQUIREMENTS.md) (UC numbers),
Flutter code under `lib/ui/features/<feature>/` for look and behaviour.
UI look: the user-guide screenshots in
[doc/images/tutorial/](../doc/images/tutorial/), light and dark mode. The
tokens, shared components and per-screen layouts are in
[AGENTS.md "Look and feel"](AGENTS.md#look-and-feel-must-match-the-user-guide);
build every screen from `ui/components/` and finish every UI task with the
screenshot comparison described there.

## Status overview

| ID | Task | Owner | Status |
| --- | --- | --- | --- |
| done | Tooling, domain, data layer, playback service, ARB converter, library + album screens | opus | done |
| T01 | Transport API on `PlaybackControls` | opus | done |
| T02 | Player sheet shell + back chain | opus | done |
| T02b | Look and feel parity with the user guide (light + dark) | opus | done |
| T03 | Expanded player: jumps, speed | any | done |
| T04 | Locate now playing + playback breadcrumbs | any | done |
| T05 | Queue engine (edit while playing) | opus | done |
| T05b | Library gestures: swipe to queue, long-press reorder | opus | done |
| T06 | Queue screen + add-tracks picker | any | done |
| T07 | Playlist detail, save, delete | any | done |
| T08 | Write-grant upgrade flow | opus | done (engine; UI in T07) |
| T09 | Library leftovers: A-Z, scroll restore, root removal | any | done |
| T10 | Settings screens (theme, language, data, reset, licenses, about) | any | done |
| T11 | Equalizer engine | opus | done |
| T10b | Device smoke tests (instrumented, AGENTS gate) | any | done |
| T12 | Equalizer settings UI | any | done |
| T13 | Keyboard shortcuts | any | dropped |
| T14 | Text-fit guards and pseudo-locales | any | done |
| T14b | Device feedback round 1 (settings like Flutter, player gestures) | any | done |
| T14c | Device feedback round 2 (sheet below the header, save anywhere, queue icons) | any | done |
| T14d | Device feedback round 3 (mini drag, build time, swipe back, add tracks picker) | any | done |
| T15 | M4B chapter reader | opus | done (reader; cache in T16) |
| T16 | Chapters in player, notification and seek bar | any | done |
| T17 | Headset options UI + resume on reconnect | any | done |
| T18 | Android Auto browse tree | opus | done |
| T19 | Glance home-screen widget | any | done |
| T20 | Managed devices + Roborazzi screenshots | any | done |
| T21 | Docs | any | done |
| T22 | Final release check | any | done |

Recommended order for a single agent is the table order. Opus will try to do
T01, T02, T05, T08, T11, T15, T18 first (in that order); when Opus is not
available, simply continue top to bottom.

---

## T01 Transport API on `PlaybackControls`

- Owner: opus. Status: done. Depends: none. UC-10, UC-17.
- Notes: `PlayerConnector` (fun interface, `PlayerConnector.kt`) with
  `MediaControllerConnector` bound in `BindingsModule`. Pending actions are a
  list now (all run on connect). While the current item is still the
  unexpanded request (no owner item id in its extras), `publish()` keeps the
  restored snapshot. `PlaybackRequests.itemExtras` is public for tests.
  Plain ExoPlayer jumps back 5 s (forward 15 s); only `RetroPlayer` in the
  service makes both 15 s, so tests use `seekBackIncrement`.
  Tests: `PlayerConnectionTest` (9).
- Goal: the UI can pause, seek, jump, skip, change speed and stop, and
  `NowPlaying` carries what the player sheet needs.
- Files:
  - `app/.../playback/PlaybackControls.kt` (interface + `NowPlaying`)
  - `app/.../playback/PlayerConnection.kt`
  - `app/src/test/.../TestLibrary.kt` (`FakePlayback`)
  - new `app/src/test/.../playback/PlayerConnectionTest.kt`
- Design:
  - Make `PlayerConnection` testable: move the controller creation behind a
    constructor parameter `connect: suspend () -> Player?` (production passes
    the `MediaController.Builder(...).buildAsync().await()` lambda from a Hilt
    `@Provides`; tests pass a `TestExoPlayerBuilder` player). All logic talks
    to `androidx.media3.common.Player`, never `MediaController` directly.
  - Add to `PlaybackControls`:
    `togglePlayPause()`, `seekTo(positionMs: Long)`, `jumpBack()`,
    `jumpForward()` (call `player.seekBack()` / `seekForward()`; the service's
    `RetroPlayer` turns these into 15 s chapter-aware jumps), `skipToPrevious()`,
    `skipToNext()`, `setSpeed(speed: Float)` (clamped with
    `TransportRules.clampSpeed`), `stop()` (stop + clear media items).
  - Add to `NowPlaying`: `queueIndex: Int = 0`, `queueSize: Int = 0`,
    `hasPrevious: Boolean`, `hasNext: Boolean`.
- Tests (`PlayerConnectionTest`, Robolectric, TestExoPlayer):
  - `toggle pauses a playing player and resumes a paused one`
  - `seekTo moves the position and publishes it`
  - `setSpeed clamps to the allowed range`
  - `skipToNext moves to the next queue entry and publishes index and size`
  - `stop clears the queue and publishes no track`
  - `actions before the player connects run once it is connected`
  - `cold start restores the last item paused with its saved title` (existing
    behaviour; move it under test now)
- Done when: all tests green, `FakePlayback` implements every new method
  (records calls in a list), app still builds, `./gradlew check` green.

## T02 Player sheet shell + back chain

- Owner: opus. Status: done. Depends: T01. UC-12, UC-14.
- Notes (what was actually built; follow this, not the design bullets below):
  - `ui/player/PlayerSheet.kt`: `PlayerHost(state, expanded, onExpandedChange,
    actions) { content }`. The mini player is docked BELOW the content in a
    `Column` (screens and FABs shrink above it; content consumes the
    navigation-bar inset while it is visible). The expanded player is an
    `AnimatedVisibility` overlay; drags on the mini player (up) and the
    expanded player (down) expand/collapse. No `AnchoredDraggable`.
  - `PredictiveBackHandler` in `PlayerHost` is composed after the content.
    `LocalPlayerExpanded` tells `AbsorbBackAtRoot(isRoot)`
    (`ui/navigation/BackChain.kt`) to step aside while expanded. Every new
    "absorb" or screen-level back handler must also check `LocalPlayerExpanded`.
  - `PlayerActions(toggle, previous, next)`: T03 adds fields here.
  - `PlaybackControls.playRequests: SharedFlow<String>`; `RetroApp` expands
    the player on each request (UC-09). `NowPlaying.trackUri` (document of the
    current track, from `PlaybackRequests.trackUriOf`) lets
    `PlayerUiState.artModel` pick `EmbeddedArt` vs folder picture.
  - Cold-start bug fixed: the start destination used to compose first and its
    `onShown()` wiped the saved browse path. Now `AppViewModel.startRoutes`
    (StateFlow, read once) gates `RetroApp`, and
    `rememberRestoredNavController(routes) { graph }` builds the back stack
    before the NavHost composes (`ui/navigation/RestoredNavigation.kt`).
    New destinations go into that builder in `RetroApp.LibraryNavHost`.
  - Tests: `PlayerViewModelTest` (6), `PlayerSheetTest` (6), `BackChainTest` (4),
    `RestoredNavigationTest` (3), `AppViewModelTest` (2), `PlayerConnectionTest` +2,
    `QueueBuilderTest` +1.
- Goal: a mini player at the bottom of library and album screens that
  expands to a full-screen player; back collapses it with the predictive
  back animation; the rest of the back chain stays as is.
- Files:
  - new `app/.../ui/player/PlayerViewModel.kt` (`@HiltViewModel`, exposes
    `NowPlaying` + playback breadcrumbs from `Breadcrumbs.playback`, forwards
    actions to `PlaybackControls`)
  - new `app/.../ui/player/PlayerSheet.kt` with stateless `MiniPlayer`,
    `ExpandedPlayer` and the container `PlayerSheet(state, expanded,
    onExpandedChange, actions)`
  - `app/.../ui/RetroApp.kt` (host the sheet around the `NavHost`)
- Design:
  - Sheet state `expanded: Boolean` lives in `RetroApp` via `rememberSaveable`.
    Container: `Box` with the NavHost and, on top, the sheet anchored to the
    bottom. Use `AnchoredDraggable` (foundation) with anchors Collapsed and
    Expanded for the drag; tapping the mini player expands.
  - Mini player: art (`AlbumArt`), title, subtitle (ellipsized), play/pause
    button. Hidden while `nowPlaying.hasTrack` is false and no title is known.
  - Expanded player (shell only in this task): art, title, subtitle,
    previous / play-pause / next. T03 adds the rest.
  - Back: `PredictiveBackHandler(enabled = expanded)` composed AFTER the
    NavHost (later handlers win). During the gesture scale the expanded
    player by `1 - progress * 0.1` and translate it down; on completion
    collapse; on cancellation restore.
  - Starting playback from a library page (folder or album screen `play`
    actions) expands the sheet (UC-09): expose a `SharedFlow<Unit>`
    `playbackStarted` from `PlaybackControls`, or call `onExpandedChange(true)`
    from the screens' play lambdas in `RetroApp`. Prefer the lambda.
  - Bottom padding: library and album lists get content padding equal to the
    mini player height when it is visible, so the last row is reachable.
- Tests:
  - `PlayerViewModelTest`: `exposes now playing from the controls`,
    `toggle forwards to the controls`, `breadcrumbs follow the playing track`
  - `PlayerSheetTest` (Compose): `mini player shows title and subtitle`,
    `mini player is hidden without a track`, `tapping the mini player expands`,
    `play button toggles without expanding`
  - `BackChainTest` (Compose with `createAndroidComposeRule<ComponentActivity>()`,
    press back via `activity.onBackPressedDispatcher.onBackPressed()`):
    `back collapses the expanded player first`,
    `back from an album returns to its folder`,
    `back at the library root is absorbed`
- Smoke test (AGENTS.md): play a track, mini player visible, expand, back
  collapses, back again leaves the album.
- Done when: tests green, smoke test passes, no crash in `logcat -b crash`.

## T02b Look and feel parity with the user guide

- Owner: opus. Status: done. Depends: T02.
- Notes (as built): components in `ui/components/Components.kt`;
  `PlayerToggleAction` lives in `PlayerSheet.kt` (reads a composition local
  that `PlayerHost` provides). Rows that contain the playing track (roots,
  favorites, folders, albums) get the playing highlight, as Flutter's
  screenshot 02. The album page keeps its breadcrumbs out (screenshot 04);
  `AlbumUiState.crumbs` is unused until someone needs it. Verified on the
  API 34 emulator in light and dark mode.
- Intentional deviations: album sort order is a top-bar menu
  (`Icons.AutoMirrored.Filled.Sort`, native addition); album header has a
  round accent "Play album" button; library row highlight also covers the
  trailing play button. Still missing until their tasks: queue icon (T06),
  settings gear (T10), ±15 and speed row (T03), crumb taps in the player (T04),
  two-pane landscape player (T14).
- Goal: the existing screens (library root, folder, album, mini player,
  expanded player shell) look like `doc/images/tutorial/01..04` in light
  mode and use the same components in dark mode. Spec: AGENTS.md
  "Look and feel".
- Files: `ui/theme/RetroTheme.kt` (typography, component defaults),
  new `ui/components/` (`RetroTopBar`, `BreadcrumbStrip`, `SectionHeader`,
  `RetroListRow`, `IconChip`, `TransportButton`, `PlaybackProgress`,
  `AlbumArt` frame), `ui/library/FolderScreen.kt`, `ui/album/AlbumScreen.kt`,
  `ui/player/PlayerSheet.kt`.
- Behaviour changes that come with the look:
  - Root rows: trash icon replaced by a trailing play button (plays the
    root) and swipe end-to-start to remove (confirmation unchanged, T05b);
    subtitle shows the root location (`/Music`).
  - Folder rows: star replaced by a trailing play button (plays the folder);
    favorite toggle is a swipe start-to-end (T05b).
  - The top-bar play-folder action goes away (row play buttons replace it).
  - Mini player and expanded player get `PlaybackProgress` (seek on
    release) and the transport row (previous / play / next).
  - Player toggle chevron in library top bars while the mini player shows.
- Tests: `RetroComponentsTest` (playing row exposes the accent strip,
  breadcrumb strip marks the current crumb, progress shows elapsed and
  total time, releasing the progress bar seeks once), updated
  `FolderContentTest` / `PlayerSheetTest` for the moved actions,
  `RootLocationTest` for the location label.
- Done when: tests green; emulator screenshots of library root, folder,
  album, mini and expanded player in light and dark mode compared with the
  user guide; remaining deviations listed here.

## T03 Expanded player: jumps, speed

- Owner: any. Status: done. Depends: T02b. UC-10.
- Notes: `PlayerActions` adds `jumpBack`, `jumpForward`, `setSpeed`.
  Expanded player: ±15 jump buttons, double-tap art halves, speed row
  (`steps = 5`, 0.25 increments). `formatSpeed` uses `1.0x` style (plain `x`,
  min one fraction digit). `PlayerViewModel.speedDown` / `speedUp` for
  quarter steps at bounds. Tests: `FormatTest` (updated), `PlayerViewModelTest`
  +3, new `ExpandedPlayerTest` (5). Emulator smoke: forward/back jump
  (position 0→15s→0), speed slider → 2.0× in session + UI, no crashes.
- The seek bar (`PlaybackProgress`) already exists since T02b; only add
  keyboard seeking (←/→ by 5 s on the focused bar) if missing.
- Flutter reference: `lib/ui/features/player/widgets/player_panel.dart`,
  `now_playing_content.dart`, `player_controls.dart`.
- Files: `ui/player/PlayerSheet.kt` (or split into `ExpandedPlayer.kt`),
  `ui/player/PlayerViewModel.kt`.
- Spec:
  - Jump buttons left and right of the art (screenshot 03): 40 dp circles
    in `iconChip` (`TransportButton` style), `Icons.Rounded.Replay` (back)
    and the same icon mirrored with
    `Modifier.scale(scaleX = -1f, scaleY = 1f)` (forward), each with a small
    "15" text overlaid (11 sp w700, `textMuted`); content descriptions
    `R.string.jump_back` / `R.string.jump_forward`.
  - Double tap on the left half of the art jumps back, right half forward
    (`Modifier.pointerInput { detectTapGestures(onDoubleTap = { offset -> ... }) }`).
  - Speed (as Flutter `player_panel.dart` `_buildSlider`): one row with a
    speed icon (`Icons.Outlined.Speed`, `textMuted`), label `R.string.speed`
    (13 sp `textMuted`), a `Slider` 0.5..2.0 (accent active track, visible
    tick marks, white thumb as `PlaybackProgress`) with
    `steps = 5` (Compose counts inner stops; that gives 0.25 increments),
    and the value on the right (`formatSpeed`, fixed width so the row does
    not jump). Screenshot 03 shows `1.0x`: change `formatSpeed` (test first
    in `FormatTest`) to at least one fraction digit and a plain `x`
    (`1.0x`, `1.25x`, `0.5x`), still with the locale decimal separator.
    The jump buttons sit left and right of the art: shrink the art so
    `art + 2 × 40 dp + gaps` fits the width. Keyboard ←/→ on the focused slider changes by 0.25 (the
    Compose `Slider` does this already; just test it).
- Tests:
  - `PlayerViewModelTest`: `jump back and forward forward to the controls`,
    `speed down stops at the minimum`, `speed up stops at the maximum`
  - `ExpandedPlayerTest`: `jump buttons call jump actions`,
    `double tap on the left half jumps back`, `double tap on the right half jumps forward`,
    `speed slider shows the formatted speed`, `speed slider changes in quarter steps`
- Done when: tests green, smoke test (seek, jump, speed visible in
  `dumpsys media_session` as position/speed changes).

## T04 Locate now playing + playback breadcrumbs

- Owner: any. Status: done. Depends: T02. UC-13.
- Notes: `StartupRoutes.locate`, `AppViewModel.locate` / `locatedTrackId` /
  `onUserBrowsing`, `NavController.navigateLocateStack`. Expanded player:
  title + art tap locate (collapses sheet), playback crumbs navigate.
  Album scroll via `scrollToTrackId`. Tests: `StartupRoutesTest` +3,
  `AppViewModelTest` +2, `ExpandedPlayerTest` +3. Emulator smoke: play in
  album, library root, expand, tap title → album with track visible.
- Spec:
  - Tapping the title or art in the expanded player collapses the sheet and
    navigates to where the current track lives: if `nowPlaying.itemId` is an
    album id (`AlbumIds.directoryOf(id) != null`) open `AlbumRoute(itemId)`
    with its folder chain behind it (`StartupRoutes.build`); otherwise
    `showFolder(track folder)` where the track folder is
    `LibraryPath(nowPlaying.trackId).parent`. For a playlist item
    (`PlaybackItem.playlistPathFromId`) open the playlist route (after T07;
    until then the playlist's folder).
  - The track row is highlighted (existing `playingTrackId` highlight) and
    scrolled into view (`LazyListState.animateScrollToItem`).
  - The highlight clears on manual browsing: keep a `locatedTrackId` in
    `AppViewModel`; set on locate, clear on any folder/album navigation not
    caused by locate. The row highlight for "currently playing" stays.
  - Playback breadcrumbs: in the expanded player under the title, a
    `BreadcrumbBar` (existing component) from `Breadcrumbs.playback(...)`;
    tapping a crumb collapses and calls `showFolder(crumb.path)`.
- Tests: `AppViewModelTest`: `locate sets the located track`,
  `manual navigation clears the located track`; `ExpandedPlayerTest`:
  `tapping the title calls locate`, `breadcrumbs of the playing item are shown`;
  `StartupRoutesTest`: `locate in an album builds folder chain plus album`.
- Done when: tests green, smoke: play in album, browse to root, expand,
  tap title, album opens with the track highlighted.

## T05 Queue engine (edit while playing)

- Owner: opus. Status: done. Depends: T01. UC-08.
- As built (differs from the spec below; the code is the reference):
  - `QueueEdits` (domain) `add` / `move` / `remove`; `SettingsStore.updateQueue`
    does read-modify-write in one DataStore transaction.
  - `QueueRepository(settings, scanner)` (data, Hilt singleton): `queue`
    flow of `AudioTrack?`, `add(paths)`, `move(from, to)`, `remove(index)`,
    `clear()`. UI code only talks to this; there is no `queueChanged` on
    `PlaybackControls`.
  - `PlayerConnection` follows the stored queue itself: while the current
    item id is `queue` it removes, reorders and appends media items by
    track id (current track keeps playing), and an emptied queue stops.
    Appends use `PlaybackRequests.addition(trackId, QUEUE_ID)`, which the
    service expands with `SessionQueue.expand(ids, intoItemId)`.
  - To play the queue: `controls.play(PlaybackItem.QUEUE_ID, startTrackId)`.
- Goal: a queue the user edits (add, move, remove, clear) that persists in
  `SettingsStore.queue`, plays as item `PlaybackItem.QUEUE_ID`, and when it
  is what is playing, edits apply to the live player without interrupting.
- Files:
  - new `domain/.../QueueEdits.kt`: pure functions `add(queue, paths)`
    (appends, skips paths already in the queue, keeps order),
    `move(queue, from, to)`, `remove(queue, index)`.
  - new `data/.../library/QueueRepository.kt`: `queue: Flow<List<AudioTrack?>>`
    (resolves paths via `LibraryRepository`/scanner, missing ones as null),
    `add`, `move`, `remove`, `clear`, all writing `SettingsStore.setQueue`.
  - `PlaybackControls`: `queueChanged(edit: QueueEdit)` where `QueueEdit` is
    a sealed type (Added(paths at end), Moved(from, to), Removed(index),
    Cleared). `PlayerConnection` applies it with `addMediaItems`,
    `moveMediaItem`, `removeMediaItem` only if the current item id is the
    queue; `Cleared` while the queue plays calls `stop()`.
  - Service: `onAddMediaItems` already expands ids; added items must carry
    the queue's item id in their extras (`PlaybackRequests.itemExtras`).
- Tests:
  - `QueueEditsTest` (domain): `add appends new paths in order`,
    `add skips paths already queued`, `move reorders`, `remove drops one entry`,
    `out of range edits leave the queue unchanged`
  - `QueueRepositoryTest` (data): `edits persist across a new repository`,
    `missing files resolve to null entries`, `clear removes the stored key`
  - `PlayerConnectionTest`: `queue edits apply to the live player when the queue plays`,
    `queue edits do not touch the player when an album plays`,
    `clearing the playing queue stops playback`
- Done when: tests green; playing a folder or album leaves the stored queue
  untouched (existing `SessionQueueTest` stays green).

## T05b Library gestures: swipe to queue, long-press to reorder

- Owner: opus. Status: done. Depends: T05.
- Gesture rule for every list in the app (user decision, binding):
  - Long-press is only ever drag-to-reorder, wherever a list has a user
    order (library roots, favorites, queue T06, playlist editor T07). No
    context menus anywhere. Where nothing can be reordered, long-press does
    nothing special and must not open the row afterwards.
  - Swipe from the end edge (left in LTR) = add to queue, on every row that
    can be queued: folders, favorites, playlists, albums, tracks, album-view
    tracks. Exception: library roots, where it asks to remove the root.
  - Swipe from the start edge (right in LTR) = favorite toggle on folders
    and favorite links. In the queue and playlist editor (T06/T07) a swipe
    removes the entry instead (with the confirmations those tasks specify).
- Queue semantics (same as Flutter): the queue is an unsaved playlist kept
  in `SettingsStore` (DataStore), never a file. It is not "what plays now":
  ▶ on a folder, album, playlist or track plays that item and leaves the
  queue untouched. Only playing the queue (T06) makes it the live list, and
  only then do queue edits reach the player (T05). ▶ on an album row and
  "Play album" in the album view start the same item and resume its saved
  track and position.
- As built:
  - `FolderViewModel.addToQueue(itemId, onAdded)` resolves the playback item
    with `PlaybackItemResolver` (exactly what ▶ would play, same order),
    appends via `QueueRepository.add` (skips tracks already queued) and
    reports how many were new. `AlbumViewModel.addToQueue(track, onAdded)`
    queues one track. A snackbar says `added_to_queue_eq0|eq1|other`.
    `addedToQueue` is a new ARB plural (with `addToQueue` as the swipe's
    accessibility label), translated in all 46 ARB files and regenerated
    for Flutter too.
  - `ui/components/SwipeActions.kt`: `SwipeActions(fromStart, fromEnd)` with
    `Swipe(icon, label, action)`; own `Modifier.draggable` + offset (not
    `SwipeToDismissBox`, whose dismiss/reset cycle dropped every second
    swipe). Runs the action past 72 dp, then animates back; RTL aware; each
    swipe is also an accessibility custom action.
  - Reorder: `sh.calvin.reorderable` 3.1.0. Roots and favorites are
    separate sections of one `LazyColumn`; `DragOrder` (private in
    `FolderScreen`) keeps the shown order during a drag and writes once on
    drop (`LibraryStore.moveRoot` / `moveFavorite`). It also swallows the
    click that the release of a long press would otherwise fire.
  - Room version 2: `library_roots.position` (auto-migration, default 0,
    order `position, addedAt, id`; new roots go last).
    `RetroDatabaseMigrationTest` covers 1 -> 2 (`room-testing`, schemas as
    test assets).
  - Accessibility: every reorderable row also offers "Move up" / "Move
    down" custom actions (`move_up`/`move_down`, new ARB keys
    `moveUp`/`moveDown`, translated in all 46 files); first row has no
    "Move up", last row no "Move down".
  - Screen edges belong to the OS: swipes starting at the left/right edge
    are system back, from the bottom edge home/recents (gesture navigation
    delivers them to the system first). Never use
    `systemGestureExclusion` on rows. Back at the library root does
    nothing (`AbsorbBackAtRoot`, UC-14). Checked on the emulator.
- Tests: `RetroDatabaseTest` `roots keep a user order and new roots go
  last`; `RetroDatabaseMigrationTest`; `FolderViewModelTest` `add to queue
  appends what play would play without playing it`, `moving roots and
  favorites saves the new order`; `AlbumViewModelTest` `adding a track to
  the queue adds only that track, once`; `FolderContentTest` drags (root,
  favorite, no cross-section moves), swipes (root remove, favorite both
  ways, every folder-page row, swipe again after snap-back), snackbar
  texts, long press opens nothing, screen-reader move actions;
  `AlbumContentTest` swipe a track.

## T06 Queue screen + add-tracks picker

- Owner: any. Status: done. Depends: T05. UC-08.
- Notes: `QueueRoute`, `AddTracksRoute`, `QueueScreen`/`AddTracksScreen`,
  `QueueNavAction` on library top bars. Reorder via `DragOrder` + reorderable;
  swipe either way removes. Save-as-playlist action omitted until T07.
  Tests: `QueueViewModelTest` (6), `QueueContentTest` (3),
  `AddTracksViewModelTest` (2). Smoke: queue opens from app bar; full
  reorder/restart flow not re-run this session.
- Flutter reference: `lib/ui/features/playlist/` (queue view and picker).
- Reorder: `sh.calvin.reorderable` is already in the catalog (T05b); copy
  the `DragOrder` pattern from `FolderScreen` (one write on drop, swallow
  the click after a long press). Gesture rule: see T05b.
- Files: `ui/queue/QueueRoute` in `Routes.kt`, `QueueViewModel.kt`,
  `QueueScreen.kt`; `ui/queue/AddTracksScreen.kt` + `AddTracksViewModel.kt`.
- Engine (T05): inject `QueueRepository` for reads and edits and
  `PlaybackControls` to play; edits reach the live player automatically.
- Look: no guide screenshot; build it like the playlist page (05) from
  `ui/components`: `RetroTopBar(stringResource(R.string.queue))` with
  `BackButton`, `RetroListRow` with `IconChip(Icons.Outlined.MusicNote)`,
  `playing` on the current track.
- Spec:
  - Open from an app-bar action (icon `Icons.Rounded.QueueMusic`, label
    `R.string.queue`) on every folder screen including the root, placed
    before `PlayerToggleAction()` (screenshot 02).
  - Rows: title, artist, duration; missing entries show `R.string.missing_track`.
    Tap a row: `controls.play(QUEUE_ID, startTrackId = path)`. Long-press drag
    reorders, swipe (`SwipeActions`, either direction) removes.
    Playing row highlighted. Empty: `R.string.queue_empty`.
  - App bar actions: Add tracks (`R.string.add_tracks`), Clear
    (`R.string.clear_queue`, confirm dialog `clear_queue_title`/`clear_queue_body`),
    Save as playlist (`R.string.save_as_playlist`, implemented in T07; until
    then hidden).
  - Add-tracks picker: browse folders like the library (reuse
    `LibraryRepository.folder`), checkboxes on tracks and albums
    (album = all its tracks in effective order), confirm button
    `R.string.add_tracks_confirm`; nothing selected shows
    `add_tracks_nothing_selected`; all already queued shows
    `add_tracks_nothing_added` (use `PlaylistEntries.filterNew`).
- Tests: `QueueViewModelTest`: `shows queued tracks in order`, `tap plays the queue from that track`,
  `remove updates the queue`, `move updates the queue`, `clear asks first`,
  `confirm clear empties the queue`; `QueueContentTest`: `empty queue shows the empty text`,
  `missing entry shows missing track`, `playing row is highlighted`;
  `AddTracksViewModelTest`: `selecting an album adds its tracks in album order`,
  `already queued tracks are not added twice`.
- Done when: tests green; smoke: add tracks, reorder, play from row 2,
  restart app, queue still there and resumes (UC-08 AC).

## T07 Playlist detail, save, delete

- Owner: any. Status: done. Depends: T06. UC-08.
- Notes: `PlaylistRoute`, detail editor (add/reorder/remove/select/delete), queue save-as-playlist with write-grant retry; locate opens playlist route; tests `PlaylistViewModelTest`, `QueueViewModelTest` save cases. Device test: `DeviceSmokeTest.theQueueSavesAsAPlaylistThatCanBeDeleted` (save with write grant, open, delete); extended add/remove/select/reorder still manual. See AGENTS.md.
- Existing code: `PlaylistFiles.read/save/overwrite/delete`, `M3u`,
  `LibraryStore.registerAppPlaylist/isAppPlaylist`.
- Files: `PlaylistRoute(path)` in `Routes.kt`, `ui/playlist/PlaylistViewModel.kt`,
  `PlaylistScreen.kt`; folder screen playlist rows open it.
- Spec:
  - Detail lists entries (missing ones as `missing_track`), tap plays the
    playlist from that entry (`PlaybackItem.playlistId(path)`). Empty:
    `playlist_empty`; play with no playable entries: snackbar
    `playlist_nothing_to_play`.
  - Editable only when `PlaylistContent.editable` (app-created and root has
    write access): add tracks (reuse T06 picker), reorder (long-press drag), remove (swipe) with
    confirmation (`remove_playlist_track_title_eq1/other`, body variants),
    multi-select (`playlist_select`, `playlist_select_all`,
    `playlist_deselect_all`, `playlist_selected_count_*`), delete playlist
    (`delete_playlist_title/body`). Read-only playlists show
    `playlist_read_only` and no edit actions.
  - Save queue as playlist (queue screen action): only when a real folder is
    the current browse path (not the virtual root); name dialog
    (`new_playlist_name`, `save`); if the root has no write grant, start T08's
    flow; if still not writable, show `folder_access_denied` (native string).
- Tests: `PlaylistViewModelTest`: `read only playlist offers no edits`,
  `app playlist can remove an entry`, `delete removes the file and the registry entry`,
  `tap plays the playlist from that entry`; `QueueViewModelTest`:
  `save is refused at the library root`, `save writes an app playlist in the open folder`.
- Done when: tests green; smoke with a write-granted root.

## T08 Write-grant upgrade flow

- Owner: opus. Status: done (engine). Depends: none. UC-02, UC-08.
- As built: `writeAccessIntent(treeUri)` (in `SafRootAccess.kt`: picker
  opens at the root, read+write+persistable flags) and
  `RootAccess.grantWrite(rootId, pickedTreeUri)`: same tree (authority +
  tree document id) takes the persistable read|write grant and sets
  `LibraryStore.setCanWrite`; any other folder returns false and nothing is
  kept. `SafRootAccessTest` covers all three. No explanation dialog (it
  would need new strings); on false show `folder_access_denied`.
  Wiring for T07: when saving needs write access, launch
  `rememberLauncherForActivityResult(StartActivityForResult())` with
  `writeAccessIntent(root.treeUri)`, pass `result.data?.data` to
  `grantWrite`, then retry the save.
- Goal: a read-only root can be upgraded to read+write when the user wants
  to save a playlist; declining keeps everything working read-only.
- Files: `app/.../library/RootAccess.kt` (+ `requestWrite`),
  `SafRootAccess.kt`, `LibraryStore` (`setCanWrite(rootId)`; exists as
  `RootDao.update`), a small explanation dialog (native strings
  `write_access_title`, `write_access_body`, `write_access_grant`).
- Spec: launch `ACTION_OPEN_DOCUMENT_TREE` with `EXTRA_INITIAL_URI` = the
  root's tree URI and flags read+write+persistable. Accept only if the
  returned tree URI equals the root's; then `takePersistableUriPermission`
  with read|write and store `canWrite = true`. Any other folder: release that
  new grant, show `folder_access_denied`.
- Tests: `SafRootAccessTest` (Robolectric `ShadowContentResolver`):
  `write grant for the same tree marks the root writable`,
  `a different tree is rejected and its grant released`;
  `FolderViewModelTest`/`QueueViewModelTest`: `save without write access asks for it`.
- Done when: tests green; smoke on emulator: save playlist on a fresh root
  shows the explanation, picker, then saves.

## T09 Library leftovers

- Owner: any. Status: done. Depends: T05b. UC-02, UC-04.
- Notes: `LibraryIndex` + `AlphabetIndexBar` on folder/root lists (>30 rows); list scroll in `FolderViewModel` `SavedStateHandle` via `FolderListScroll`; removing the playing root calls `playback.stop()`; `RetroApp` folder navigation: `NavController.openFolder` (no `launchSingleTop`, which pushed nothing for a different path; review fix with `FolderNavigationTest`). Tests: `LibraryIndexTest`, `FolderContentTest` (index bar), `FolderViewModelTest` (scroll + stop), `BackChainTest` (scroll restore). Device test: `DeviceSmokeTest.theIndexBarJumpsAndTheScrollSurvivesRecreation` (`LongList/` of 31 one-track folders).
- Spec (each bullet one red/green cycle, tests in `FolderViewModelTest` /
  `FolderContentTest`):
  - Swipes and long-press reordering of roots and favorites: done in T05b.
  - A-Z index bar on lists with more than 30 rows: vertical strip of first
    letters at the right edge; tap or drag jumps to the first row with that
    letter: `index bar appears for long lists`, `tapping a letter scrolls to it`.
  - Scroll position per folder survives going into a subfolder and back
    (each `FolderRoute` keeps its `rememberLazyListState()` via the back
    stack's saved state): `BackChainTest` `going up restores the parent scroll position`.
  - Removing a root that contains what is playing stops playback
    (`controls.stop()`): `removing the playing root stops playback`.
- Done when: tests green; smoke: index bar jumps, scroll position survives going up.

## T10 Settings screens

- Owner: any. Status: done. Depends: T02. UC-16, UC-12 (fixed mini dock in settings).
- Notes: `SettingsRoute` + data/licenses/about/equalizer stub screens; theme via `SettingsStore`, language via `AppCompatDelegate` + `locales_config.xml`; reset stops playback and optionally clears roots/grants; `BuildConfig` git/build date; gear on library top bar; `PlayerHost(allowExpansion=false)` while settings visible. Tests: `SettingsViewModelTest`, `SettingsContentTest`, `LicensesTest`, `BackChainTest` (mini-only player). Review fixes: locales were never read from `locales_config.xml` (missing Android namespace, `LocaleTagsTest`); "clear everything" released no grants (roots were deleted first; reset only forgets folders: database rows and the app's access grant, never files on disk); the system-language row is drawn by the screen so it follows the language; selectable radio rows; build date = commit date. Device tests: `settingsPagesOpenAndThePlayerStaysMini`, `choosingGermanTranslatesTheAppUntilSystemIsChosenAgain`.
- Flutter reference: `lib/ui/features/settings/`.
- Files: `SettingsRoute`, `SettingsDataRoute`, `SettingsLicensesRoute`,
  `SettingsAboutRoute` in `Routes.kt`; `ui/settings/SettingsViewModel.kt`,
  `SettingsScreen.kt` and one file per subpage. Entry: app-bar overflow or
  gear icon on folder screens (`R.string.settings`).
- Spec:
  - Appearance: theme radio group (`theme_system`, `theme_light`, `theme_dark`)
    → `SettingsStore.setTheme`; applies immediately (AppViewModel already
    collects theme).
  - Language: list "System" (`language_system`) plus every locale in
    `res/xml/locales_config.xml`, each shown in its own language
    (`Locale.forLanguageTag(tag).getDisplayName(locale)`). Apply with
    `AppCompatDelegate.setApplicationLocales(LocaleListCompat.forLanguageTags(tag))`
    (empty list = system). This needs `MainActivity` to extend
    `AppCompatActivity` (theme parent `Theme.AppCompat.DayNight.NoActionBar`)
    and, for API < 33, in the manifest the service
    `androidx.appcompat.app.AppLocalesMetadataHolderService` with meta-data
    `autoStoreLocales=true`. Do not store the language in DataStore (the
    system/AppCompat owns it); remove `AppSettings.languageTag` if unused.
  - Equalizer entry row → T12 page (show the row now, page in T12).
  - Data storage page: `data_storage_intro`, then the app data, library,
    playlists and Android sections (`data_storage_*_title/body`, Android
    variants only).
  - Reset (`reset_database`): dialog `reset_database_title/body` with
    `reset_database_keep_folders` and `reset_database_clear_everything`;
    both call `controls.stop()`, `SettingsStore.reset()`,
    `LibraryStore.reset(keepRoots)`; clear everything also releases the
    persisted URI grants (`RootAccess.remove` for each root) and resets the
    language to system.
  - Licenses (`open_source_licenses`): static list of the libraries in
    `libs.versions.toml` with license name; a unit test reads the catalog
    file and fails if a library group is missing from the list.
  - About: app name, `about_version` (versionName), build date, git branch and
    commit via `BuildConfig` fields set in `app/build.gradle.kts` from
    `providers.exec { commandLine("git", ...) }` (fallback "unknown").
  - While Settings is open the player shows only the mini player, not
    expandable (UC-12 alternative).
- Tests: `SettingsViewModelTest`: `choosing the default theme leaves no stored key`,
  `reset keeping folders keeps roots`, `clear everything removes roots and grants`,
  `reset stops playback`; `LicensesTest`: `every catalog library is listed`;
  `SettingsContentTest`: `theme choice is checked`, `reset asks first`;
  `BackChainTest`: `back closes settings before the player`.
- Done when: tests green; smoke: switch to German, UI is German after
  restart; switch back to system.

## T10b Device smoke tests

- Owner: any. Status: done. Depends: T07, T09, T10 (behaviour under test).
- As built: `app/src/androidTest/.../smoke/DeviceSmokeTest.kt` (5 tests, about
  one minute) run by `scripts/device-smoke.sh`; `FolderPicker` drives the system
  picker with UiAutomator; the orchestrator clears app data before each test.
  Replaced the first version (`emulator-smoke.sh`, uiautomator dumps and
  coordinate taps, 15+ minutes and flaky). The flows found three app bugs:
  folder navigation pushed nothing (`launchSingleTop`), no languages listed,
  and the Add folder button had no accessible label.
- Done when: `scripts/device-smoke.sh` passes on the API 34 AVD; `./gradlew
  check` green; AGENTS.md commit gate documented.

## T11 Equalizer engine

- Owner: opus. Status: done. Depends: none. UC-16.
- As built (all in `playback/.../EqualizerBinder.kt`): `EqualizerEngine`,
  `EqualizerInfo(centersHz, rangeDb)`, `EqualizerBinder(create, report)`
  (one engine per audio session, applies `gainsForDevice` clamped to the
  device range, `setEnabled(false)` when off, releases on new session and
  in `onDestroy`), `AudioFxEqualizer` (millibels, `createOrNull`), and the
  Hilt singleton `EqualizerAvailability.info: StateFlow<EqualizerInfo?>`
  for T12. `PlaybackService` feeds it from `onAudioSessionIdChanged` and the
  settings flow. Emulator: `dumpsys media.audio_flinger` lists the
  Equalizer effect on the session.
- Goal: `EqualizerSettings` drive `android.media.audiofx.Equalizer` on the
  player's audio session, with graceful "unavailable".
- Files (`:playback`): `EqualizerEngine.kt` interface
  (`centersHz: List<Int>`, `rangeDb: ClosedFloatingPointRange<Float>`,
  `apply(gainsDb: List<Float>)`, `setEnabled(Boolean)`, `release()`);
  `AudioFxEqualizer.kt` (real, millibels); `EqualizerBinder.kt` (a
  `Player.Listener`/`AnalyticsListener` that creates the engine for each
  audio session id, applies `settings.gainsForDevice(...)`, releases on
  change and in `onDestroy`); `EqualizerAvailability` singleton
  `StateFlow<EqualizerInfo?>` (null = unavailable) for the UI. Wire it in
  `PlaybackService`. Create the engine with a factory lambda so tests use a fake.
- Tests (`EqualizerBinderTest`): `applies device gains when a session starts`,
  `reapplies when settings change`, `disabled settings turn the effect off`,
  `releases the old effect on a new session`, `creation failure reports unavailable`.
- Done when: tests green; smoke: enable bass boost, `adb shell dumpsys media.audio_flinger`
  shows an equalizer effect on the session.

## T12 Equalizer settings UI

- Owner: any. Status: done. Depends: T10, T11.
- Flutter reference: `lib/ui/features/settings/` equalizer widgets.
- Spec: page title `equalizer`; enable switch; presets as a wrapping
  `FlowRow` of `FilterChip`s (`eq_manually`, `eq_bass`, `eq_treble`,
  `eq_voice`); `bands` heading with 5 vertical sliders (rotate a `Slider`
  or custom) -15..15 dB, label below each = frequency (60 Hz, 230 Hz,
  910 Hz, 3.6 kHz, 14 kHz; locale-neutral), content description includes
  the value; moving a slider switches the preset to manual; `reset` button
  sets flat manual. Unavailable: show `equalizer_unavailable` and disable.
- Tests: `EqualizerViewModelTest`: `moving a band switches to manual`,
  `choosing a preset stores it`, `reset to flat leaves no stored keys`;
  `EqualizerContentTest`: `unavailable disables the controls`,
  `preset chips wrap instead of clipping` (with T14 helper).
- Done when: tests green, smoke.
- Done: `EqualizerScreen.kt` (rotated `Slider`s in forced LTR, whole-dB
  steps), `EqualizerViewModel` (100 ms debounced band saves); device smoke
  checks the page shows the 60 Hz band.

## T13 Keyboard shortcuts

- Status: dropped. The Flutter shortcut table is desktop-only (Linux,
  Windows, macOS); the Flutter Android app has none. Android keeps what the
  platform gives: media keys via Media3 and Compose focus navigation.

## T14 Text-fit guards and pseudo-locales

- Owner: any. Status: done. Depends: T03, T10, T12.
- Spec:
  - Debug build: `isPseudoLocalesEnabled = true` (en-XA, ar-XB).
  - Test helper `assertNoClippedText(tag)` in `app/src/test/.../TextFit.kt`:
    for every node under `tag` with `SemanticsActions.GetTextLayoutResult`,
    invoke it and assert `!result.hasVisualOverflow`. Use it on controls that
    must never cut text (buttons, chips, dialog actions, speed, EQ).
  - Single-line labels that cannot wrap: `BasicText(autoSize =
    TextAutoSize.StepBased(minFontSize = 11.sp))`.
  - Run each screen's Content test additionally with
    `@Config(qualifiers = "de")`, `"fi"`, `"el"`, `"ru"`, `"en-rXA"`,
    `"ar-rXB"`, and font scale 2 (`qualifiers = "+w320dp"` and
    `RuntimeEnvironment.setFontScale(2f)`), as parameterized tests.
  - Landscape / short screens: when the expanded player is wider than tall
    (`BoxWithConstraints` in `ExpandedPlayer`), show art on the start half
    and titles, progress, transport and speed on the end half. Test with
    `@Config(qualifiers = "w800dp-h360dp")`: `landscape player shows art and
    controls side by side` (transport displayed, art not clipped).
- Tests: `TextFitTest` per screen: `<screen> controls fit in <locale> at font scale <n>`.
- Done when: all pass (fix layouts, never shorten translations).
- Done: `app/src/test/.../ui/TextFit.kt` (`assertNoClippedText`, `DisplayRule`;
  needs `@GraphicsMode(NATIVE)`, and checks lines itself because the
  semantics layout reports `hasVisualOverflow` for every text).
  `Modifier.mayEllipsize()` marks user data (list rows, player titles).
  `TextFitTest` runs 22 screen states x 7 locales at font scale 2 (154 cases).
  Fixes: top bar titles wrap to 2 lines and shrink to 11 sp; text actions
  moved to a wrapping row under the bar (`RetroTopBar(textActions)`) on
  queue, playlist and add tracks; dialog bodies scroll (`DialogBody`); EQ
  bands header and reset wrap; landscape expanded player puts art and
  controls side by side (art had collapsed to 0 height).

## T14b Device feedback round 1

- Owner: any. Status: done. From the user's first run on a Pixel 8.
- Equalizer availability comes from the device (`AudioEffect.queryEffects`
  has an equalizer), not from a live audio session; the page said
  "not available" until something played.
- Settings like the Flutter guide (`doc/images/tutorial/06-settings.png`):
  theme as segmented buttons; language as a dropdown row; equalizer inline
  (segmented presets, horizontal band sliders with Hz label and dB value,
  reset bands); data storage, licenses, reset rows; About inline at the
  bottom. The equalizer and about sub pages go away.
- Reset dialog: buttons stacked, end aligned: keep library folders, clear
  everything, cancel.
- Speed slider drawn like the progress bar (thin track, same thumb).
- Jump buttons: three-quarter arc with arrowhead, "-15" / "+15" inside
  (Flutter `_JumpArcPainter`).
- Player sheet follows the finger between mini and expanded, snaps on release
  (velocity or past half way).
- Mini player: tapping the titles locates the playing track; the handle,
  drag and the bar chevron expand.
- Top bar actions in Flutter order with the settings cog last; the cog also
  on the expanded player and the album page.
- Navigation transitions: short slide instead of the 700 ms default fade, so
  predictive back follows the finger quickly.
- Done when: tests green, smoke, installed on the phone.
- As built: `EqualizerAvailability` + `EqualizerProbe`; `EqualizerSection`
  inline in `SettingsContent` (bands switch the EQ on, flat manual bands off;
  no enable switch); `LanguageDropdown`; `AboutSection`; `RetroSegmentedRow`,
  `RetroSlider` in `Components.kt`; `rememberSheetPosition` drives the sheet
  (`Animatable` fraction, 400 dp/s fling or half way); the expanded bar keeps
  only back and the cog (the collapse chevron duplicated back and squeezed
  the title; T14c brings it back as in the Flutter screenshots); `RetroNavHost` slides in 250 ms. Tests: `EqualizerSectionTest`,
  `SettingsContentTest`, `PlayerSheetTest` drag cases, `RetroNavHostTest`,
  cog tests in `AlbumContentTest` / `ExpandedPlayerTest`, bar order in
  `FolderContentTest`; smoke checks the inline sections and the dropdown.

## T14c Device feedback round 2

- Owner: any. Status: done. Second run on the Pixel 8; checked against
  `doc/images/tutorial/*.png`.
- Settings show no player at all (`PlayerHost(showPlayer = false)`).
- The sheet grows from the mini player up to the bottom of the current
  page's header (top bar + breadcrumbs), never over it; only the handle
  drags the collapsed sheet (the expanded body drags too). Pages report their
  header through `RetroTopBar` / `BreadcrumbStrip`
  (`rememberPlayerSheetAnchor`, keyed by the back stack entry); library pages
  call `ShareHeaderWithPlayer()` and past half way their header becomes
  "Now Playing" with the playback crumbs, back, the collapse chevron and the
  cog (Flutter `main_shell_view`). Album, playlist and queue keep their own
  bar. Mini body fades out by 25 %, the expanded body fades in from 25 %.
- Back pulls the sheet down with the finger (`SheetBackHandler`), cancel
  springs it back. Pop transitions are linear so the page stays under the
  finger.
- Locate from a played folder or the queue opens the album holding the track
  (`LibraryRepository.albumOf`, `StartupRoutes.locate(albumOfTrack)`).
- Queue: clear is the sweep icon, save as playlist opens
  `SavePlaylistScreen` (folder picker from the library sources, as Flutter's
  `SaveQueuePlaylistPage`); add tracks is a `RetroFab` like Add folder, also
  in the playlist editor.
- Bar titles may shrink below the label minimum at large font scales
  (`MIN_LABEL_SIZE / fontScale`); TextFit tolerates sub-pixel height.
- Open: no strings exist for "name taken" / "save failed"; the picker stays
  open without a message. Needs translations (ask first).
- Tests: `PlayerSheetTest` (header, handle-only drag, settings), `BackChainTest`
  (back gesture follows / cancels), `SavePlaylistViewModelTest`,
  `SavePlaylistContentTest`, `QueueContentTest`, `PlaylistContentTest`,
  `LibraryRepositoryTest.album of a track`, `StartupRoutesTest`,
  `AppViewModelTest`; smoke saves through the picker.

## T14d Device feedback round 3

- Owner: opus. Status: done. Depends: T14c.
- The whole mini player drags the sheet, not only the handle.
- About shows the build's commit time `yyyy-MM-dd HH:mm:ss` in the device
  zone (`BuildConfig.BUILD_TIME`, `buildTimeLabel`), as Flutter does.
- Back swipes: `NavHost` used its default predictive pop transitions (the
  page shrank to about 70 %), only back presses slid. `RetroNavHost` now
  passes the slide as `predictivePopEnter/ExitTransition`. Emulator framestats:
  the first swipe in a process has a ~2 s GPU frame (software renderer warm-up),
  later swipes stay under 120 ms.
- Add tracks: folders have a checkbox (every track below, in play order via
  `folderQueue`), albums open to pick single tracks, checkbox takes the whole
  album; back steps through the picker's history; "Add selected tracks"
  (`addSelectedTracks`, new ARB key in all 46 languages, approved) is a
  `RetroFab`; after adding it closes at once (it used to wait for the snackbar).
- Library pages use `LibraryRepository.watchFolder`: `LibraryScanner.invalidate`
  publishes `changed`, so a playlist saved or deleted by the app shows without
  leaving the page for 5 s (found by the smoke test once adding got faster).
- Save playlist: `RetroTextField` (underlined, page background, accent focus,
  as Flutter's `TextField`); keyboard Done saves; Save sits above the keyboard.
- Found, not changed: Turkish `addTracks` reads "Yardımcı metin ekle" ("add
  helper text").
- Tests: `PlayerSheetTest` (body drag), `BuildTimeTest`, `RetroNavHostTest`
  (swipe slides full width), `AddTracksViewModelTest`, `AddTracksContentTest`,
  `LibraryRepositoryTest` (watch), `SavePlaylistContentTest` (Done key); smoke
  adds through the new button.

## T15 M4B chapter reader

- Owner: opus. Status: done (reader). Depends: none.
- As built: `domain/.../model/Chapter.kt`; `data/.../chapters/Mp4ChapterReader.kt`
  with `ByteSource` (`of(ByteArray)`, `of(FileChannel)` for a SAF
  `ParcelFileDescriptor` via `FileInputStream(pfd.fileDescriptor).channel`).
  Nero `chpl` wins, else the `tref/chap` text track (stts/stsz/stsc/stco|co64,
  `mdhd` timescale); malformed input returns empty. Tests use boxes built in
  code plus `data/src/test/resources/chapters/ffmpeg-chapters.m4b` (real
  ffmpeg output, 1.6 KB).
- Moved to T16: caching in `TrackCacheEntity.chaptersJson` (Room v3
  auto-migration, only for `.m4b/.m4a/.mp4`, read on a background
  dispatcher when the track first plays, not during folder scans).
- Files: `domain/.../model/Chapter.kt` (`Chapter(startMs: Long, title: String)`),
  `data/.../chapters/Mp4ChapterReader.kt` reading from an `InputStream`/
  random access over the SAF document: parse boxes `moov/udta/chpl` (Nero)
  and QuickTime chapter tracks (`trak` referenced by `tref/chap`, samples are
  text with 2-byte length prefix, times from `stts` + `mdhd` timescale).
  Prefer Nero when both exist; titles UTF-8; cache result in
  `TrackCacheEntity` (new column `chaptersJson`, Room migration).
- Fixtures: create with ffmpeg (QuickTime text chapters) and a hand-built
  `chpl` box in test code; put files in `data/src/test/resources/chapters/`.
- Tests: `Mp4ChapterReaderTest`: `reads nero chapters`, `reads quicktime chapter track`,
  `no chapters returns empty`, `truncated file returns empty without throwing`,
  `chapter times use the media timescale`.
- Done when: tests green.

## T16 Chapters in player, notification and seek bar

- Owner: any. Status: done. Depends: T03, T15.
- Spec: service loads chapters for the current track (on media item
  transition, IO dispatcher), feeds `RetroPlayer(chapterStartsMs = ...)`, and
  publishes them in the media item's extras; `NowPlaying.chapters`.
  Expanded player: ticks on the seek bar at chapter starts, current chapter
  title under the track title, chapter list sheet (tap seeks), chapter
  previous/next buttons when chapters exist. Notification: Media3
  `CommandButton`s with custom `SessionCommand`s `app.retroplayer.CHAPTER_PREV`
  / `CHAPTER_NEXT` via `MediaSession.setMediaButtonPreferences` only when
  the track has chapters. Native strings `chapters`, `previous_chapter`, `next_chapter`.
- Tests: `RetroPlayerTest`: `jump stops at chapter start` (exists, keep);
  `ChapterNavigationTest` (domain pure): `next chapter from inside a chapter`,
  `previous chapter within 3 s of a start goes to the one before`;
  `ExpandedPlayerTest`: `chapter list seeks to the chapter`.
- Done when: tests green; smoke with an M4B fixture pushed to the emulator.
- Done (as built):
  - No Room column: `data/.../chapters/ChapterRepository.kt` reads
    `.m4b/.m4a/.mp4` once through `SafChapterSource` and keeps the last 32
    tracks in memory (failures read as no chapters). The service and the UI
    run in one process and share the singleton, so the UI does not need
    media item extras.
  - `domain/.../ChapterNavigation.kt`: `current`, `next`, `previous`
    (restart within the chapter, the one before within 3 s of a start).
  - Service: `ChapterTracker` loads on media item transition and feeds
    `RetroPlayer` chapter starts and `ChapterCommands.buttons` (notification
    back/forward slots, `ChapterLabels` from `AppModule`); `onConnect` adds
    the two commands, `onCustomCommand` seeks.
  - UI: `PlayerViewModel` loads chapters for `trackUri`, chapter steps seek
    through `PlaybackControls.seekTo`; expanded player shows
    "‹ chapter ›" under the titles (tap opens a `ModalBottomSheet` list) and
    ticks on `PlaybackProgress(marksMs)`.
  - Strings as ARB keys in all 46 languages: `chapters`, `previousChapter`,
    `nextChapter` (plus the T17 keys `headphones`, `autoRewind`,
    `autoRewindHint`, `rewindBy`, `secondsShort`, `resumeOnReconnect`,
    `resumeOnReconnectHint`).
  - Tests: `ChapterNavigationTest`, `ChapterRepositoryTest`,
    `ChapterTrackerTest`, `ChapterCommandsTest`, `PlayerViewModelTest`
    (5 chapter cases), `ExpandedPlayerTest` (3 chapter cases).
  - Emulator: 6-min M4B with 4 chapters; row, ticks, list seek and the
    notification's chapter back (restart, then previous) checked.

## T17 Headset options UI + resume on reconnect

- Owner: any. Status: done. Depends: T10.
- Existing: `HeadsetSettings(autoRewind, autoRewindSeconds, resumeOnReconnect)`,
  `AutoRewindTracker`, `TransportRules.autoRewindMs`, becoming-noisy pause.
- Spec:
  - Settings page "Headset" (native strings): auto-rewind switch, seconds
    (5, 10, 15, 30 chips), resume on reconnect switch.
  - Resume on reconnect: pure `ReconnectPolicy.shouldResume(pausedByNoisyAtMs,
    nowMs, enabled)` (true when enabled and the pause came from becoming
    noisy less than 10 minutes ago). Service records the time when
    `onPlayWhenReadyChanged` reason is
    `PLAY_WHEN_READY_CHANGE_REASON_AUDIO_BECOMING_NOISY`; an
    `AudioDeviceCallback` (`AudioManager.registerAudioDeviceCallback`) on
    added outputs of type wired headset/headphones, BT A2DP, USB headset
    asks the policy and calls `play()`.
- Tests: `ReconnectPolicyTest` (4 cases), `HeadsetSettingsViewModelTest`:
  `default values leave no stored keys`, `turning resume on stores it`.
- Done when: tests green.
- Done (as built):
  - A "Headphones" section on the settings page (after the equalizer), not
    a separate page: `HeadsetSection` (switch rows with hints, seconds as a
    segmented row, disabled while rewinding is off) over
    `HeadsetSettingsViewModel`; strings are the ARB keys added in T16.
  - `domain/.../ReconnectPolicy.kt`; `playback/.../ReconnectWatcher.kt`
    keeps the noisy-pause time (cleared by any play) and resumes once on
    added wired/USB/A2DP/BLE headset outputs. The service feeds it from an
    exo listener and an `AudioDeviceCallback`. Starting the foreground
    service from the background can be refused on Android 12+; Media3 then
    shows its resume notification.
  - Tests: `ReconnectPolicyTest` (4), `ReconnectWatcherTest` (5),
    `HeadsetSettingsViewModelTest` (4), `HeadsetSectionTest` (4),
    `TextFitTest` `headset`, `player_chapters`, `chapter_list`.
  - Emulator: section look and stored choices checked; reconnect itself
    needs real headphones (Pixel).

## T18 Android Auto browse tree

- Owner: opus. Status: done. Depends: T05.
- Files: `playback/.../LibraryTree.kt` (pure over repository/store
  interfaces), `PlaybackService.onGetChildren/onGetItem/onGetLibraryRoot`,
  `res/xml/automotive_app_desc.xml` (`<uses name="media"/>`), manifest
  meta-data `com.google.android.gms.car.application` (resource reference
  only; no Play services dependency).
- Tree: root → `Library sources` (each root → its folder tree), `Favorites`,
  `Queue`. Folder node children: subfolders (browsable), albums (browsable
  and playable; children are tracks), playlists (playable), loose tracks
  (playable). Media ids: `nav:roots`, `nav:favorites`, `browse:<path>`,
  album ids, `playlist:<path>`, track paths, `queue`. Playing any playable
  node sends the same request path as the phone UI (`onSetMediaItems`).
  Paging: honour `page`/`pageSize`.
- Tests: `LibraryTreeTest`: `root lists sources favorites and queue`,
  `folder lists subfolders albums playlists and tracks in display order`,
  `album children are its tracks in effective order`, `paging slices children`,
  `unknown id returns no children`.
- Done when: tests green; manual check with the Desktop Head Unit if
  available (`$ANDROID_HOME/extras/google/auto/desktop-head-unit`), else
  note "DHU not run" in Notes.
- As built: `LibraryTree` takes lambdas (roots, favorites, folder,
  album tracks) plus `TreeLabels` (provided by `AppModule` from
  `library_sources`/`favorites`/`queue`, not a singleton so it follows the
  app language at service start). Folder nodes use `PlaybackItem` folder ids
  and are browsable and playable; album track ids are
  `PlaybackRequests.inItem(albumId, trackId)`, which `parseId` turns into
  "play the album starting at this track". `onGetItem` returns a bare
  playable item for the id; playback always goes through `onSetMediaItems`.
  Notes: DHU not run (not installed). Artwork on browse nodes not set yet
  (T16/T19 may add it via the existing art URIs).

## T19 Glance home-screen widget

- Owner: any. Status: done. Depends: T01.
- New dependency allowed: `androidx.glance:glance-appwidget-testing`
  (testImplementation, same version as glance).
- Spec: `ui/widget/RetroWidget.kt` (`GlanceAppWidget`) + receiver; layout:
  art, title, subtitle, previous, jump back, play/pause, jump forward, next;
  sizes `SizeMode.Responsive` (small: title + play/pause; wide: all).
  Actions: an `ActionCallback` that connects a `MediaController` to the
  session and runs the command. State: the service writes title, subtitle,
  isPlaying, art URI into the widget's Glance state on `onEvents` (throttled)
  and calls `updateAll`. Tap on the widget body opens `MainActivity`.
  Review the merged release manifest: WorkManager (from Glance) adds
  `RECEIVE_BOOT_COMPLETED`; keep it and document why in T21.
- Tests (`runGlanceAppWidgetUnitTest`): `shows title and play button when paused`,
  `shows pause button while playing`, `small size shows only title and play pause`.
- Done when: tests green; smoke: add widget on emulator home screen
  (long-press home, Widgets), controls work.
- Done (as built):
  - Buttons send `ACTION_MEDIA_BUTTON` intents straight to `PlaybackService`
    (`actionStartService`, one category per key so the pending intents stay
    apart; only play starts it in the foreground) instead of an
    `ActionCallback` with a `MediaController`. Media3 handles them like
    headset keys, so jumps follow the same rules as the notification.
  - State: the service publishes a `NowPlayingSnapshot` through
    `NowPlayingSink` on `onEvents`; `WidgetUpdater` (singleton, skips equal
    snapshots) holds it as a `StateFlow` and calls `updateAll`. No Glance
    state store. Without a session the widget shows the last played
    bookmark; with nothing played, the app name.
  - Three sizes: small (title + play/pause), row (adds cover and jumps),
    wide (cover and titles above previous, back, play, forward, next).
    Colours follow the system dark mode.
  - Merged manifest: no network permission; `RECEIVE_BOOT_COMPLETED` comes
    from WorkManager and stays (T21 documents it).
  - Tests: `RetroWidgetTest` (6), `WidgetUpdaterTest` (3),
    `NowPlayingSnapshotTest` (4).
  - Emulator: widget placed from the launcher, play/pause, ±15 s jumps,
    tap opens the app, dark mode checked. The picker preview is the
    initial layout (no `previewLayout` yet).

## T20 Managed devices + Roborazzi screenshots

- Owner: any. Status: done. Depends: T02.
- Spec:
  - Gradle Managed Devices in `app/build.gradle.kts` (`testOptions.managedDevices`),
    AOSP ATD images (`systemImageSource = "aosp-atd"`): `pixel2Api26`
    (Pixel 2, API 26), `pixel4Api30`, `pixel7Api33`, `pixel9Api35`,
    `pixelTabletApi35`, `pixelFoldApi35`. Groups: `phones` (26, 33, 35),
    `fullMatrix` (all). Check the AGP 9 DSL names in the AGP docs if the
    build complains (`localDevices` vs `allDevices`).
  - Instrumented tests `app/src/androidTest/`: launch shows the empty
    library; add a root through the real picker with UiAutomator
    (`androidx.test.uiautomator`, add to catalog) using a pre-pushed folder;
    play a track and see the mini player; rotate keeps the state.
    If ATD images lack DocumentsUI, use `systemImageSource = "aosp"` for the
    picker test only.
  - Roborazzi: add plugin `io.github.takahirom.roborazzi` (version ref
    `roborazzi`) and libs `roborazzi`, `roborazzi-compose`, `roborazzi-junit-rule`
    to the catalog; screenshot each Content composable light/dark,
    compact/expanded width, `de`, `ar-rXB`, font scale 2. Record with
    `./gradlew recordRoborazziDebug`, verify in CI with `verifyRoborazziDebug`.
    Before recording, compare the light recordings of Library, mini player,
    expanded player, album, playlist and settings with
    `doc/images/tutorial/01..06` and fix deviations first (AGENTS.md
    "Look and feel").
  - Re-capture the user-guide screenshots from the native app (light, sample
    audio from `scripts/push-sample-audio-to-emulator.sh`) with
    `scripts/ui.sh shot` into `doc/images/tutorial/` only in T21, and only
    if they still match the layout described in USAGE.md.
  - CI (`.github/workflows/android-native.yml`): add `verifyRoborazziDebug`;
    `phonesGroupDebugAndroidTest` only if the runner has KVM (document).
- Done when: `./gradlew phonesGroupDebugAndroidTest` passes locally (needs
  `["all"]`), screenshots recorded and committed.
- Notes:
  - Devices use `systemImageSource = "aosp"` (ATD images have no DocumentsUI,
    which the picker tests need). The Pixel 2 runs API 27, not 26 (only the
    API 27 image is set up here), so `minSdk` 26 itself has no managed device.
  - The smoke tests create the sample folder themselves (`SampleLibrary`), so
    managed devices need no adb push. New tests: fresh start shows the empty
    library; rotating keeps the page and the player.
  - `ScreenshotTest` (94 images in `app/src/test/screenshots/`) reuses the
    `TextFitTest` screens. Comparing with `doc/images/tutorial/` found two
    deviations, fixed before recording: settings block titles use Flutter's
    `trackTitle` (20 sp), and the playlist page says "Playlist" in the top bar
    with the name as a 17 sp header (`PlaylistContentTest`). Robolectric draws
    all font weights alike and no slider thumb outline; that is not a bug.

## T21 Docs

- Owner: any. Status: done. Depends: all feature tasks.
- `android-native/README.md`: what it is, build, test, emulator smoke test,
  managed devices, screenshot tests, module map (link AGENTS.md).
- Root `README.md`: section "Native Android app".
- `doc/REQUIREMENTS.md` UC-07: "no reordering" becomes "no manual
  reordering; selectable sort order (tag order, file name, title), stored per
  album". Add Android-native notes where behaviour differs (natural sort,
  write access optional).
- `doc/USAGE.md`: Android section (adding folders, write access for
  playlists, Android Auto, widget, headset options, chapters).
- Done when: links checked, no stale Flutter-only statements for Android.
- Done (as built): `android-native/README.md` (new), root README section,
  docs index entry, REQUIREMENTS "Android native" notes (UC-02, 04, 07, 08,
  10, 15, 16, 17; non-goal on ordering corrected; UC-16 languages), USAGE
  "Native Android app" section, save-playlist and ±15 s rows corrected for
  both apps, two broken `lib/` links in REQUIREMENTS fixed. Relative links
  checked by script (only the planned `MANUAL_TESTING.md` is missing).
  User-guide screenshots `doc/images/tutorial/01..06` re-captured from the
  native app (user decision; emulator, light, sample audio plus a
  `Demo Mix.m3u`, system bars cropped); steps in that folder's README. The
  Flutter captures stay in git history.

## T22 Final release check

- Owner: any. Status: done. Depends: T01-T21.
- `./gradlew check assembleRelease` green; merged release manifest has no
  `INTERNET`/`ACCESS_NETWORK_STATE`; full smoke test of UC-01 to UC-17 on
  the emulator (list each UC with pass/fail in Notes); APK size noted;
  `git log` clean; update the status table.
- Done (as built): `check assembleRelease verifyRoborazziDebug` green, device
  smoke green on the API 34 emulator. Release permissions: FOREGROUND_SERVICE
  (+ MEDIA_PLAYBACK), WAKE_LOCK, POST_NOTIFICATIONS, RECEIVE_BOOT_COMPLETED
  (Glance/WorkManager) and the AndroidX dynamic-receiver permission; no
  network. Release APK (unsigned, R8): 4,680,514 bytes (4.5 MiB). Per-UC
  results in Notes. Fixed on the way: play after the queue ended needed two
  taps; untagged tracks in a library root showed the root id ("1") as album
  in the player and notification; the reset-dialog screenshots contained the
  live build time and commit, so `verifyRoborazziDebug` failed after every
  commit (About values now come from `LocalBuildInfo`, pinned in the test).

---

## Notes

(Agents: add dated notes per task here when the task section is not enough.)

### 2026-11-04 T22 manual smoke (emulator API 34, debug build, sample audio)

| UC | Result | Checked |
|----|--------|---------|
| UC-01 | pass | fresh start shows the empty library; cold start reopens the album detail with the mini player paused at the saved position |
| UC-02 | pass | add via system picker (read-only grant); end-edge swipe on the root asks, removes it and clears playback; files stay |
| UC-03 | pass | folders, playlists and audio sections; untagged WAV falls back to the file name |
| UC-04 | pass | browse in, breadcrumbs, back goes up; swipe right favorites a folder, starred link at the root (A-Z bar in device smoke) |
| UC-05/06 | n/a | not in REQUIREMENTS |
| UC-07 | pass | album row opens the detail, track tap plays from it |
| UC-08 | pass | file `.m3u` opens read-only, remote entry dropped, row tap plays; queue save/delete in device smoke |
| UC-09 | pass | track tap and row play button start playback, sheet expands |
| UC-10 | pass (after fix) | pause/play, previous/next, ±15 s, chapter skip on the M4B; play after the queue ended needed two taps, fixed |
| UC-11 | pass | process restart rebuilds the queue paused; finished queue restarts at the first track |
| UC-12 | pass | playback expands the sheet, back collapses it |
| UC-13 | pass | mini player title opens the album and highlights the playing track |
| UC-14 | pass | back: player, then detail, then folders up one level each |
| UC-15 | n/a | desktop only |
| UC-16 | pass | dark theme and EQ preset survive restart; licenses, data storage, about; reset keeping folders clears favorites, playback and theme |
| UC-17 | pass (after fix) | plays with the screen off; notification and media buttons pause/play and the app mirrors it; Recents swipe-away pauses and keeps the position; root-level tracks showed album "1", fixed |

Follow-ups, done after T22 (ARB, so both apps): `tracksCountArtist` is an
ICU plural ("1 track"; the `=1` branch uses `{count}` because Flutter maps it
to the CLDR "one" category, which also covers 21, 31 ... in several
languages); broken fa/et/fr counts fixed. The native Data storage page uses
the new `dataStorageAndroidNativeBody` (the first paragraph of the Flutter
text, without the audio/photo permission sentence). Literal `&#10;`/`&#39;`
in vi, tr, ko, it, ja, ru replaced; Flutter showed them raw.

Seen twice: the first `check` after a source change can crash in
`lintAnalyzeDebugAndroidTest` ("Unexpected failure during lint analysis",
Kotlin FIR phase error inside lint); the rerun passes.
