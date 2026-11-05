# Retro Player — use-case requirements

Retro Player is a **read-only front end for audio folders on local storage**,
for Android. It browses, plays and resumes; it never changes the user's files.
The only disk writes are playlists the app itself creates (and edits or
deletes later).

Each use case lists actor and goal, preconditions, main flow, alternative flows,
persisted state and acceptance criteria (AC). Items marked *(target)* are agreed
behavior that is not fully implemented yet; everything else describes the app
as it ships. Persisted names refer to Room tables (`RetroDatabase`) and
DataStore keys (`SettingsStore`).

## Non-goals

- Manual ordering of folder contents and album tracks. Folder contents are
  sorted by metadata. Library roots, favorites, the queue and app-created
  playlists keep the order the user drags them into.
- Renaming, moving, tagging or deleting audio files or folders.
- Writing to playlists found on disk (they are read-only).
- Sleep timer, in-app volume, tag-based Artist/Album/Songs views.
- Network access of any kind (streams, remote playlists, cover downloads).

## Glossary

| Term | Meaning |
|------|---------|
| Library root | A folder the user added; everything shown lives below a root. |
| Browse path | The folder currently shown (`null` = list of roots). |
| Album | Tracks in one directory grouped by tags (`AlbumIds.folder` / `AlbumIds.tag`). |
| Playback item | What a queue was started from: album, folder (recursive), playlist or track. |
| Player sheet | The draggable mini/expanded player on library, album and playlist pages. |

---

## UC-01 App start and session restore

- **Actor / goal:** user opens the app and continues where they left off.
- **Preconditions:** none (first start shows the empty library).
- **Main flow:** restore the browse path and the album detail that was open,
  restore the last queue **paused** at the saved position, apply theme and
  equalizer. The mini player shows the saved title and position.
- **Alternatives:** saved path no longer under a root → library root.
- **Persisted:** `browse_path`, `open_album`, `last_item`, `queue`;
  `playback_states`.
- **AC:** cold start shows the saved folder and the mini player with the saved
  track title and position; nothing plays until the user presses play.

## UC-02 Add and remove library roots

- **Actor / goal:** user chooses which folders the app shows.
- **Preconditions:** none; the app asks for no storage or media permission.
- **Main flow (add):** "Add folder" FAB → system folder picker → read-only
  grant stored → root appears in the library.
- **Main flow (remove):** swipe a root row from the end edge → confirm → root
  removed; playback under it stops and is cleared.
- **Alternatives:** picker cancelled → no change.
- **Persisted:** `library_roots` (with the persisted URI grant).
- **AC:** files are never copied or modified; removing a root only forgets it
  (database rows and the access grant). Library roots reorder by long-press
  drag. Write access is asked for later, only when a playlist is saved (UC-08).

## UC-03 Lazy folder scan and metadata

- **Actor / goal:** app shows the contents of the folder being viewed.
- **Preconditions:** folder is under a root.
- **Main flow:** list subfolders and playlists, then audio files; read tags;
  group tracks into albums; sort; resolve covers lazily.
- **Alternatives:** cached folder shows instantly and refreshes in background.
  Unreadable tags fall back to file name.
- **Persisted:** `track_cache` (tags per file, refreshed when the file changes).
- **AC:** subfolders appear before tags are read. *(target)* Every audio file
  appears right away as a placeholder named after the file, and each row fills
  in with its metadata as soon as that file is read; album rows form as their
  tracks arrive, no row appears twice, the scroll position does not jump, and
  leaving the folder cancels the scan. Tag reads never block the UI.

## UC-04 Browse in folder mode

- **Actor / goal:** navigate like a file manager.
- **Main flow:** tap a folder → browse into it; breadcrumbs jump to any parent;
  A–Z index bar on long lists; sections Folders, Playlists, Audio. Swipe a
  nested folder from the start edge to mark it as a favorite; the same swipe
  clears it. Favorites appear at the library root as starred links. A long
  press drags a favorite link to a new position, and that order is saved.
  Swiping a row from the end edge adds it to the queue (folders, favorites,
  playlists, albums, tracks).
- **Alternatives:** system back goes up one level (with the predictive back
  preview of the real parent folder).
- **Persisted:** browse path; favorite folder paths in display order
  (`favorite_folders`).
- **AC:** going up restores the parent's scroll position; the root shows
  library roots and favorite links. A favorite is not removed by the root
  swipe. Names sort naturally: case and accent insensitive, and numbers by
  value (`Track 2` before `Track 10`). The A–Z bar always shows the whole
  alphabet, plus `#` and `•` when names start with digits or other characters;
  tapping or sliding jumps to the first row of that letter, or of the next
  letter that has rows. Accented letters count as their base letter.

## UC-07 Album detail

- **Actor / goal:** see an album's tracks and play one.
- **Main flow:** tap an album row (▶ plays directly) → detail page → tap a track
  → queue starts at it.
- **Alternatives:** restored on cold start; "locate now playing" highlights the track.
- **Persisted:** `open_album` while open; sort order per album (`album_sorts`).
- **AC:** no manual reordering. The sort order is selectable (tag order, file
  name, title) and stored per album. By default an album uses tag order when
  every track has a distinct track number, and file name order otherwise;
  forcing tag order on such an album asks first and lists the unnumbered
  tracks after the numbered ones.

## UC-08 Playlists

- **Actor / goal:** compose a queue, play it, and save it as a playlist; play
  `.m3u`/`.m3u8` files already in the library.
