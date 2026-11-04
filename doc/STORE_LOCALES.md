# Store listing locales

The store listing lives in [`fastlane/metadata/android/`](../fastlane/metadata/android/),
one folder per locale. F-Droid reads it from the repository; Google Play's
`supply` (fastlane) and the Play Console use the same files.

## Policy

- **Source language:** English in `en-US/`. Edit only these files by hand.
- **Other locales:** machine-translated from `en-US/` with
  `python3 scripts/mt_store_listings.py` ([L10N_MT_CLOUD.md](L10N_MT_CLOUD.md)).
  The title is a name and is copied unchanged. Review the main languages.
- **Images:** only in `en-US/images/` (`python3 scripts/make_store_images.py`
  from `assets/icon/` and `doc/images/tutorial/`). Stores fall back to them in
  every locale.
- **Fallback:** Google Play, F-Droid and Accrescent show the English listing
  when a locale has no translation.

## Files per locale

| File | Play Console | Limit |
|------|--------------|-------|
| `title.txt` | App name | 30 chars |
| `short_description.txt` | Short description | 80 chars |
| `full_description.txt` | Full description | 4000 chars |
| `changelogs/<versionCode>.txt` | What's new | 500 chars |
| `images/icon.png` | App icon | 512×512, 32-bit PNG |
| `images/featureGraphic.png` | Feature graphic | 1024×500 |
| `images/phoneScreenshots/*.png` | Phone screenshots | long side ≤ 2× short side |

`python3 scripts/mt_store_listings.py --check` reports text over a limit.
The privacy policy URL is entered once in the Play Console:
`https://github.com/r-e-t-r-o-p-l-a-y-e-r/retroplayer/blob/main/PRIVACY.md`.

## App locale → store folder

In-app locales are the `app/src/main/res/values-<code>/strings_arb.xml`
folders. Folder names follow Google Play's language codes; `LOCALES` in
`scripts/mt_store_listings.py` is the full mapping. The ones that differ from
the app code:

| App code | Store folder | Notes |
|----------|--------------|-------|
| `en` | `en-US` | Source |
| `de`, `fr`, `es`, `it`, … | `de-DE`, `fr-FR`, `es-ES`, `it-IT`, … | Play requires the region |
| `he` | `iw-IL` | Play still uses the old code |
| `nb` | `no-NO` | Norwegian Bokmål |
| `pt` | `pt-PT` | |
| `zh` | `zh-CN` | Simplified Chinese |
| `bn` | `bn-BD` | |
| `bs`, `ga`, `mt` | same | Not a Play listing language; F-Droid only |

When adding an app locale, add it to `LOCALES` and run the script for it.
