# Retro Player — use-case requirements

Retro Player is a **read-only front end for audio folders on local storage**.
It browses, plays and resumes; it never changes the user's files. The only
disk writes are playlists the app itself creates (and edits or deletes later).

Each use case lists actor and goal, preconditions, main flow, alternative flows,
persisted state and acceptance criteria (AC). Test coverage per use case lives in
[TEST_PLAN.md](TEST_PLAN.md). Items marked *(target)* are agreed behavior that
the refactor introduces; everything else describes the app as it ships.

## Non-goals

- Manual ordering of any list (library, album tracks). Lists are sorted by metadata only.
- Renaming, moving, tagging or deleting audio files or folders.
- Writing to playlists found on disk (they are read-only).
- Sleep timer, in-app volume, tag-based Artist/Album/Songs views.
- Network access of any kind (streams, remote playlists, cover downloads).

## Glossary

| Term | Meaning |
|------|---------|
| Library root | A folder the user added; everything shown lives below a root. |
| Browse path | The folder currently shown in folder mode (`null` = list of roots). |
| Album | Tracks in one directory grouped by tags (`GroupTracksIntoAlbums`). |
| Playback item | What a queue was started from: album, folder (recursive), playlist or track. |
| Player sheet | The draggable mini/expanded player on library, album and playlist pages. |

---

## UC-01 App start and session restore

- **Actor / goal:** user opens the app and continues where they left off.
- **Preconditions:** none (first start shows the empty library).
- **Main flow:** open DB → **in parallel** restore library browse path / queue
  metadata and restore last playback **paused** at the saved position (engine
  queue hydrate may finish after the shell is visible) → reopen the album detail
  that was open → apply saved theme, locale and equalizer. When a playback
  snapshot exists in `playback_states`, the mini player may show the saved title
  before transport is ready; play stays disabled until the engine has a track.
- **Alternatives:** saved path no longer under a root → library root. Media
  session init fails → app runs without notification / MPRIS.
- **Persisted:** `app_settings` (browse path/mode, album detail id, last item),
  `playback_states`.
- **AC:** cold start shows the saved folder and mini player with the saved track
  title and position (snapshot and/or engine); nothing plays until the user
  presses play and `hasTrack` is true.

## UC-02 Add and remove library roots

- **Actor / goal:** user chooses which folders the app shows.
- **Preconditions:** Android grants audio/storage access.
- **Main flow (add):** "Add folder" FAB or Ctrl+O → permission → directory
  picker → root stored → app browses into it.
- **Main flow (remove):** swipe a root row (or Delete on a selected root) →
  confirm → root removed; playback under it stops and is cleared.
- **Alternatives:** permission denied → snackbar; picker cancelled → no change.
- **Persisted:** `library_roots`.
- **AC:** files are never copied or modified; removing a root only forgets it.

## UC-03 Lazy folder scan and metadata

- **Actor / goal:** app shows the contents of the folder being viewed.
- **Preconditions:** folder is under a root.
- **Main flow:** list subfolders and playlists, then audio files; read tags;
  group tracks into albums; sort; resolve covers lazily.
- **Alternatives:** cached folder shows instantly and refreshes in background.
  Unreadable tags fall back to file name.
- **Persisted:** none (in-memory directory cache).
- **AC:** subfolders appear before tags are read. *(target)* Every audio file
  appears right away as a placeholder named after the file, and each row fills
  in with its metadata as soon as that file is read; album rows form as their
  tracks arrive, no row appears twice, scroll position and keyboard selection do
  not jump, and leaving the folder cancels the scan. Tag reads never block the UI.

## UC-04 Browse in folder mode

- **Actor / goal:** navigate like a file manager.
- **Main flow:** tap a folder → browse into it; breadcrumbs jump to any parent;
  A–Z index bar on long lists; sections Folders, Playlists, Audio. Swipe right
  on a nested folder marks it as a favorite; the same swipe clears it.
  Favorites appear at the library root as starred links. A long press drags a
  favorite link to a new position, and that order is saved with the paths.
- **Alternatives:** system back / Backspace / Alt+← goes up one level.
- **Persisted:** browse path; scroll offset per path (memory); favorite folder paths in display order.
- **AC:** going up restores the parent's scroll position; the root shows
  library roots and favorite links. A favorite is not removed by the root swipe.

## UC-07 Album detail

- **Actor / goal:** see an album's tracks and play one.
- **Main flow:** tap an album row (▶ plays directly) → detail page → tap a track
  → queue starts at it.
- **Alternatives:** restored on cold start; "locate now playing" highlights the track.
- **Persisted:** `library_album_detail_id` while open.
- **AC:** tracks are in tag order; no reordering.

## UC-08 Playlists

- **Actor / goal:** compose a queue, play it, and save it as a playlist; play
  `.m3u`/`.m3u8` files already in the library.
- **Main flow:** the queue is available from the library, including the root
  (app bar or Ctrl+N). Add tracks with the in-app picker, long-press to
  reorder, swipe to remove, or clear the whole queue. Tracks that have already
  played stay in the list until the queue is cleared.
  Tap a row to play the queue from that track. There is no separate play
  button on the queue or on a playlist's app bar. Save writes an app-created
  M3U after a real library folder is open (a library source or a folder inside
  one) and the user names the file. The queue itself stays.