- **Main flow:** the queue is available from the library app bar, including
  the root. Add tracks with the in-app picker, long-press to reorder, swipe to
  remove, or clear the whole queue. Tracks that have already played stay in
  the list until the queue is cleared. Tap a row to play the queue from that
  track. There is no separate play button on the queue or on a playlist's app
  bar. Save writes an app-created M3U after a real library folder is open (a
  library source or a folder inside one) and the user names the file. The
  queue itself stays.
- **Alternatives:** playing a folder, album, or file playlist replaces what is
  playing and leaves the stored queue in place. The virtual library root is
  not a directory, so Save stays off there. Missing playlist entries show as
  missing. Remote entries are rejected. A row tap on a saved playlist still
  starts playback. Clear asks first, then drops the stored queue. If that queue
  is what is playing, playback stops. A folder, album, or file playlist that
  is already playing keeps playing. Audio files and saved playlists stay.
  Write access is optional: the first save into a library root opens the
  system folder picker at that root to grant write access; choosing another
  folder or cancelling saves nothing, and the library keeps working read-only.
- **Persisted:** `queue` (paths and index); position and speed in
  `playback_states` for the queue item; playlist files; `app_playlists`
  registry.
- **AC:** the queue survives a restart and folder playback. Cold start resumes
  the queue when it was last active. Saving from the virtual root is refused.
  Only app-created playlists can be edited, saved or deleted. Playlists found
  on disk open read-only (no save, add, reorder or remove).

## UC-09 Play album, folder, playlist or track

- **Actor / goal:** start gapless playback from any item.
- **Main flow:** ▶ on a row or a track tap → queue built in the playback
  service → plays → player sheet expands on library pages.
- **Alternatives:** same queue already loaded → just play/seek; empty playlist → snackbar.
- **Persisted:** `playback_states` keyed by playback item.
- **AC:** playback never jumps to an unrelated item; queue order follows the list order.

## UC-10 Transport

- **Main flow:** play/pause, previous/next, seek bar, speed 0.5×–2.0×. The
  expanded player jumps 15 seconds from buttons on each side of the album art
  and from a double tap on the left or right half of the art.
- **Persisted:** position (every 10 s while playing and on pause/seek/skip/speed/background), speed. A jump seeks, so the bookmark moves with it.
- **AC:** progress bar moves while playing; speed persists per item; a jump
  stops at the start of the chapter and at the end when the length is known.
  M4B/M4A chapters show as ticks on the seek bar and as the current chapter
  title under the track; a chapter list seeks, and previous/next chapter
  buttons appear in the player and the notification when a track has chapters.

## UC-11 Resume across restart

- **Main flow:** cold start rebuilds the last queue paused at the saved position;
  starting a previously played item resumes it.
- **AC:** resume survives rescans because track ids are normalized file paths.

## UC-12 Player sheet expand and collapse

- **Main flow:** drag the handle, tap the app bar toggle, or start playback →
  sheet expands; back / drag / toggle collapses.
- **Alternatives:** Settings shows a fixed mini player instead of the sheet.
- **AC:** one sheet is active at a time; after closing a detail page the
  library's mini player is visible and works.

## UC-13 Locate now playing and playback breadcrumbs

- **Main flow:** tap title/art → collapse player → navigate to the folder (or
  playlist) of the current track and highlight it; breadcrumbs of the playing
  item jump to their folder.
- **AC:** the highlight clears on manual browsing.

## UC-14 System back and edge swipe

- **Rules, in order:**
  1. Settings or a Settings subpage open → close it.
  2. Player expanded → collapse it (also over album or playlist detail).
  3. Album or playlist detail → close it.
  4. Folder below a root → go up one level.
  5. Library root → nothing happens (the app stays; quit via Recents).
- **AC:** each back gesture moves exactly one step and shows the predictive
  back preview of the destination. Edge swipes belong to the system: the app
  never excludes system gesture areas.

## UC-15 *(removed)*

Desktop keyboard shortcuts belonged to the former desktop version.

## UC-16 Settings

- **Main flow:** theme (light/dark/system), language (system or any bundled
  translation, as Android's per-app language), equalizer (presets and 5 bands
  where supported), headphones, data storage info, licenses, reset database,
  about.
- **Persisted:** `theme`, `eq_enabled`, `eq_preset`, `eq_manual_gains`,
  `headset_*`; the language is stored by Android. Only non-default values are
  stored.
- **AC:** changes apply immediately and survive restart. Reset database clears
  playback, favorites, browse path, theme, language, and equalizer. Keeping
  library folders leaves those paths listed. Clear everything also forgets the
  added folders and empties the library. Audio files and playlist files on
  disk stay either way. Headphones: "Rewind on resume" (on by default, 5 s):
  after a pause of at least a minute, tracks longer than 20 minutes resume 5,
  10, 15 or 30 seconds earlier. "Resume when headphones reconnect" (off by
  default): playback continues when wired, USB or Bluetooth headphones
  (including car audio) come back within 10 minutes of the disconnect that
  paused it.

## UC-17 Background playback and media session

- **Main flow:** playback continues with the screen off; the notification
  shows title, artist, and album (file name and folder name when those tags
  are missing) plus transport; Recents swipe-away stops audio and saves position.
- **AC:** transport from the notification mirrors the in-app state. Android
  Auto shows a browse tree (library sources with their folders, albums,
  playlists and tracks; favorites; queue) and plays any playable node like the
  phone does. A home-screen widget shows the current item with play/pause, and
  on larger sizes cover, ±15 s jumps and previous/next; tapping it opens the app.

## UC-18 Privacy

- **AC:** release build has no `INTERNET` permission (`verifyReleasePrivacy`);
  folders only through the Storage Access Framework; only local files are
  played; remote playlist entries are rejected; no network dependencies.
