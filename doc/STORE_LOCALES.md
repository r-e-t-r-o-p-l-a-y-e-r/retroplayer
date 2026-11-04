# Store listing locales

How [`store-listings/`](../store-listings/) relates to in-app languages and store consoles.

## Policy

- **Canonical language:** English — directory [`store-listings/en/`](../store-listings/en/), generated from [`store-listings/source.en.json`](../store-listings/source.en.json).
- **Other locales:** subdirectories `store-listings/<code>/` with the same filenames.
- **Fallback:** Google Play, F-Droid and Accrescent show the default listing (English) when a store locale has no translation.

## Files per locale

| File | Play Console | F-Droid / fastlane | Limits (typical) |
|------|--------------|--------------------|------------------|
| `title.txt` | App name | `title.txt` | 30 chars |
| `short_description.txt` | Short description | `short_description.txt` | 80 chars |
| `full_description.txt` | Full description | `full_description.txt` | 4000 chars |
| `privacy_policy_url.txt` | Privacy policy URL | — | HTTPS URL |
| `whats_new.txt` | What's new | `changelogs/<versionCode>.txt` | 500 chars |

The fastlane layout (`fastlane/metadata/android/<locale>/`) uses BCP 47 tags such as `en-US` and `de-DE`.

## App locale → store locale mapping

In-app locales are the `app/src/main/res/values-<code>/strings_arb.xml` folders (listed for Android's per-app language in `res/xml/locales_config.xml`). Store consoles use their own BCP 47 tags:

| App code | Play Console (example) | fastlane folder (example) | Notes |
|----------|------------------------|---------------------------|--------|
| `en` | `en-US` | `en-US` | Default |
| `de` | `de-DE` | `de-DE` | |
| `sl` | `sl` | `sl` | |
| `nb` | `no-NO` | `no-NO` | Norwegian Bokmål |
| `zh` | `zh-CN` | `zh-CN` | Decide CN vs TW if you split |
| `pt` | `pt-BR` or `pt-PT` | `pt-PT` | Pick one primary |
| `sr` | `sr` | `sr` | Script may need store-specific variant |
| `ca`, `ga`, `mt`, … | match Play's list | same tag | |

When unsure, use Play Console's locale picker codes.

## Authoring workflow

1. Edit `store-listings/source.en.json`.
2. Run `python3 scripts/mt_store_listings.py` to write `store-listings/en/` and the machine-translated locales (backends and keys: [L10N_MT_CLOUD.md](L10N_MT_CLOUD.md)). Human review is recommended for the main languages.
3. Link the full description to the user guide ([USAGE.md](USAGE.md)) and the privacy policy ([PRIVACY.md](../PRIVACY.md)).
