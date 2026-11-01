# Store listing locales

How [`store-listings/`](../store-listings/) relates to in-app languages and store consoles.

## Policy

- **Canonical language:** English — directory [`store-listings/en/`](../store-listings/en/).
- **Other locales:** Optional subdirectories `store-listings/<code>/` with the same filenames.
- **Fallback:** Google Play, F-Droid, and Aptoide show the default listing (English) when a store locale has no translation. Missing directories in the repo are expected until translated.

## Files per locale

| File | Play Console | F-Droid (`metadata/`) | Limits (typical) |
|------|--------------|------------------------|------------------|
| `title.txt` | App name | (often from manifest) | Short |
| `short_description.txt` | Short description | `summary.txt` | ~80 chars |
| `full_description.txt` | Full description | `full_description.txt` | ~4000 chars |
| `privacy_policy_url.txt` | Privacy policy URL | — | HTTPS URL |
| `whats_new.txt` | What's new (Play) | — | Release notes |

F-Droid may use `en-US/` instead of `en/` in fdroiddata; copy content from `store-listings/en/` when submitting.

## App locale → store locale mapping

In-app codes come from [`AppLocaleCatalog`](../lib/l10n/app_locale_catalog.dart) / `app_<code>.arb`. Store consoles use their own BCP 47 tags. Use this table when creating `store-listings/<code>/`:

| App / ARB code | Play Console (example) | F-Droid folder (example) | Notes |
|----------------|------------------------|---------------------------|--------|
| `en` | `en-US` | `en-US` | Default |
| `de` | `de-DE` | `de-DE` | |
| `sl` | `sl` | — | |
| `nb` | `no-NO` | — | Norwegian Bokmål |
| `zh` | `zh-CN` | — | Decide CN vs TW if you split |
| `pt` | `pt-BR` or `pt-PT` | — | Pick one primary |
| `sr` | `sr` | — | Script may need store-specific variant |
| `ca`, `ga`, `mt`, … | match Play’s list | optional | |

When unsure, use Play Console’s locale picker codes as directory names under `store-listings/`.

## Authoring workflow

1. Edit English files in `store-listings/en/`.
2. Translate (human review recommended for DE, SL, etc.):
   - Manual copy, or
   - Extend MT scripts ([`scripts/mt_l10n_arbs.py`](../scripts/mt_l10n_arbs.py)) for store text in a follow-up.
3. Link full description to the user guide: [`USAGE.md`](USAGE.md) on your public repo (replace `<org>` when host exists).

## CI gate (future)

Optional test: assert `store-listings/en/*.txt` exist and non-empty; warn if [`SupportedLocaleCodes`](../lib/domain/supported_locale_codes.dart) has no matching store folder.

## Checklist IDs

`store-listings-en`, `store-listings-l10n` in [`PUBLIC_RELEASE_PLAN.md`](PUBLIC_RELEASE_PLAN.md).
