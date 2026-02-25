# Documentation

This directory contains documentation for the ChefMoon website wiki system and maintenance tools.

## Using Scripts

1. run `release-info-updater.md` to update data file with information about released mods
2. run `wiki-status-checker.md` to get an overview to of all wikis

## Wiki Documentation

### [wiki-home-system.md](wiki-home-system.md)
Comprehensive guide to the wiki home system. Explains how wiki pages are rendered, where shared content lives, version-specific overrides, and the data structure for sections, announcements, and compatibility tables. Includes authoring workflows and troubleshooting tips.

### [wiki-status-checker.md](wiki-status-checker.md)
Guide to the `check_wiki_status.rb` script that scans the repository to identify which Minecraft mod versions have wiki pages. Explains how to run the script, interpret its output, and handle missing wikis.

### [release-info-updater.md](release-info-updater.md)
Guide to the `update_release_info_from_recent_posts.rb` script that inspects recent changelog posts and adds missing Minecraft versions to release data in `_data/minecraft_mod_release_info.yml`.

## Build & Validation

### [htmlproofer.md](htmlproofer.md)
Guide to HTMLProofer link validation tool. Explains how to run HTMLProofer, why we disable external link checking, what errors we validate, and how to fix common link issues.

---

**Quick Links:**
- [Wiki Status Checker Script](../scripts/check_wiki_status.rb)
- [Release Info Updater Script](../scripts/update_release_info_from_recent_posts.rb)
- [Release Info Data](../_data/minecraft_mod_release_info.yml)
- [Wiki Home Data](../_data/wiki_home/)
- [Wiki Layouts](../_layouts/minecraft-mod/wiki/)
