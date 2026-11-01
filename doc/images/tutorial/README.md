# Tutorial screenshots

PNG files referenced from [`doc/USAGE.md`](../../USAGE.md):

| File | Scene |
|------|--------|
| `01-library.png` | Library with at least one folder/album |
| `02-mini-player.png` | Collapsed mini player while playing |
| `03-expanded-player.png` | Expanded player sheet |
| `04-album-detail.png` | Album track list |
| `05-playlist.png` | Playlist track list |
| `06-settings.png` | Settings overview |

**Recommended (real device / emulator, store-ready):**

```bash
./scripts/capture-tutorial-screenshots-adb.sh
```

**Quick draft (widget test, readable text but not pixel-perfect):**

```bash
./scripts/capture-tutorial-screenshots.sh
```

Requires sample audio on the emulator ([`scripts/push-sample-audio-to-emulator.sh`](../../scripts/push-sample-audio-to-emulator.sh)). Commit PNGs after review for stable GitHub rendering in USAGE.md.
