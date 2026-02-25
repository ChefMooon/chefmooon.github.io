# Wiki Status Checker

## Overview

The `check_wiki_status.rb` script scans the repository to determine which Minecraft mod versions have wiki home pages created. It compares the list of released versions in [`_data/minecraft_mod_release_info.yml`](../_data/minecraft_mod_release_info.yml) against the actual `home.md` files that exist in the filesystem.

## Purpose

This tool helps maintain wiki completeness by:
- Identifying which released versions are missing wiki pages
- Providing a quick overview of wiki coverage across all mods
- Making it easy to spot gaps before they're discovered by users

## Running the Script

From the repository root:

```bash
ruby check_wiki_status.rb
```

The script requires no arguments and will output a formatted report to your terminal.

## Understanding the Output

### Example Output

```
================================================================================
MINECRAFT MOD WIKI STATUS CHECKER
================================================================================

BREEZEBOUNCE
----------------------------------------
  ✓ 1.21.1
  ✓ 1.21.5
  ✓ 1.21.8
  ✓ 1.21.10
  ✗ 1.21.11

FRIGHTSDELIGHT
----------------------------------------
  ✓ 1.19.2
  ✓ 1.20.1
  ✓ 1.21.1
  ✓ 1.21.5
  ✓ 1.21.8
  ✓ 1.21.10
  ✓ 1.21.11

...

================================================================================
SUMMARY
================================================================================
Total versions: 35
Versions with wiki: 34
Versions without wiki: 1
Coverage: 97.1%
================================================================================
```

### Legend

- **✓ (checkmark)** — Wiki `home.md` file exists for this version
- **✗ (cross)** — Wiki `home.md` file does NOT exist for this version

### Summary Section

- **Total versions**: Sum of all released versions across all mods
- **Versions with wiki**: Count of versions that have a `home.md` file
- **Versions without wiki**: Count of versions missing a `home.md` file
- **Coverage**: Percentage of released versions that have wikis

## File Structure

The script looks for wiki files at:
```
minecraft-mod/<mod_name>/wiki/<version>/home.md
```

### Examples

Valid wiki file paths that will be detected as `✓`:
- `minecraft-mod/breezebounce/wiki/1.21.1/home.md`
- `minecraft-mod/frightsdelight/wiki/1.20.1/home.md`
- `minecraft-mod/ubesdelight/wiki/1.21.11/home.md`

## What to Do If Gaps Are Found

If the script shows versions without wikis (marked with `✗`):

1. **Create the missing wiki file**: Create a new `home.md` file at the indicated path
   ```bash
   mkdir -p minecraft-mod/<mod_name>/wiki/<version>
   touch minecraft-mod/<mod_name>/wiki/<version>/home.md
   ```

2. **Add frontmatter**: At minimum, the file should include YAML frontmatter:
   ```yaml
   ---
   layout: minecraft-mod/wiki
   title: "<Mod Name> Wiki - Minecraft <Version>"
   ---
   ```
   See [`_data/wiki_home/<mod_name>.yml`](../_data/wiki_home/) for per-mod wiki content structure.

3. **Re-run the script**: Verify the file now shows `✓`
   ```bash
   ruby check_wiki_status.rb
   ```

4. **Build and test**: Verify the wiki page renders correctly
   ```bash
   bundle exec jekyll serve
   ```
   Then browse to the mod's wiki page on localhost.

## Data Sources

- **Release info**: [`_data/minecraft_mod_release_info.yml`](../_data/minecraft_mod_release_info.yml) — All released mod versions
- **Wiki content**: [`_data/wiki_home/<mod_name>.yml`](../_data/wiki_home/) — Shared wiki content per mod
- **Wiki structure**: [`_layouts/minecraft-mod/wiki/`](_layouts/minecraft-mod/wiki/) — Wiki page layouts

## How it Works

1. Reads `_data/minecraft_mod_release_info.yml` to get all mods and their released versions
2. For each mod and version combination, checks if `minecraft-mod/<mod_name>/wiki/<version>/home.md` exists on disk
3. Counts existing vs. missing wiki files
4. Outputs a formatted report with individual status lines and summary statistics

## Troubleshooting

**Script exits with error:** Make sure you're running it from the repository root and that `_data/minecraft_mod_release_info.yml` exists.

**All versions show `✗`:** Check that wiki files are in the correct path: `minecraft-mod/<mod_name>/wiki/<version>/home.md` (lowercase mod names with underscores are used in filesystem paths, not hyphens).
