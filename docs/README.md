# Documentation

This directory contains documentation for the ChefMoon website wiki system and maintenance tools.

## Using Scripts

1. run `release-info-updater.rb` to update data file with information about released mods
2. run `wiki-status-checker.rb` to get an overview to of all wikis

## Automated Workflows

### Wiki Status Report Workflow
The **Wiki Status Report** GitHub Actions workflow automates the wiki status reporting process. It runs the release info updater and wiki status checker sequentially, then uploads a report as an artifact for download.

**To run manually:**
1. Navigate to the [Actions tab](../../actions) in GitHub.
2. Click **Wiki Status Report** in the left sidebar.
3. Click **Run workflow** and select the branch (default: main).
4. Monitor the workflow in progress or review the completed run.
5. Download the **wiki-status-report** artifact from the workflow summary.
6. View the report output directly in the workflow logs under the "Run wiki status checker and save report" step.

**Workflow behavior:**
- Always updates the `wiki-status` branch from the latest `main` before running scripts.
- Only commits changes to `_data/minecraft_mod_release_info.yml` if modifications are detected.
- Uploads the wiki status report as an artifact for easy access and historical reference.
- Does not trigger the main branch website publish action (commits go to `wiki-status`).

## Wiki Documentation

### [wiki-module-loader.md](wiki-module-loader.md)
Guide to `_plugins/wiki_module_loader.rb`. Explains how modular wiki markdown files are discovered, how version overrides are resolved, how module content is Liquid-rendered, and how layouts consume `page.wiki_modules`.

### [wiki-home-system.md](wiki-home-system.md)
Comprehensive guide to the wiki home system. Explains how wiki pages are rendered, where shared content lives, version-specific overrides, and the data structure for sections, announcements, and compatibility tables. Includes authoring workflows and troubleshooting tips.

### [wiki-status-checker.md](wiki-status-checker.md)
Guide to the `check_wiki_status.rb` script that scans the repository to identify which Minecraft mod versions have wiki pages. Explains how to run the script, interpret its output, and handle missing wikis. Includes coverage of `mono_wiki` mode for mods with version-agnostic wikis.

### [release-info-updater.md](release-info-updater.md)
Guide to the `update_release_info_from_recent_posts.rb` script that inspects recent changelog posts and adds missing Minecraft versions to release data in `_data/minecraft_mod_release_info.yml`. Covers field preservation behavior for optional mod flags like `mono_wiki`.

## Frontend & Styling

### [styling-guide.md](styling-guide.md)
Comprehensive styling guide documenting the design system, CSS patterns, and component conventions used across the site. Covers color tokens, typography, spacing, layout patterns, component styles, responsive design, and best practices for maintaining visual consistency when updating pages.

## Build & Validation

### [translations.md](translations.md)
Runbook for the translation workflow with jekyll-polyglot. Covers adding a new language, maintaining i18n keys, Lokalise sync, fallback behavior, and release checks.

### [htmlproofer.md](htmlproofer.md)
Guide to HTMLProofer link validation tool. Explains how to run HTMLProofer, why we disable external link checking, what errors we validate, and how to fix common link issues.

### [recipe-validation-system.md](recipe-validation-system.md)
Guide to the Recipe Validation System in the recipe generator plugin. Explains how validation schemas work, what errors mean, how to fix invalid recipe data, and how to add support for new recipe types.

---

**Quick Links:**
- [Wiki Status Checker Script](../scripts/check_wiki_status.rb)
- [Release Info Updater Script](../scripts/update_release_info_from_recent_posts.rb)
- [Release Info Data](../_data/minecraft_mod_release_info.yml)
- [Wiki Home Data (Archived)](../_data/wiki_home_archive/)
- [Wiki Modular Content](../minecraft-mod/)
- [Wiki Layouts](../_layouts/minecraft-mod/wiki/)
- [Wiki Module Loader](wiki-module-loader.md)
