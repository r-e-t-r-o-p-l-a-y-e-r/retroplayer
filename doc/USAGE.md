# Retro Player — user guide

Retro Player plays **music and audiobooks from folders on your device**. It does not upload your files, stream from the internet, or change your audio files on disk (except playlists you create inside the app).

Screenshots in this guide: [`images/tutorial/`](images/tutorial/).

---

## Getting started

### First launch

When you open the app for the first time, the library is empty. Add at least one **library folder** (a directory that contains your audio files or subfolders).

### Add a library folder

1. Open **Library**.
2. Tap **Add folder** (floating button on phone, or **Ctrl+O** on desktop Linux).
3. In the system folder picker, choose a folder (for example `Music`, an audiobook collection, or an SD card directory).
4. Wait while the app scans. Folders and albums appear as tags are read; the list fills in gradually without losing your scroll position.

![Library with folders](images/tutorial/01-library.png)

**Android:** You only get access to folders you pick in the system dialog — that is normal.

**Remove a library root:** On the library root screen, swipe a source row to remove it from the app (your files on disk are not deleted). Playback stops if it was playing from that tree.

---

## Browse your collection

The library works like a **file browser**:

- Tap a **folder** to open it.
- **Breadcrumbs** at the top show where you are; tap a segment to jump to that parent folder. When you go back up, the list returns to the same scroll position as when you entered the folder.
- At the **library root**, you see your added sources and any **favorite folders** (starred shortcuts).
- **Swipe right** on a folder to add or remove it from favorites (favorites are links, not copies of files).
- Long **A–Z** lists show an index bar on the right for quick jumps.

**Album rows:** Tracks in the same folder are often grouped into one **album** (by tags or folder). Tap the album to see tracks; tap **Play** on a row to start that album or folder.

**Playlists on disk:** `.m3u` / `.m3u8` files in a folder appear as playlist entries. They are read-only; the app does not edit those files.

---

## Play music or audiobooks

- Tap **▶** on a folder, album, or playlist row, or tap a **track** in an album view.
- Use **Space** on desktop when a library row is selected to start playback.
- Playback is **gapless** within an album or queue where the format allows it.
- The app **remembers position** per album, folder, or playlist. After you fully quit and reopen, press **Play** to continue where you left off (nothing auto-plays on startup).

![Mini player](images/tutorial/02-mini-player.png)

---

## Player controls

### Mini player and expanded player

- A **mini player** sits above the library while something is loaded.
- **Swipe up** on the handle or use the expand control in the app bar to open the full player sheet.
- **Swipe down**, tap collapse, or **Ctrl+↓** (desktop) to show more of the library again.

![Expanded player](images/tutorial/03-expanded-player.png)

### While playing

| Action | Phone / touch | Linux desktop |
|--------|----------------|---------------|
| Play / pause | Button or notification | **Ctrl+P** or button |
| Previous / next track | Buttons or lock screen | **Ctrl+←** / **Ctrl+→** |
| Seek | Progress bar | Drag progress bar |
| Skip ~15 s | **−15** / **+15** beside the art, or double-tap left/right on the art (expanded) | **Ctrl+Shift+←** / **Ctrl+Shift+→** |
| Playback speed | Speed control (audiobooks) | Same (0.5×–2.0×; saved per item) |

Background playback continues with the screen off. Use the **notification** (Android) or **system media keys / MPRIS** (Linux) to control playback. Fully closing the app from recents stops playback and saves position.

---

## Album and track views

Open an album from the library to see its track list in tag order.

- Tap a track to play from that track.
- Tap **album art or title** in the player to **find the current track** in the library: the player collapses, the app opens the right folder or album, and highlights the playing row.

![Album detail](images/tutorial/04-album-detail.png)

---

## Queue and playlists

- Open the **queue** from the library app bar (**Ctrl+N** on desktop) to build a temporary play order.
- Add tracks, reorder with long-press drag, swipe to remove rows, or clear the queue (with confirmation).
- Tap a row in the queue to start playback from that track.
- **Save playlist** asks for a name and a folder inside one of your library folders, then writes a new playlist file there. Only playlists the app created can be edited or deleted; playlist files you copied in yourself stay read-only in the app.

![Playlist](images/tutorial/05-playlist.png)

---

## Back navigation

Behavior is the same on Android (back gesture) and desktop (**←** in the app bar, **Backspace**, or **Alt+←**):

1. Close Settings (or a Settings subpage) if open.
2. If the player is **expanded**, collapse it first.
3. If an **album or playlist page** is open, close it.
4. If you are **inside a folder**, go up one level (scroll position on the parent is restored).
5. On the **library root**, back does not exit the app (use the system app switcher to quit). On Android, swiping the app away in recents stops audio.

---

## Settings

Open **Settings** from the app bar (**Ctrl+,** on desktop).

- **Appearance** — light, dark, or follow system.
- **Language** — app UI language (many locales available).
- **Equalizer** — presets and bands where supported on your device.
- **Data & storage** — where the database lives; library roots; reset options.
- **About** — version and open-source licenses.

