# Store listing copy

Localized text for **Google Play**, **F-Droid**, and **Aptoide**. Not used at runtime — separate from [`lib/l10n/`](../lib/l10n/).

- **English source of truth:** [`source.en.json`](source.en.json) → refresh with `python3 scripts/mt_store_listings.py --write-en`
- **English (required):** [`en/`](en/)
- **Other locales:** optional `store-listings/<code>/` — see [`doc/STORE_LOCALES.md`](../doc/STORE_LOCALES.md)
- **User guide link:** point `full_description.txt` readers to [`doc/USAGE.md`](../doc/USAGE.md) on your public repository

Upload Play translations from these files (or sync via Fastlane `supply` later). F-Droid uses the same content under `metadata/<locale>/` in [fdroiddata](https://gitlab.com/fdroid/fdroiddata).
