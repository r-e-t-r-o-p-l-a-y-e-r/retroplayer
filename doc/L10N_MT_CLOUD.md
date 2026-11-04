# Machine translation (DeepL / Google Cloud / Azure)

The store listings are machine-translated from English with
`python3 scripts/mt_store_listings.py` (`pip install requests`; MyMemory and
scraper paths also need `deep-translator`). The backends, rate limits and
locale code mapping live in `scripts/mt_l10n_arbs.py`, which the listing script
imports.

In-app strings (`app/src/main/res/values-*/strings_arb.xml`) are the
translation source themselves; a new key needs a translation in every locale
file.

## Credentials (`.env`)

Copy [`.env.example`](../.env.example) to **`.env`** (gitignored). The scripts
load `.env` automatically on startup (`load_dotenv_file`). Variables already set
in the environment win.

| Variable | Backend |
|----------|---------|
| `DEEPL_AUTH_KEY` | DeepL (preferred when `--backend deepl`) |
| `GOOGLE_CLOUD_TRANSLATE_API_KEY` | Google Cloud Translation API v2 |
| `AZURE_TRANSLATOR_KEY` + `AZURE_TRANSLATOR_REGION` | Azure AI Translator |
| `MYMEMORY_EMAIL` | MyMemory (free, slow) |

With `--backend deepl`, each locale uses **DeepL when supported**, then
**Google Cloud**, then **Azure** (`pick_mt_backend`). Add Google or Azure keys
to `.env` so locales DeepL does not cover are not skipped.

## Runbook (store listings)

From the repo root:

```bash
python3 scripts/mt_store_listings.py --write-en                     # English files from source.en.json
python3 scripts/mt_store_listings.py --backend auto                 # all locales
python3 scripts/mt_store_listings.py --backend deepl --locale de --locale sl
```

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
used automatically with `--backend deepl`.

## Azure AI Translator

1. Create an [Azure Translator](https://azure.microsoft.com/products/ai-services/translator) resource (free F0 tier: ~2M chars/month).
2. Copy **Key** and **Region** into `.env`.

Optional: `AZURE_TRANSLATOR_ENDPOINT=https://api.cognitive.microsofttranslator.com`

## Locale code mapping

App codes map to API targets where needed (e.g. `zh` → `zh-CN` / `zh-Hans`,
`nb` → `no` / `nb`, `sr` → `sr-Latn`). See `GOOGLE_CLOUD_TARGET`,
`AZURE_TARGET` and `DEEPL_TARGET` in `scripts/mt_l10n_arbs.py`.

## MyMemory (slow, free)

```bash
# MYMEMORY_EMAIL=you@example.com in .env
python3 scripts/mt_store_listings.py --backend mymemory
```

Daily character cap (~50k with email). Not suitable for all locales in one day.
