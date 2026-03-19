# Translation Procedure

This guide explains how translations work on this site and how to add or update them safely.

## Current Setup

- Localization engine: jekyll-polyglot
- Default language: en
- Active language list is configured in [_config.yml](../_config.yml)
- Translatable strings live in one file per language:
  - [_data/i18n/en/strings.yml](../_data/i18n/en/strings.yml)
- Mod titles/descriptions are included at the top of strings.yml under the mods key
- Structural mod metadata (icons, URLs, version flags, etc.) stays in [_data/minecraft_mods.yml](../_data/minecraft_mods.yml)

## What Gets Translated

- Navigation labels
- Button labels
- Recipe UI labels and crafting type display names
- Footer labels
- Wiki compatibility and translation section labels
- Fallback notice text
- Mod titles and mod descriptions (strings.yml -> mods)

## Add a New Language

1. Add the language code to languages in [_config.yml](../_config.yml).
2. Create a new folder for the language:
   - _data/i18n/<lang>/
3. Copy [_data/i18n/en/strings.yml](../_data/i18n/en/strings.yml) to:
   - _data/i18n/<lang>/strings.yml
4. Translate only values. Do not rename, remove, or reorder keys in a way that changes meaning.
5. Preserve Liquid placeholders and symbols in translated values:
   - Keep things like %s, {{ ... }}, or punctuation markers if present.
6. Build and verify:
   - bundle exec jekyll build

## Update Existing Translations

1. Make English source changes in [_data/i18n/en/strings.yml](../_data/i18n/en/strings.yml).
2. Propagate the same key additions to each language file under _data/i18n/<lang>/strings.yml.
3. If a key is intentionally missing in a non-English file, fallback will use English.
4. Run a local build to ensure no Liquid/YAML errors.

## Lokalise Workflow

Config file: [.lokalise.yml](../.lokalise.yml)

One-time setup:

1. Set your Lokalise project_id in [.lokalise.yml](../.lokalise.yml).
2. Set env var LOKALISE_API_TOKEN in your shell/session.

Typical sync flow:

1. Upload English source strings:
   - lokalise2 file upload --config .lokalise.yml
2. Download translated files:
   - lokalise2 file download --config .lokalise.yml

Expected download layout:

- _data/i18n/<lang>/strings.yml

## Testing Lokalise CLI Locally (Post-Publish)

After publishing the site and setting up your Lokalise project:

1. Update [.lokalise.yml](../.lokalise.yml) with your real project_id.
2. Set LOKALISE_API_TOKEN env var locally.
3. Run a local upload/download round trip to validate:
   - lokalise2 file upload --config .lokalise.yml
   - lokalise2 file download --config .lokalise.yml
4. Verify generated files land in _data/i18n/<lang>/strings.yml.
5. Confirm key structure and file mapping are correct.
6. Once validated, add a custom GitHub Actions workflow for automated sync.

This local testing phase ensures auth, file paths, and key structures are correct before automating in CI.

## Fallback Behavior

- The templates use this pattern:
  - Try site.data.i18n[site.active_lang].strings
  - Fallback to site.data.i18n.en.strings
- A translation notice is shown when a page is served from fallback content.
- Language switcher appears only when more than one language exists in the languages array.

## Quality Checklist Before Publish

1. Run: bundle exec jekyll build
2. Verify language switcher appears and links correctly
3. Spot check:
   - Home page labels
   - Mod cards and descriptions
   - Wiki recipe labels
   - Footer labels
4. Confirm no YAML syntax issues in _data/i18n/<lang>/strings.yml
5. Confirm new keys exist in every active language file

## Common Mistakes

- Adding a language to data files but forgetting to add it in [_config.yml](../_config.yml)
- Editing key names instead of values in strings.yml
- Breaking YAML indentation or quoting
- Forgetting to sync translated files after adding new keys in English
- Leaving placeholder tokens altered in translated text

## Notes

- If only UI strings are translated, page/post body content can still remain in English.
- To fully localize long-form page content, you also need language-specific page content files in addition to strings data.
