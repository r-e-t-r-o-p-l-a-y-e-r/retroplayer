# Retro Player — user guide

Task-oriented help for music and audiobooks. Maps to use cases in [`REQUIREMENTS.md`](REQUIREMENTS.md). Store listings link here for detailed screenshots.

**Screenshots:** [`images/tutorial/`](images/tutorial/) (English UI recommended for consistency). Regenerate drafts with [`scripts/capture-tutorial-screenshots.sh`](../scripts/capture-tutorial-screenshots.sh) (widget test), or use [`scripts/capture-tutorial-screenshots-adb.sh`](../scripts/capture-tutorial-screenshots-adb.sh) on a device for Play Store–quality PNGs.

---

## 1. Add your music or audiobooks

1. Open the app → **Library**.
2. Tap **Add folder** (or use the menu) and pick a directory on your device.
3. Wait for scanning to finish. Albums and folders appear grouped by how files are organized on disk.

![Library with folders](images/tutorial/01-library.png)

*Regenerate drafts: `./scripts/capture-tutorial-screenshots.sh`. For store listings use `./scripts/capture-tutorial-screenshots-adb.sh` on a phone or emulator.*

---

## 2. Play an album or folder

1. Tap an album or folder in the library.
2. Tap a track, or use **Play all** where shown.
3. Playback continues in the background; use notification or lock-screen controls to pause, skip, or seek.

![Now playing / mini player](images/tutorial/02-mini-player.png)

---

## 3. Mini player and full player

- **Swipe up** on the handle bar at the bottom to expand the player sheet.
- **Tap the handle** or the app bar control to expand or collapse.
- In the expanded view: album art, seek bar, shuffle/repeat (if available), speed control for audiobooks, and queue context.

![Expanded player](images/tutorial/03-expanded-player.png)

---

## 4. Album and track details

- From the library, open an album to see its track list and metadata.
- Use the settings icon on album view for app settings (same as library settings).
- Tap track title area in the mini player to **locate** the current track in the library.

![Album detail](images/tutorial/04-album-detail.png)

*Album detail golden: optional follow-up (open an album from the library list).*

---

## 5. Playlists

- Create playlists from the library menu; add tracks from album views.
- Playlist files are stored in app data — your original audio files are not moved or renamed.

![Playlist](images/tutorial/05-playlist.png)

*Playlist screenshot: add when golden navigation covers playlist creation (optional for v1).*

---

## 6. Settings

- **Theme**, **language**, **equalizer**, **data & storage** (library roots, cache paths), and **About** (version, licenses).
- On Linux, the About / data storage section explains desktop icon installation if the taskbar icon looks wrong after an update.

![Settings](images/tutorial/06-settings.png)

---

## 7. Android: storage permission

When adding a folder on Android, the system folder picker grants access only to paths you select. Use **Music** or an SD card folder you control.

---

## 8. Linux: install and desktop icon

1. Extract the release bundle or install via your package method (see project README).
2. Ensure **libmpv** is installed on your system unless you use a Flatpak that bundles it.
3. If the panel icon is generic after an update, run `scripts/install-linux-desktop.sh` from a source checkout, or rely on automatic install on app startup.

---

## Privacy reminder

Release builds do not use the Internet for app features. Your files stay on your device. See the root [README.md](../README.md#privacy).

---

## Reporting problems

Once the public repository is hosted, open an issue with platform (Android/Linux), steps, and expected vs actual behavior. See [`SECURITY.md`](../SECURITY.md) for security reports.
