# Store listing copy

Localized text for **Google Play**, **F-Droid** and **Accrescent**. Not used at runtime; the in-app strings live in `app/src/main/res/values*/strings_arb.xml`.

- **English source of truth:** [`source.en.json`](source.en.json) → refresh with `python3 scripts/mt_store_listings.py --write-en`
- **English (required):** [`en/`](en/)
- **Other locales:** optional `store-listings/<code>/` — see [`doc/STORE_LOCALES.md`](../doc/STORE_LOCALES.md)
- **User guide (end users):** [`doc/USAGE.md`](../doc/USAGE.md) — link from Play / F-Droid full descriptions (not developer docs)

Upload Play translations from these files (or sync via Fastlane `supply` later). F-Droid uses the same content under `metadata/<locale>/` in [fdroiddata](https://gitlab.com/fdroid/fdroiddata).
