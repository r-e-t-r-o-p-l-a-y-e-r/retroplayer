# Machine translation (DeepL / Google Cloud / Azure)

Two scripts translate from English (`pip install requests`). The backends, rate
limits and API locale codes live in `scripts/mt_l10n_arbs.py`, which both
import.

In-app strings: after adding an English value to
`app/src/main/res/values/strings_arb.xml`, run
`python3 scripts/mt_android_strings.py` to translate the missing keys into
every `values-*/strings_arb.xml` (`--locale`, `--key ... --force` to redo one
string, `--dry-run` to list). `TranslationsTest` fails while a locale misses a
key.

Store listing: `python3 scripts/mt_store_listings.py` translates
`fastlane/metadata/android/en-US/` into every locale folder (see
[STORE_LOCALES.md](STORE_LOCALES.md)).

## Credentials (`.env`)

Copy [`.env.example`](../.env.example) to **`.env`** (gitignored). The scripts
load `.env` automatically on startup (`load_dotenv_file`). Variables already set
in the environment win.

| Variable | Backend |
|----------|---------|
| `DEEPL_AUTH_KEY` | DeepL (preferred) |
| `GOOGLE_CLOUD_TRANSLATE_API_KEY` | Google Cloud Translation API v2 |
| `AZURE_TRANSLATOR_KEY` + `AZURE_TRANSLATOR_REGION` | Azure AI Translator |

Each locale uses **DeepL when supported**, then **Google Cloud**, then
**Azure** (`pick_mt_backend`). Add Google or Azure keys to `.env` so locales
DeepL does not cover are not skipped.

## Runbook (store listing)

From the repo root:

```bash
python3 scripts/mt_store_listings.py                              # all locales, all fields
python3 scripts/mt_store_listings.py --locale de --locale sl      # app locale codes
python3 scripts/mt_store_listings.py --field changelog            # newest changelog only
python3 scripts/mt_store_listings.py --check                      # length limits only
```

A run overwrites hand-made fixes in the locales and fields it translates;
redo them afterwards (German is written in the "du" form like the app).

## Google Cloud Translation

1. Create a [Google Cloud project](https://console.cloud.google.com/).
2. Enable **Cloud Translation API**.
3. Create an **API key** (APIs & Services → Credentials). Restrict it to Cloud Translation API.
4. Put the key in `.env` as `GOOGLE_CLOUD_TRANSLATE_API_KEY`.

Pricing: the first **500,000 characters/month** are free for standard NMT
([pricing](https://cloud.google.com/translate/pricing)).

## DeepL API

1. Create an API key at [DeepL Pro API](https://www.deepl.com/pro-api) (Developer plan includes a character trial).
2. Free API keys end with `:fx` and use `api-free.deepl.com` automatically.

DeepL's language list changes over time; the script queries live targets at
run time. When a locale is not on DeepL, **Google Cloud or Azure** in `.env` is
used automatically.

## Azure AI Translator

1. Create an [Azure Translator](https://azure.microsoft.com/products/ai-services/translator) resource (free F0 tier: ~2M chars/month).
2. Copy **Key** and **Region** into `.env`.

Optional: `AZURE_TRANSLATOR_ENDPOINT=https://api.cognitive.microsofttranslator.com`

## Locale code mapping

App codes map to API targets where needed (e.g. `zh` → `zh-CN` / `zh-Hans`,
`nb` → `no` / `nb`, `sr` → `sr-Latn`). See `GOOGLE_CLOUD_TARGET`,
`AZURE_TARGET` and `DEEPL_TARGET` in `scripts/mt_l10n_arbs.py`.