![Settings](images/tutorial/06-settings.png)

**Reset database** clears playback state, favorites, browse position, theme, language, and equalizer settings. You can keep listed library folders or remove everything and start with an empty library. **Your audio files on disk are never deleted.**

---

## Native Android app

The native Android app ([`android-native/`](../android-native/README.md))
works as described above, with no keyboard shortcuts. This section covers
what it does differently or in addition.

### Adding folders

Retro Player asks for no storage permission. **Add folder** opens the system
folder picker; tap **Use this folder** and **Allow**. The app can then read
that folder and everything below it, and nothing else. It cannot change your
files.

Long-press a library source or a favorite and drag it to change the order.
Swipe a library source to the left to remove it from the app (with a
confirmation; nothing is deleted on disk).

### Swipes and the A–Z bar

- **Swipe right** on a folder: add or remove it as a favorite.
- **Swipe left** on a folder, favorite, playlist, album or track: add it to
  the queue. The app says how many tracks were added.
- The **A–Z bar** on long lists covers the whole alphabet, plus **#** for
  names starting with a digit and **•** for other characters. Tap a letter or
  slide along the bar; a letter without entries jumps to the next one.

### Saving playlists (write access)

Folders are added read-only. The first time you save a playlist into a library
folder, the system folder picker opens at that folder: confirm it to give
Retro Player write access there. If you pick a different folder or cancel,
nothing is saved and everything else keeps working. Retro Player only ever
writes playlist files it created itself.

### Album track order

In an album, the sort button switches between **tag order**, **file name**
and **title**. The choice is kept per album. When some tracks have no track
number, the album uses file name order; choosing tag order then asks first.

### Chapters

M4B and M4A audiobooks with chapters show chapter marks on the progress bar
and the current chapter under the title. Tap it for the chapter list. Previous
and next chapter buttons appear in the player and in the notification.

### Headphones

**Settings → Headphones**:

- **Rewind on resume** (on by default): after a pause of at least a minute,
  tracks longer than 20 minutes start a few seconds earlier (5, 10, 15 or
  30 s), so you do not lose the thread.
- **Resume when headphones reconnect** (off by default): when playback paused
  because headphones were disconnected, it continues once they are connected
  again within 10 minutes. This works for wired, USB and Bluetooth devices,
  including car audio over Bluetooth.

### Android Auto

In the car, Retro Player shows your library sources (with their folders,
albums, playlists and tracks), your favorites and the queue. Playing something
there works as on the phone, including resume.

### Home-screen widget

Long-press the home screen, open **Widgets** and add **Retro Player**. The
small widget shows the title and play/pause; larger sizes add the cover,
±15 s jumps and previous/next. Tap the widget to open the app.

---

## Supported formats

| Format | Typical use |
|--------|-------------|
| MP3, FLAC, WAV | Music and audiobooks |
| M4A, M4B | AAC / audiobooks (unencrypted) |
| OGG | Android and Linux only (not on iOS) |

The app plays **local files only**. Remote URLs in playlist files are ignored.

---

## Linux installation notes

- Install **libmpv** on your system if you run the release tarball (Flatpak bundles its own dependencies when available).
- Run the `retroplayer` binary from the release bundle, or install the menu entry with the project’s `install-linux-desktop.sh` if you build from source.
- If the **taskbar icon** looks wrong after an update, fully quit the app and launch again; the app installs desktop metadata under your user data directory on startup.

---

## Privacy

Release builds are built **without Internet access** for app features: no ads, analytics, or in-app purchases. The app reads only folders you add. Details are in the project [README](../README.md#privacy).

---

## Something wrong?

When the public GitHub repository is linked from the store listing, report bugs there with your **platform** (Android / Linux), **steps**, and what you expected. Security issues: see [SECURITY.md](../SECURITY.md).

---

## Quick reference (desktop Linux)

| Keys | Action |
|------|--------|
| Ctrl+O | Add library folder |
| Ctrl+N | Queue / new playlist flow |
| Ctrl+, | Settings |
| Ctrl+P | Play / pause |
| Ctrl+← / Ctrl+→ | Previous / next track |
| Ctrl+Shift+← / Ctrl+Shift+→ | Seek back / forward |
| Ctrl+↑ / Ctrl+↓ | Expand / collapse player |
| Alt+← / Backspace | Back (same rules as above) |
| Delete | Remove selected library root or deletable playlist (with confirmation) |

Shortcuts are disabled while you type in a text field.

---

## For maintainers (screenshots)

Tutorial PNGs live in [`images/tutorial/`](images/tutorial/). Regenerate with [`scripts/capture-tutorial-screenshots.sh`](../scripts/capture-tutorial-screenshots.sh) or [`scripts/capture-tutorial-screenshots-adb.sh`](../scripts/capture-tutorial-screenshots-adb.sh). See [`images/tutorial/README.md`](images/tutorial/README.md).
