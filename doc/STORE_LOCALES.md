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

## Languages and store folders

In-app locales are the `app/src/main/res/values-<code>/strings_arb.xml`
folders (`values/` is English). Store folders follow Google Play's language
codes, which add a region for many languages and use `iw` for Hebrew and `no`
for Norwegian. `LOCALES` in `scripts/mt_store_listings.py` is the same mapping
in code.

| Language | App code | Store folder | On Google Play |
|----------|----------|--------------|----------------|
| Albanian | `sq` | `sq` | yes |
| Arabic | `ar` | `ar` | yes |
| Bengali | `bn` | `bn-BD` | yes |
| Bosnian | `bs` | `bs` | no, F-Droid only |
| Bulgarian | `bg` | `bg` | yes |
| Catalan | `ca` | `ca` | yes |
| Chinese (Simplified) | `zh` | `zh-CN` | yes |
| Croatian | `hr` | `hr` | yes |
| Czech | `cs` | `cs-CZ` | yes |
| Danish | `da` | `da-DK` | yes |
| Dutch | `nl` | `nl-NL` | yes |
| English (US) | `en` | `en-US` | yes (source) |
| Estonian | `et` | `et` | yes |
| Finnish | `fi` | `fi-FI` | yes |
| French | `fr` | `fr-FR` | yes |
| German | `de` | `de-DE` | yes |
| Greek | `el` | `el-GR` | yes |
| Hebrew | `he` | `iw-IL` | yes |
| Hindi | `hi` | `hi-IN` | yes |
| Hungarian | `hu` | `hu-HU` | yes |
| Icelandic | `is` | `is-IS` | yes |
| Indonesian | `id` | `id` | yes |
| Irish | `ga` | `ga` | no, F-Droid only |
| Italian | `it` | `it-IT` | yes |
| Japanese | `ja` | `ja-JP` | yes |
| Korean | `ko` | `ko-KR` | yes |
| Latvian | `lv` | `lv` | yes |
| Lithuanian | `lt` | `lt` | yes |
| Macedonian | `mk` | `mk-MK` | yes |
| Maltese | `mt` | `mt` | no, F-Droid only |
| Norwegian Bokmål | `nb` | `no-NO` | yes |
| Persian | `fa` | `fa` | yes |
| Polish | `pl` | `pl-PL` | yes |
| Portuguese (Portugal) | `pt` | `pt-PT` | yes |
| Romanian | `ro` | `ro` | yes |
| Russian | `ru` | `ru-RU` | yes |
| Serbian | `sr` | `sr` | yes |
| Slovak | `sk` | `sk` | yes |
| Slovenian | `sl` | `sl` | yes |
| Spanish | `es` | `es-ES` | yes |
| Swedish | `sv` | `sv-SE` | yes |
| Thai | `th` | `th` | yes |
| Turkish | `tr` | `tr-TR` | yes |
| Ukrainian | `uk` | `uk` | yes |
| Urdu | `ur` | `ur` | yes |
| Vietnamese | `vi` | `vi` | yes |

When adding an app locale, add it to `LOCALES` and to this table, then run the
script for it.