- **Alternatives:** playing a folder, album, or file playlist replaces what is
  playing and leaves the stored queue in place. The virtual library root is
  not a directory, so Save stays off there. Missing playlist entries show as
  missing. Remote entries are rejected. A row tap on a saved playlist still
  starts playback. Clear asks first, then drops the stored queue. If that queue
  is what is playing, playback stops. A folder, album, or file playlist that
  is already playing keeps playing. Audio files and saved playlists stay.
- **Persisted:** queue paths and index in `app_settings` (`playback_queue`);
  position and speed in `playback_states` for item id `queue`; playlist files;
  `app_created_playlist:{path}` registry.
- **AC:** the queue survives a restart and folder playback. Cold start resumes
  the queue when it was last active. Saving from the virtual root is refused.
  Only app-created playlists can be edited, saved or deleted. Playlists found
  on disk open read-only (no save, add, reorder or remove).

## UC-09 Play album, folder, playlist or track

- **Actor / goal:** start gapless playback from any item.
- **Main flow:** ▶ on a row, Space on the selected row, or a track tap → queue
  built → plays → player sheet expands on library pages.
- **Alternatives:** same queue already loaded → just play/seek; empty playlist → snackbar.
- **Persisted:** `playback_states` keyed by playback item.
- **AC:** playback never jumps to an unrelated item; queue order follows the list order.

## UC-10 Transport

- **Main flow:** play/pause, previous/next, seek bar, speed 0.5×–2.0×. The maximized player jumps 15 seconds from buttons on each side of the album art, from a double tap on the left or right half of the art, and from Ctrl+Shift+←/→.
- **Persisted:** position (every 10 s while playing and on pause/seek/skip/speed/background), speed. A jump seeks, so the bookmark moves with it.
- **AC:** progress bar moves while playing; speed persists per item; a jump stops at the start of the chapter and at the end when the length is known.

## UC-11 Resume across restart

- **Main flow:** cold start rebuilds the last queue paused at the saved position;
  starting a previously played item resumes it.
- **AC:** resume survives rescans because track ids are normalized file paths.

## UC-12 Player sheet expand and collapse

- **Main flow:** drag the handle, tap the AppBar toggle, Ctrl+↑/↓, or start
  playback → sheet expands; back / drag / toggle collapses.
- **Alternatives:** Settings shows a fixed mini dock instead of the sheet.
- **AC:** one sheet is active at a time; after closing a detail page the
  library's mini player is visible and works.

## UC-13 Locate now playing and playback breadcrumbs

- **Main flow:** tap title/art → collapse player → navigate to the folder (or
  playlist) of the current track and highlight it; breadcrumbs of the playing
  item jump to their folder.
- **AC:** the highlight clears on manual browsing.

## UC-14 System back and edge swipe (Android)

- **Desktop:** on Linux, Windows, and macOS, an AppBar ← control appears when
  back would not be absorbed (same order as below), via
  [`AppBarBackLeading`](lib/ui/core/navigation/app_bar_back_leading.dart).
  Main Settings keeps Material’s implicit back; pushed Settings subpages use
  [`DesktopSubpageBackLeading`](lib/ui/core/navigation/app_bar_back_leading.dart).
- **Rules, in order:**
  1. Settings or a Settings subpage open → close it.
  2. Player expanded → collapse it (also over album or playlist detail).
  3. Album or playlist detail → close it.
  4. Folder below a root → go up one level.
  5. Library root → absorb (the app stays; quit via Recents).
- **AC:** the app always owns back (`setFrameworkHandlesBack(true)`), including
  after Settings round trips, detail pages and player expand/collapse; an edge
  swipe never slides the app away; each swipe moves exactly one step.

## UC-15 Desktop keyboard

- **Main flow:** shortcuts for library, player, playlist and settings (see
  DEVELOPMENT_PLAN key table); arrow-key list navigation; Escape mirrors back.
- **AC:** shortcuts are disabled while a text field has focus.

## UC-16 Settings

- **Main flow:** theme (light/dark/system), language (en/de/system), equalizer
  (presets and 5 bands where supported), data storage info, licenses, reset
  database, about.
- **Persisted:** `theme_preference`, `locale_preference`, `equalizer_*`.
- **AC:** changes apply immediately and survive restart. Reset database clears
  playback, favorites, browse path, theme, language, and equalizer. Keeping
  library folders leaves those paths listed. Clear everything also forgets the
  added folders and empties the library. Audio files and playlist files on
  disk stay either way.

## UC-17 Background playback and media session

- **Main flow:** playback continues with the screen off; notification / MPRIS
  shows title, artist, and album (file name and folder name when those tags
  are missing) plus transport; Recents swipe-away stops audio and saves position.
- **AC:** transport from the notification mirrors the in-app state.

## UC-18 Privacy

- **AC:** release build has no INTERNET permission; only local file paths are
  played; remote playlist entries are rejected; no network dependencies.
