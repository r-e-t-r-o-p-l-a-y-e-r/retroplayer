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

The last two columns say where the current texts came from:

- **App strings** (`strings_arb.xml`): "Flutter, DeepL" means the strings were
  taken over from the Flutter app (the service used there is not recorded) and
  keys added since then went through DeepL. The other languages were
  translated completely with `scripts/mt_android_strings.py`, which picks
  DeepL when it supports the language and Google Cloud otherwise.
- **Store texts** (title, descriptions, changelog): the languages that existed
  before the 0.1.1 store rewrite went through DeepL; the 60 added with it went
  through Google Cloud to save DeepL's monthly quota (Aragonese through DeepL,
  because Google has no Aragonese). German is written by hand, and the
  Slovenian DeepL output was reviewed and corrected. The 18 languages added
  for 0.1.2 went through Google Cloud for both, since DeepL has none of them.

Not translated, because neither DeepL nor the Google Cloud Translation API
offers them:

| Language | Code | Spoken in |
| --- | --- | --- |
| Cornish | `kw` | [Cornwall](https://mapy.cz/?q=Cornwall), United Kingdom |
| Faroese | `fo` | [Faroe Islands](https://mapy.cz/?q=Faroe%20Islands) (Denmark) |
| Interlingua | `ia` | nowhere in particular: constructed auxiliary language |
| Kalaallisut (Greenlandic) | `kl` | [Greenland](https://mapy.cz/?q=Greenland) (Denmark) |
| Kashmiri | `ks` | [Kashmir Valley](https://mapy.cz/?q=Kashmir%20Valley), India; also Pakistan-administered Kashmir |
| Kikuyu | `ki` | [Central Kenya](https://mapy.cz/?q=Nyeri), around Mount Kenya and Nairobi |
| Luba-Katanga | `lu` | [Katanga](https://mapy.cz/?q=Lubumbashi), DR Congo |
| Manx | `gv` | [Isle of Man](https://mapy.cz/?q=Isle%20of%20Man) |
| North Ndebele | `nd` | [Matabeleland](https://mapy.cz/?q=Bulawayo), Zimbabwe |
| Northern Sami | `se` | [Sápmi](https://mapy.cz/?q=Kautokeino): northern Norway, Sweden and Finland |
| Norwegian Nynorsk | `nn` | [Western Norway](https://mapy.cz/?q=Vestland) (written standard, mostly there) |
| Ossetic | `os` | [North Ossetia](https://mapy.cz/?q=Vladikavkaz) (Russia) and [South Ossetia](https://mapy.cz/?q=Tskhinvali) (Georgia) |
| Romansh | `rm` | [Graubünden](https://mapy.cz/?q=Graub%C3%BCnden), Switzerland |
| Sichuan Yi (Nuosu) | `ii` | [Liangshan](https://mapy.cz/?q=Xichang), Sichuan, China |
| Tibetan | `bo` | [Tibet](https://mapy.cz/?q=Lhasa), China; also Nepal, Bhutan and northern India |

`mt_store_listings.py` uses DeepL whenever `DEEPL_AUTH_KEY` is set; run it with
`DEEPL_AUTH_KEY=` (empty) to force Google Cloud and keep this split. Exclude
`--locale de` when retranslating, or the hand-written German is overwritten.

| Language | App code | Store folder | App strings | Store texts |
|----------|----------|--------------|-------------|-------------|
| Afrikaans | `af` | `af` | DeepL | Google |
| Akan (Twi) | `ak` | `ak` | Google | Google |
| Albanian | `sq` | `sq` | Flutter, DeepL | DeepL |
| Amharic | `am` | `am` | Google | Google |
| Arabic | `ar` | `ar` | Flutter, DeepL | DeepL |
| Aragonese | `an` | `an` | DeepL | DeepL |
| Armenian | `hy` | `hy-AM` | DeepL | Google |
| Assamese | `as` | `as` | DeepL | Google |
| Aymara | `ay` | `ay` | DeepL | Google |
| Azerbaijani | `az` | `az-AZ` | DeepL | Google |
| Bambara | `bm` | `bm` | Google | Google |
| Bashkir | `ba` | `ba` | DeepL | Google |
| Basque | `eu` | `eu-ES` | DeepL | Google |
| Belarusian | `be` | `be` | DeepL | Google |
| Bengali | `bn` | `bn-BD` | Flutter, DeepL | DeepL |
| Bosnian | `bs` | `bs` | Flutter, DeepL | DeepL |
| Breton | `br` | `br` | DeepL | Google |
| Bulgarian | `bg` | `bg` | Flutter, DeepL | DeepL |
| Burmese | `my` | `my-MM` | DeepL | Google |
| Catalan | `ca` | `ca` | Flutter, DeepL | DeepL |
| Chinese (Simplified) | `zh` | `zh-CN` | Flutter, DeepL | DeepL |
| Chinese (Traditional) | `b+zh+Hant` | `zh-TW` | DeepL | Google |
| Croatian | `hr` | `hr` | Flutter, DeepL | DeepL |
| Czech | `cs` | `cs-CZ` | Flutter, DeepL | DeepL |
| Danish | `da` | `da-DK` | Flutter, DeepL | DeepL |
| Dutch | `nl` | `nl-NL` | Flutter, DeepL | DeepL |
| Dzongkha | `dz` | `dz` | Google | Google |
| English (US, source) | `en` | `en-US` | source | source |
| Esperanto | `eo` | `eo` | DeepL | Google |
| Estonian | `et` | `et` | Flutter, DeepL | DeepL |
| Ewe | `ee` | `ee` | Google | Google |
| Filipino (Tagalog) | `fil` | `fil` | DeepL | Google |
| Finnish | `fi` | `fi-FI` | Flutter, DeepL | DeepL |
| French | `fr` | `fr-FR` | Flutter, DeepL | DeepL |
| Fula | `ff` | `ff` | Google | Google |
| Galician | `gl` | `gl-ES` | DeepL | Google |
| Ganda (Luganda) | `lg` | `lg` | Google | Google |
| Georgian | `ka` | `ka-GE` | DeepL | Google |
| German | `de` | `de-DE` | Flutter, DeepL | by hand |
| Greek | `el` | `el-GR` | Flutter, DeepL | DeepL |
| Guarani | `gn` | `gn` | DeepL | Google |
| Gujarati | `gu` | `gu` | DeepL | Google |
| Haitian Creole | `ht` | `ht` | DeepL | Google |
| Hausa | `ha` | `ha` | DeepL | Google |
| Hebrew | `he` | `iw-IL` | Flutter, DeepL | DeepL |
| Hindi | `hi` | `hi-IN` | Flutter, DeepL | DeepL |
| Hungarian | `hu` | `hu-HU` | Flutter, DeepL | DeepL |
| Icelandic | `is` | `is-IS` | Flutter, DeepL | DeepL |
| Igbo | `ig` | `ig` | DeepL | Google |
| Indonesian | `id` | `id` | Flutter, DeepL | DeepL |
| Irish | `ga` | `ga` | Flutter, DeepL | DeepL |
| Italian | `it` | `it-IT` | Flutter, DeepL | DeepL |
| Japanese | `ja` | `ja-JP` | Flutter, DeepL | DeepL |
| Javanese | `jv` | `jv` | DeepL | Google |
| Kannada | `kn` | `kn-IN` | Google | Google |
| Kazakh | `kk` | `kk` | DeepL | Google |
| Khmer | `km` | `km-KH` | Google | Google |
| Kinyarwanda | `rw` | `rw` | Google | Google |
| Korean | `ko` | `ko-KR` | Flutter, DeepL | DeepL |
| Kyrgyz | `ky` | `ky-KG` | DeepL | Google |
| Lao | `lo` | `lo-LA` | Google | Google |
| Latin | `la` | `la` | DeepL | Google |
| Latvian | `lv` | `lv` | Flutter, DeepL | DeepL |
| Lingala | `ln` | `ln` | DeepL | Google |
| Lithuanian | `lt` | `lt` | Flutter, DeepL | DeepL |
| Luxembourgish | `lb` | `lb` | DeepL | Google |
| Macedonian | `mk` | `mk-MK` | Flutter, DeepL | DeepL |
| Malagasy | `mg` | `mg` | DeepL | Google |
| Malay | `ms` | `ms` | DeepL | Google |
| Malayalam | `ml` | `ml-IN` | DeepL | Google |
| Maltese | `mt` | `mt` | Flutter, DeepL | DeepL |
| Maori | `mi` | `mi` | DeepL | Google |
| Marathi | `mr` | `mr-IN` | DeepL | Google |
| Mongolian | `mn` | `mn-MN` | DeepL | Google |
| Nepali | `ne` | `ne-NP` | DeepL | Google |
| Norwegian Bokmål | `nb` | `no-NO` | Flutter, DeepL | DeepL |
| Occitan | `oc` | `oc` | DeepL | Google |
| Odia | `or` | `or` | Google | Google |
| Oromo | `om` | `om` | DeepL | Google |
| Pashto | `ps` | `ps` | DeepL | Google |
| Persian | `fa` | `fa` | Flutter, DeepL | DeepL |
| Polish | `pl` | `pl-PL` | Flutter, DeepL | DeepL |
| Portuguese (Brazil) | `pt-rBR` | `pt-BR` | DeepL | Google |
| Portuguese (Portugal) | `pt` | `pt-PT` | Flutter, DeepL | DeepL |
| Punjabi | `pa` | `pa` | DeepL | Google |
| Quechua | `qu` | `qu` | DeepL | Google |
| Romanian | `ro` | `ro` | Flutter, DeepL | DeepL |
| Rundi | `rn` | `rn` | Google | Google |
| Russian | `ru` | `ru-RU` | Flutter, DeepL | DeepL |
| Sango | `sg` | `sg` | Google | Google |
| Sanskrit | `sa` | `sa` | DeepL | Google |
| Scottish Gaelic | `gd` | `gd` | Google | Google |
| Serbian | `sr` | `sr` | Flutter, DeepL | DeepL |
| Sesotho | `st` | `st` | DeepL | Google |
| Shona | `sn` | `sn` | Google | Google |
| Sinhala | `si` | `si-LK` | Google | Google |
| Slovak | `sk` | `sk` | Flutter, DeepL | DeepL |
| Slovenian | `sl` | `sl` | Flutter, DeepL | DeepL, reviewed |
| Somali | `so` | `so` | Google | Google |
| Spanish | `es` | `es-ES` | Flutter, DeepL | DeepL |
| Spanish (Latin America) | `b+es+419` | `es-419` | DeepL | Google |
| Sundanese | `su` | `su` | DeepL | Google |
| Swahili | `sw` | `sw` | DeepL | Google |
| Swedish | `sv` | `sv-SE` | Flutter, DeepL | DeepL |
| Tajik | `tg` | `tg` | DeepL | Google |
| Tamil | `ta` | `ta-IN` | DeepL | Google |
| Tatar | `tt` | `tt` | DeepL | Google |
| Telugu | `te` | `te-IN` | DeepL | Google |
| Thai | `th` | `th` | Flutter, DeepL | DeepL |
| Tigrinya | `ti` | `ti` | Google | Google |
| Tsonga | `ts` | `ts` | DeepL | Google |
| Tswana | `tn` | `tn` | DeepL | Google |
| Turkish | `tr` | `tr-TR` | Flutter, DeepL | DeepL |
| Turkmen | `tk` | `tk` | DeepL | Google |
| Ukrainian | `uk` | `uk` | Flutter, DeepL | DeepL |
| Urdu | `ur` | `ur` | Flutter, DeepL | DeepL |
| Uzbek | `uz` | `uz` | DeepL | Google |
| Vietnamese | `vi` | `vi` | Flutter, DeepL | DeepL |
| Welsh | `cy` | `cy` | DeepL | Google |
| Wolof | `wo` | `wo` | DeepL | Google |
| Xhosa | `xh` | `xh` | DeepL | Google |
| Yiddish | `yi` | `yi` | DeepL | Google |
| Yoruba | `yo` | `yo` | Google | Google |
| Zulu | `zu` | `zu` | DeepL | Google |

When adding an app locale, add it to `LOCALES` and to this table, then run the
script for it.
