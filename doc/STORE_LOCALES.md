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
Norwegian. Regional variants use Android's resource qualifiers (`pt-rBR`,
`b+es+419`, `b+zh+Hant`); `locales_config.xml` lists them as language tags
(`pt-BR`, `es-419`, `zh-Hant`), which `TranslationsTest` checks. `LOCALES` in `scripts/mt_store_listings.py` is the same mapping
in code.

| Language | App code | Store folder |
|----------|----------|--------------|
| Afrikaans | `af` | `af` |
| Albanian | `sq` | `sq` |
| Amharic | `am` | `am` |
| Arabic | `ar` | `ar` |
| Aragonese | `an` | `an` |
| Armenian | `hy` | `hy-AM` |
| Assamese | `as` | `as` |
| Aymara | `ay` | `ay` |
| Azerbaijani | `az` | `az-AZ` |
| Bashkir | `ba` | `ba` |
| Basque | `eu` | `eu-ES` |
| Belarusian | `be` | `be` |
| Bengali | `bn` | `bn-BD` |
| Bosnian | `bs` | `bs` |
| Breton | `br` | `br` |
| Bulgarian | `bg` | `bg` |
| Burmese | `my` | `my-MM` |
| Catalan | `ca` | `ca` |
| Chinese (Simplified) | `zh` | `zh-CN` |
| Chinese (Traditional) | `b+zh+Hant` | `zh-TW` |
| Croatian | `hr` | `hr` |
| Czech | `cs` | `cs-CZ` |
| Danish | `da` | `da-DK` |
| Dutch | `nl` | `nl-NL` |
| English (US, source) | `en` | `en-US` |
| Esperanto | `eo` | `eo` |
| Estonian | `et` | `et` |
| Filipino (Tagalog) | `fil` | `fil` |
| Finnish | `fi` | `fi-FI` |
| French | `fr` | `fr-FR` |
| Galician | `gl` | `gl-ES` |
| Georgian | `ka` | `ka-GE` |
| German | `de` | `de-DE` |
| Greek | `el` | `el-GR` |
| Guarani | `gn` | `gn` |
| Gujarati | `gu` | `gu` |
| Haitian Creole | `ht` | `ht` |
| Hausa | `ha` | `ha` |
| Hebrew | `he` | `iw-IL` |
| Hindi | `hi` | `hi-IN` |
| Hungarian | `hu` | `hu-HU` |
| Icelandic | `is` | `is-IS` |
| Igbo | `ig` | `ig` |
| Indonesian | `id` | `id` |
| Irish | `ga` | `ga` |
| Italian | `it` | `it-IT` |
| Japanese | `ja` | `ja-JP` |
| Javanese | `jv` | `jv` |
| Kannada | `kn` | `kn-IN` |
| Kazakh | `kk` | `kk` |
| Korean | `ko` | `ko-KR` |
| Kyrgyz | `ky` | `ky-KG` |
| Latin | `la` | `la` |
| Latvian | `lv` | `lv` |
| Lingala | `ln` | `ln` |
| Lithuanian | `lt` | `lt` |
| Luxembourgish | `lb` | `lb` |
| Macedonian | `mk` | `mk-MK` |
| Malagasy | `mg` | `mg` |
| Malay | `ms` | `ms` |
| Malayalam | `ml` | `ml-IN` |
| Maltese | `mt` | `mt` |
| Maori | `mi` | `mi` |
| Marathi | `mr` | `mr-IN` |
| Mongolian | `mn` | `mn-MN` |
| Nepali | `ne` | `ne-NP` |
| Norwegian Bokmål | `nb` | `no-NO` |
| Occitan | `oc` | `oc` |
| Oromo | `om` | `om` |
| Pashto | `ps` | `ps` |
| Persian | `fa` | `fa` |
| Polish | `pl` | `pl-PL` |
| Portuguese (Brazil) | `pt-rBR` | `pt-BR` |
| Portuguese (Portugal) | `pt` | `pt-PT` |
| Punjabi | `pa` | `pa` |
| Quechua | `qu` | `qu` |
| Romanian | `ro` | `ro` |
| Russian | `ru` | `ru-RU` |
| Sanskrit | `sa` | `sa` |
| Serbian | `sr` | `sr` |
| Sesotho | `st` | `st` |
| Slovak | `sk` | `sk` |
| Slovenian | `sl` | `sl` |
| Spanish | `es` | `es-ES` |
| Spanish (Latin America) | `b+es+419` | `es-419` |
| Sundanese | `su` | `su` |
| Swahili | `sw` | `sw` |
| Swedish | `sv` | `sv-SE` |
| Tajik | `tg` | `tg` |
| Tamil | `ta` | `ta-IN` |
| Tatar | `tt` | `tt` |
| Telugu | `te` | `te-IN` |
| Thai | `th` | `th` |
| Tsonga | `ts` | `ts` |
| Tswana | `tn` | `tn` |
| Turkish | `tr` | `tr-TR` |
| Turkmen | `tk` | `tk` |
| Ukrainian | `uk` | `uk` |
| Urdu | `ur` | `ur` |
| Uzbek | `uz` | `uz` |
| Vietnamese | `vi` | `vi` |
| Welsh | `cy` | `cy` |
| Wolof | `wo` | `wo` |
| Xhosa | `xh` | `xh` |
| Yiddish | `yi` | `yi` |
| Zulu | `zu` | `zu` |

When adding an app locale, add it to `LOCALES` and to this table, then run the
script for it.
