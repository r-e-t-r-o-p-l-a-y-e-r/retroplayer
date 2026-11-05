# Store listing locales

The store listing lives in [`fastlane/metadata/android/`](../fastlane/metadata/android/),
one folder per locale (fastlane layout). F-Droid reads it from the repository.

## Policy

- **Source language:** English in `en-US/`. Edit only these files by hand.
- **Other locales:** machine-translated from `en-US/` with
  `python3 scripts/mt_store_listings.py` ([L10N_MT_CLOUD.md](L10N_MT_CLOUD.md)).
  The title is a name and is copied unchanged. Review the main languages.
- **Images:** only in `en-US/images/` (`python3 scripts/make_store_images.py`
  from `assets/icon/` and `doc/images/tutorial/`). Stores fall back to them in
  every locale.
- **Fallback:** F-Droid shows the English listing when a locale has no
  translation.

## Files per locale

| File | Shown as | Limit |
|------|----------|-------|
| `title.txt` | App name | 30 chars |
| `short_description.txt` | Short description | 80 chars |
| `full_description.txt` | Full description | 4000 chars |
| `changelogs/<versionCode>.txt` | What's new | 500 chars |
| `images/icon.png` | App icon | 512×512, 32-bit PNG |
| `images/featureGraphic.png` | Feature graphic | 1024×500 |
| `images/phoneScreenshots/*.png` | Phone screenshots | long side ≤ 2× short side |

`python3 scripts/mt_store_listings.py --check` reports text over a limit (the
common fastlane limits, which F-Droid also applies).

## Languages and store folders

In-app locales are the `app/src/main/res/values-<code>/strings_arb.xml`
folders (`values/` is English). Store folders use fastlane's language codes,
which add a region for many languages and use `iw` for Hebrew and `no` for
Norwegian. `LOCALES` in `scripts/mt_store_listings.py` is the same mapping
in code.

| Language | App code | Store folder |
|----------|----------|--------------|
| Albanian | `sq` | `sq` |
| Arabic | `ar` | `ar` |
| Bengali | `bn` | `bn-BD` |
| Bosnian | `bs` | `bs` |
| Bulgarian | `bg` | `bg` |
| Catalan | `ca` | `ca` |
| Chinese (Simplified) | `zh` | `zh-CN` |
| Croatian | `hr` | `hr` |
| Czech | `cs` | `cs-CZ` |
| Danish | `da` | `da-DK` |
| Dutch | `nl` | `nl-NL` |
| English (US, source) | `en` | `en-US` |
| Estonian | `et` | `et` |
| Finnish | `fi` | `fi-FI` |
| French | `fr` | `fr-FR` |
| German | `de` | `de-DE` |
| Greek | `el` | `el-GR` |
| Hebrew | `he` | `iw-IL` |
| Hindi | `hi` | `hi-IN` |
| Hungarian | `hu` | `hu-HU` |
| Icelandic | `is` | `is-IS` |
| Indonesian | `id` | `id` |
| Irish | `ga` | `ga` |
| Italian | `it` | `it-IT` |
| Japanese | `ja` | `ja-JP` |
| Korean | `ko` | `ko-KR` |
| Latvian | `lv` | `lv` |
| Lithuanian | `lt` | `lt` |
| Macedonian | `mk` | `mk-MK` |
| Maltese | `mt` | `mt` |
| Norwegian Bokmål | `nb` | `no-NO` |
| Persian | `fa` | `fa` |
| Polish | `pl` | `pl-PL` |
| Portuguese (Portugal) | `pt` | `pt-PT` |
| Romanian | `ro` | `ro` |
| Russian | `ru` | `ru-RU` |
| Serbian | `sr` | `sr` |
| Slovak | `sk` | `sk` |
| Slovenian | `sl` | `sl` |
| Spanish | `es` | `es-ES` |
| Swedish | `sv` | `sv-SE` |
| Thai | `th` | `th` |
| Turkish | `tr` | `tr-TR` |
| Ukrainian | `uk` | `uk` |
| Urdu | `ur` | `ur` |
| Vietnamese | `vi` | `vi` |

When adding an app locale, add it to `LOCALES` and to this table, then run the
script for it.
