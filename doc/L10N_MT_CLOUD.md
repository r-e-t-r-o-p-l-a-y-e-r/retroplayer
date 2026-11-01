# Machine translation (DeepL / Google Cloud / Azure)

Bulk-fill `lib/l10n/app_*.arb` from `app_en.arb`. Total volume for all locales is on the order of **~175k characters** (English source × target languages).

Script: `python3 scripts/mt_l10n_arbs.py` (`pip install requests`; MyMemory/scraper paths also need `deep-translator`).

**Disambiguation:** `@key.description` in `app_en.arb` (optional `@key.x-mt-context`) is sent with each string—DeepL via API `context`; Google/Azure via an extra `[Context: …]` line (only the first line of the translation is saved). Short equalizer labels (`eqBass`, `eqTreble`, `eqVoice`) rely on this.

**All-in-one (recommended when `.env` has keys):** `./scripts/update_l10n_locales.sh` — sync, repair, fill-english-only, icu-only, `flutter gen-l10n`, and `flutter test test/ui/l10n/`. Pass `--skip-tests` to skip tests.

## Credentials (`.env`)

Copy [`.env.example`](../.env.example) to **`.env`** (gitignored). The MT script **loads `.env` automatically** on startup (`load_dotenv_file` in `scripts/mt_l10n_arbs.py`). Shell `export` still works and overrides nothing already set in the environment.

| Variable | Backend |
|----------|---------|
| `DEEPL_AUTH_KEY` | DeepL (preferred when `--backend deepl`) |
| `GOOGLE_CLOUD_TRANSLATE_API_KEY` | Google Cloud Translation API v2 |
| `AZURE_TRANSLATOR_KEY` + `AZURE_TRANSLATOR_REGION` | Azure AI Translator |
| `MYMEMORY_EMAIL` | MyMemory (free, slow) |

With `--backend deepl`, each locale uses **DeepL when supported**, then **Google Cloud**, then **Azure** (`pick_mt_backend`). Add Google or Azure keys to `.env` so locales DeepL does not cover are not skipped.

## Runbook (after editing `app_en.arb` or fixing corruption)

From the repo root:

```bash
# 1. Sync new keys from English into every ARB (Dart)
dart run scripts/sync_l10n_arbs.dart

# 2. Fix placeholder / corruption only (does not reset good ICU)
python3 scripts/repair_l10n_arbs.py

# 3. Fill any string that still matches English (skips brand "Retro Player")
python3 scripts/mt_l10n_arbs.py --backend deepl --fill-english-only

# 4. ICU playlist plurals only (branch text MT, structure preserved)
python3 scripts/mt_l10n_arbs.py --backend deepl --icu-only

# 5. Regenerate Dart l10n
flutter gen-l10n

# 6. Guard tests
flutter test test/ui/l10n/
```

Re-run steps 2–4 safely; locales are skipped when already translated unless flags apply. Use `--force` to overwrite. Use `--locale de --locale fr` to limit scope.

After changing one English string (e.g. fixing wording in `app_en.arb`):

```bash
python3 scripts/mt_l10n_arbs.py --backend deepl --keys eqManually
flutter gen-l10n
```

**DeepL-only gap locales** (when Google/Azure are not configured): if the log shows `Skipping <code>: no MT backend for this locale`, add `GOOGLE_CLOUD_TRANSLATE_API_KEY` or Azure vars to `.env` and re-run `--fill-english-only` (and `--icu-only` if needed).

**Google Cloud only** (no DeepL):

```bash
python3 scripts/mt_l10n_arbs.py --backend google-cloud --fill-english-only
python3 scripts/mt_l10n_arbs.py --backend google-cloud --icu-only
flutter gen-l10n
```

**Azure only**:

```bash
python3 scripts/mt_l10n_arbs.py --backend azure --fill-english-only
python3 scripts/mt_l10n_arbs.py --backend azure --icu-only
flutter gen-l10n
```

## Google Cloud Translation

1. Create a [Google Cloud project](https://console.cloud.google.com/).
2. Enable **Cloud Translation API**.
3. Create an **API key** (APIs & Services → Credentials). Restrict it to Cloud Translation API.
4. Put the key in `.env` as `GOOGLE_CLOUD_TRANSLATE_API_KEY`.

Pricing: first **500,000 characters/month** are free for standard NMT ([pricing](https://cloud.google.com/translate/pricing)). This project fits in one run.

## DeepL API

1. Create an API key at [DeepL Pro API](https://www.deepl.com/pro-api) (Developer plan includes a character trial).
2. Free API keys end with `:fx` and use `api-free.deepl.com` automatically.

DeepL’s language list changes over time; the script queries live targets at run time. When a locale is not on DeepL, **Google Cloud or Azure** in `.env` is used automatically with `--backend deepl`.

## ICU plurals (playlist strings)

Do **not** send whole `{count,plural,…}` lines to raw MT. The script uses `scripts/icu_arb.py` to translate **inner branch text** only.

```bash
python3 scripts/mt_l10n_arbs.py --backend deepl --icu-only
```

## Azure AI Translator

1. Create an [Azure Translator](https://azure.microsoft.com/products/ai-services/translator) resource (free F0 tier: ~2M chars/month).
2. Copy **Key** and **Region** into `.env`.

Optional: `AZURE_TRANSLATOR_ENDPOINT=https://api.cognitive.microsofttranslator.com`

## Locale code mapping

App codes map to API targets where needed (e.g. `zh` → `zh-CN` / `zh-Hans`, `nb` → `no` / `nb`, `sr` → `sr-Latn`). See `GOOGLE_CLOUD_TARGET`, `AZURE_TARGET`, and `DEEPL_TARGET` in `scripts/mt_l10n_arbs.py`.

## MyMemory (slow, free)

```bash
# MYMEMORY_EMAIL=you@example.com in .env
python3 scripts/mt_l10n_arbs.py --backend mymemory
# or scripts/mt_l10n_until_done.sh
```

Daily character cap (~50k with email). Not suitable for all locales in one day.
