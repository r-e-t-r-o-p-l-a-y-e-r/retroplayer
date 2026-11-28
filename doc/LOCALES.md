# Languages

The app and its store listing are translated into the same 124 languages,
listed in [Languages and store folders](#languages-and-store-folders) with
where each one is spoken. App strings: [Strings in AGENTS.md](../AGENTS.md#strings)
and [L10N_MT_CLOUD.md](L10N_MT_CLOUD.md).

## Store listing

The store listing lives in [`fastlane/metadata/android/`](../fastlane/metadata/android/),
one folder per locale (fastlane layout). F-Droid reads it from the repository.

### Policy

- **Source language:** English in `en-US/`. Edit only these files by hand.
- **Other locales:** machine-translated from `en-US/` with
  `python3 scripts/mt_store_listings.py` ([L10N_MT_CLOUD.md](L10N_MT_CLOUD.md)).
  The title is a name and is copied unchanged. Review the main languages.
- **Images:** only in `en-US/images/` (`python3 scripts/make_store_images.py`
  from `assets/icon/` and `doc/images/tutorial/`). Stores fall back to them in
  every locale.
- **Fallback:** F-Droid shows the English listing when a locale has no
  translation.

### Files per locale

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

The App strings and Store texts columns say where the current texts came from:

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

| Language | App code | Store folder | App strings | Store texts | Spoken in |
|----------|----------|--------------|-------------|-------------|-----------|
| Afrikaans | `af` | `af` | DeepL | Google | [South Africa](https://mapy.cz/?q=South%20Africa), Namibia |
| Akan (Twi) | `ak` | `ak` | Google | Google | [Ghana](https://mapy.cz/?q=Ghana) (Ashanti, south and centre) |
| Albanian | `sq` | `sq` | Flutter, DeepL | DeepL | [Albania](https://mapy.cz/?q=Albania), Kosovo, North Macedonia |
| Amharic | `am` | `am` | Google | Google | [Ethiopia](https://mapy.cz/?q=Ethiopia) |
| Arabic | `ar` | `ar` | Flutter, DeepL | DeepL | [Middle East and North Africa](https://mapy.cz/?q=Cairo): Egypt, Saudi Arabia, Morocco, Iraq and others |
| Aragonese | `an` | `an` | DeepL | DeepL | [Aragon](https://mapy.cz/?q=Huesca), Spain (Pyrenean valleys) |
| Armenian | `hy` | `hy-AM` | DeepL | Google | [Armenia](https://mapy.cz/?q=Armenia) |
| Assamese | `as` | `as` | DeepL | Google | [Assam](https://mapy.cz/?q=Assam), India |
| Aymara | `ay` | `ay` | DeepL | Google | [Bolivia](https://mapy.cz/?q=Bolivia), Peru (around Lake Titicaca) |
| Azerbaijani | `az` | `az-AZ` | DeepL | Google | [Azerbaijan](https://mapy.cz/?q=Azerbaijan), northwest Iran |
| Bambara | `bm` | `bm` | Google | Google | [Mali](https://mapy.cz/?q=Mali) |
| Bashkir | `ba` | `ba` | DeepL | Google | [Bashkortostan](https://mapy.cz/?q=Ufa), Russia |
| Basque | `eu` | `eu-ES` | DeepL | Google | [Basque Country](https://mapy.cz/?q=Bilbao), Spain and France |
| Belarusian | `be` | `be` | DeepL | Google | [Belarus](https://mapy.cz/?q=Belarus) |
| Bengali | `bn` | `bn-BD` | Flutter, DeepL | DeepL | [Bangladesh](https://mapy.cz/?q=Bangladesh), West Bengal (India) |
| Bosnian | `bs` | `bs` | Flutter, DeepL | DeepL | [Bosnia and Herzegovina](https://mapy.cz/?q=Bosnia%20and%20Herzegovina) |
| Breton | `br` | `br` | DeepL | Google | [Brittany](https://mapy.cz/?q=Quimper), France |
| Bulgarian | `bg` | `bg` | Flutter, DeepL | DeepL | [Bulgaria](https://mapy.cz/?q=Bulgaria) |
| Burmese | `my` | `my-MM` | DeepL | Google | [Myanmar](https://mapy.cz/?q=Myanmar) |
| Catalan | `ca` | `ca` | Flutter, DeepL | DeepL | [Catalonia](https://mapy.cz/?q=Barcelona), Valencia and the Balearic Islands (Spain), Andorra |
| Chinese (Simplified) | `zh` | `zh-CN` | Flutter, DeepL | DeepL | [China](https://mapy.cz/?q=China), Singapore |
| Chinese (Traditional) | `b+zh+Hant` | `zh-TW` | DeepL | Google | [Taiwan](https://mapy.cz/?q=Taiwan), Hong Kong, Macau |
| Croatian | `hr` | `hr` | Flutter, DeepL | DeepL | [Croatia](https://mapy.cz/?q=Croatia), Bosnia and Herzegovina |
| Czech | `cs` | `cs-CZ` | Flutter, DeepL | DeepL | [Czechia](https://mapy.cz/?q=Czechia) |
| Danish | `da` | `da-DK` | Flutter, DeepL | DeepL | [Denmark](https://mapy.cz/?q=Denmark) |
| Dutch | `nl` | `nl-NL` | Flutter, DeepL | DeepL | [Netherlands](https://mapy.cz/?q=Netherlands), Belgium (Flanders), Suriname |
| Dzongkha | `dz` | `dz` | Google | Google | [Bhutan](https://mapy.cz/?q=Bhutan) |
| English (US, source) | `en` | `en-US` | source | source | [United States](https://mapy.cz/?q=United%20States), United Kingdom and worldwide |
| Esperanto | `eo` | `eo` | DeepL | Google | nowhere in particular: constructed international language |
| Estonian | `et` | `et` | Flutter, DeepL | DeepL | [Estonia](https://mapy.cz/?q=Estonia) |
| Ewe | `ee` | `ee` | Google | Google | [Ghana](https://mapy.cz/?q=Ghana) (Volta Region), Togo |
| Filipino (Tagalog) | `fil` | `fil` | DeepL | Google | [Philippines](https://mapy.cz/?q=Philippines) |
| Finnish | `fi` | `fi-FI` | Flutter, DeepL | DeepL | [Finland](https://mapy.cz/?q=Finland) |
| French | `fr` | `fr-FR` | Flutter, DeepL | DeepL | [France](https://mapy.cz/?q=France), Belgium, Switzerland, Canada, West and Central Africa |
| Fula | `ff` | `ff` | Google | Google | [West Africa](https://mapy.cz/?q=Senegal): Senegal, Guinea, Mali, Niger, Nigeria, Cameroon and others |
| Galician | `gl` | `gl-ES` | DeepL | Google | [Galicia](https://mapy.cz/?q=Santiago%20de%20Compostela), Spain |
| Ganda (Luganda) | `lg` | `lg` | Google | Google | [Uganda](https://mapy.cz/?q=Uganda) (Buganda, around Kampala) |
| Georgian | `ka` | `ka-GE` | DeepL | Google | [Georgia](https://mapy.cz/?q=Tbilisi) |
| German | `de` | `de-DE` | Flutter, DeepL | by hand | [Germany](https://mapy.cz/?q=Germany), Austria, Switzerland, Liechtenstein, Luxembourg |
| Greek | `el` | `el-GR` | Flutter, DeepL | DeepL | [Greece](https://mapy.cz/?q=Greece), Cyprus |
| Guarani | `gn` | `gn` | DeepL | Google | [Paraguay](https://mapy.cz/?q=Paraguay), parts of Bolivia, Argentina and Brazil |
| Gujarati | `gu` | `gu` | DeepL | Google | [Gujarat](https://mapy.cz/?q=Ahmedabad), India |
| Haitian Creole | `ht` | `ht` | DeepL | Google | [Haiti](https://mapy.cz/?q=Haiti) |
| Hausa | `ha` | `ha` | DeepL | Google | [Nigeria](https://mapy.cz/?q=Nigeria) (north), Niger |
| Hebrew | `he` | `iw-IL` | Flutter, DeepL | DeepL | [Israel](https://mapy.cz/?q=Israel) |
| Hindi | `hi` | `hi-IN` | Flutter, DeepL | DeepL | [North India](https://mapy.cz/?q=New%20Delhi) |
| Hungarian | `hu` | `hu-HU` | Flutter, DeepL | DeepL | [Hungary](https://mapy.cz/?q=Hungary), neighbouring parts of Romania, Slovakia and Serbia |
| Icelandic | `is` | `is-IS` | Flutter, DeepL | DeepL | [Iceland](https://mapy.cz/?q=Iceland) |
| Igbo | `ig` | `ig` | DeepL | Google | [Nigeria](https://mapy.cz/?q=Nigeria) (southeast) |
| Indonesian | `id` | `id` | Flutter, DeepL | DeepL | [Indonesia](https://mapy.cz/?q=Indonesia) |
| Irish | `ga` | `ga` | Flutter, DeepL | DeepL | [Ireland](https://mapy.cz/?q=Ireland) |
| Italian | `it` | `it-IT` | Flutter, DeepL | DeepL | [Italy](https://mapy.cz/?q=Italy), Switzerland (Ticino), San Marino |
| Japanese | `ja` | `ja-JP` | Flutter, DeepL | DeepL | [Japan](https://mapy.cz/?q=Japan) |
| Javanese | `jv` | `jv` | DeepL | Google | [Java](https://mapy.cz/?q=Yogyakarta), Indonesia (central and east) |
| Kannada | `kn` | `kn-IN` | Google | Google | [Karnataka](https://mapy.cz/?q=Bengaluru), India |
| Kazakh | `kk` | `kk` | DeepL | Google | [Kazakhstan](https://mapy.cz/?q=Kazakhstan) |
| Khmer | `km` | `km-KH` | Google | Google | [Cambodia](https://mapy.cz/?q=Cambodia) |
| Kinyarwanda | `rw` | `rw` | Google | Google | [Rwanda](https://mapy.cz/?q=Rwanda) |
| Korean | `ko` | `ko-KR` | Flutter, DeepL | DeepL | [South Korea](https://mapy.cz/?q=South%20Korea), North Korea |
| Kyrgyz | `ky` | `ky-KG` | DeepL | Google | [Kyrgyzstan](https://mapy.cz/?q=Kyrgyzstan) |
| Lao | `lo` | `lo-LA` | Google | Google | [Laos](https://mapy.cz/?q=Laos) |
| Latin | `la` | `la` | DeepL | Google | nowhere today: classical language, Vatican City uses it officially |
| Latvian | `lv` | `lv` | Flutter, DeepL | DeepL | [Latvia](https://mapy.cz/?q=Latvia) |
| Lingala | `ln` | `ln` | DeepL | Google | [DR Congo](https://mapy.cz/?q=Kinshasa), Republic of the Congo |
| Lithuanian | `lt` | `lt` | Flutter, DeepL | DeepL | [Lithuania](https://mapy.cz/?q=Lithuania) |
| Luxembourgish | `lb` | `lb` | DeepL | Google | [Luxembourg](https://mapy.cz/?q=Luxembourg) |
| Macedonian | `mk` | `mk-MK` | Flutter, DeepL | DeepL | [North Macedonia](https://mapy.cz/?q=North%20Macedonia) |
| Malagasy | `mg` | `mg` | DeepL | Google | [Madagascar](https://mapy.cz/?q=Madagascar) |
| Malay | `ms` | `ms` | DeepL | Google | [Malaysia](https://mapy.cz/?q=Malaysia), Brunei, Singapore |
| Malayalam | `ml` | `ml-IN` | DeepL | Google | [Kerala](https://mapy.cz/?q=Thiruvananthapuram), India |
| Maltese | `mt` | `mt` | Flutter, DeepL | DeepL | [Malta](https://mapy.cz/?q=Malta) |
| Maori | `mi` | `mi` | DeepL | Google | [New Zealand](https://mapy.cz/?q=New%20Zealand) |
| Marathi | `mr` | `mr-IN` | DeepL | Google | [Maharashtra](https://mapy.cz/?q=Mumbai), India |
| Mongolian | `mn` | `mn-MN` | DeepL | Google | [Mongolia](https://mapy.cz/?q=Mongolia), Inner Mongolia (China) |
| Nepali | `ne` | `ne-NP` | DeepL | Google | [Nepal](https://mapy.cz/?q=Nepal), Sikkim (India), Bhutan |
| Norwegian Bokmål | `nb` | `no-NO` | Flutter, DeepL | DeepL | [Norway](https://mapy.cz/?q=Norway) |
| Occitan | `oc` | `oc` | DeepL | Google | [Southern France](https://mapy.cz/?q=Toulouse), Val d'Aran (Spain), Occitan Valleys (Italy) |
| Odia | `or` | `or` | Google | Google | [Odisha](https://mapy.cz/?q=Bhubaneswar), India |
| Oromo | `om` | `om` | DeepL | Google | [Ethiopia](https://mapy.cz/?q=Ethiopia) (Oromia), northern Kenya |
| Pashto | `ps` | `ps` | DeepL | Google | [Afghanistan](https://mapy.cz/?q=Afghanistan), northwest Pakistan |
| Persian | `fa` | `fa` | Flutter, DeepL | DeepL | [Iran](https://mapy.cz/?q=Iran), Afghanistan (Dari), Tajikistan |
| Polish | `pl` | `pl-PL` | Flutter, DeepL | DeepL | [Poland](https://mapy.cz/?q=Poland) |
| Portuguese (Brazil) | `pt-rBR` | `pt-BR` | DeepL | Google | [Brazil](https://mapy.cz/?q=Brazil) |
| Portuguese (Portugal) | `pt` | `pt-PT` | Flutter, DeepL | DeepL | [Portugal](https://mapy.cz/?q=Portugal), Angola, Mozambique and other former colonies |
| Punjabi | `pa` | `pa` | DeepL | Google | [Punjab](https://mapy.cz/?q=Amritsar), India and Pakistan |
| Quechua | `qu` | `qu` | DeepL | Google | [Andes](https://mapy.cz/?q=Cusco): Peru, Bolivia, Ecuador |
| Romanian | `ro` | `ro` | Flutter, DeepL | DeepL | [Romania](https://mapy.cz/?q=Romania), Moldova |
| Rundi | `rn` | `rn` | Google | Google | [Burundi](https://mapy.cz/?q=Burundi) |
| Russian | `ru` | `ru-RU` | Flutter, DeepL | DeepL | [Russia](https://mapy.cz/?q=Russia), Belarus, Kazakhstan, Kyrgyzstan and other former Soviet states |
| Sango | `sg` | `sg` | Google | Google | [Central African Republic](https://mapy.cz/?q=Central%20African%20Republic) |
| Sanskrit | `sa` | `sa` | DeepL | Google | nowhere as a mother tongue: classical language of India, used in religion and scholarship |
| Scottish Gaelic | `gd` | `gd` | Google | Google | [Scottish Highlands and Islands](https://mapy.cz/?q=Stornoway), United Kingdom |
| Serbian | `sr` | `sr` | Flutter, DeepL | DeepL | [Serbia](https://mapy.cz/?q=Serbia), Bosnia and Herzegovina, Montenegro |
| Sesotho | `st` | `st` | DeepL | Google | [Lesotho](https://mapy.cz/?q=Lesotho), South Africa |
| Shona | `sn` | `sn` | Google | Google | [Zimbabwe](https://mapy.cz/?q=Zimbabwe) |
| Sinhala | `si` | `si-LK` | Google | Google | [Sri Lanka](https://mapy.cz/?q=Sri%20Lanka) |
| Slovak | `sk` | `sk` | Flutter, DeepL | DeepL | [Slovakia](https://mapy.cz/?q=Slovakia) |
| Slovenian | `sl` | `sl` | Flutter, DeepL | DeepL, reviewed | [Slovenia](https://mapy.cz/?q=Slovenia) |
| Somali | `so` | `so` | Google | Google | [Somalia](https://mapy.cz/?q=Somalia), Djibouti, eastern Ethiopia, northeastern Kenya |
| Spanish | `es` | `es-ES` | Flutter, DeepL | DeepL | [Spain](https://mapy.cz/?q=Spain) |
| Spanish (Latin America) | `b+es+419` | `es-419` | DeepL | Google | [Latin America](https://mapy.cz/?q=Mexico): Mexico, Central and South America, the Caribbean |
| Sundanese | `su` | `su` | DeepL | Google | [West Java](https://mapy.cz/?q=Bandung), Indonesia |
| Swahili | `sw` | `sw` | DeepL | Google | [East Africa](https://mapy.cz/?q=Tanzania): Tanzania, Kenya, Uganda, DR Congo |
| Swedish | `sv` | `sv-SE` | Flutter, DeepL | DeepL | [Sweden](https://mapy.cz/?q=Sweden), Finland (coast and Åland) |
| Tajik | `tg` | `tg` | DeepL | Google | [Tajikistan](https://mapy.cz/?q=Tajikistan) |
| Tamil | `ta` | `ta-IN` | DeepL | Google | [Tamil Nadu](https://mapy.cz/?q=Chennai), India; Sri Lanka, Singapore |
| Tatar | `tt` | `tt` | DeepL | Google | [Tatarstan](https://mapy.cz/?q=Kazan), Russia |
| Telugu | `te` | `te-IN` | DeepL | Google | [Andhra Pradesh and Telangana](https://mapy.cz/?q=Hyderabad), India |
| Thai | `th` | `th` | Flutter, DeepL | DeepL | [Thailand](https://mapy.cz/?q=Thailand) |
| Tigrinya | `ti` | `ti` | Google | Google | [Eritrea](https://mapy.cz/?q=Eritrea), Tigray (Ethiopia) |
| Tsonga | `ts` | `ts` | DeepL | Google | [South Africa](https://mapy.cz/?q=South%20Africa) (Limpopo, Mpumalanga), Mozambique |
| Tswana | `tn` | `tn` | DeepL | Google | [Botswana](https://mapy.cz/?q=Botswana), South Africa |
| Turkish | `tr` | `tr-TR` | Flutter, DeepL | DeepL | [Turkey](https://mapy.cz/?q=Turkey), Northern Cyprus |
| Turkmen | `tk` | `tk` | DeepL | Google | [Turkmenistan](https://mapy.cz/?q=Turkmenistan) |
| Ukrainian | `uk` | `uk` | Flutter, DeepL | DeepL | [Ukraine](https://mapy.cz/?q=Ukraine) |
| Urdu | `ur` | `ur` | Flutter, DeepL | DeepL | [Pakistan](https://mapy.cz/?q=Pakistan), North India |
| Uzbek | `uz` | `uz` | DeepL | Google | [Uzbekistan](https://mapy.cz/?q=Uzbekistan) |
| Vietnamese | `vi` | `vi` | Flutter, DeepL | DeepL | [Vietnam](https://mapy.cz/?q=Vietnam) |
| Welsh | `cy` | `cy` | DeepL | Google | [Wales](https://mapy.cz/?q=Cardiff), United Kingdom |
| Wolof | `wo` | `wo` | DeepL | Google | [Senegal](https://mapy.cz/?q=Senegal), Gambia, Mauritania |
| Xhosa | `xh` | `xh` | DeepL | Google | [South Africa](https://mapy.cz/?q=South%20Africa) (Eastern Cape) |
| Yiddish | `yi` | `yi` | DeepL | Google | Jewish communities, mainly in the United States and Israel |
| Yoruba | `yo` | `yo` | Google | Google | [Nigeria](https://mapy.cz/?q=Nigeria) (southwest), Benin |
| Zulu | `zu` | `zu` | DeepL | Google | [South Africa](https://mapy.cz/?q=South%20Africa) (KwaZulu-Natal) |

When adding an app locale, add it to `LOCALES` and to this table, then run the
script for it.
