# Wiki Status Checker

## Overview

The `check_wiki_status.rb` script scans the repository to report wiki completeness and recipe data coverage for each released Minecraft mod version. It compares released versions in [`_data/minecraft_mod_release_info.yml`](../_data/minecraft_mod_release_info.yml) against wiki files and recipe data that exist in the filesystem.

## Purpose

This tool helps maintain wiki completeness by:
- Identifying which released versions are missing specific wiki pages (`home.md`, `item-details.md`, `block-details.md`, `recipes.md`)
- Reporting recipe data availability and counts per mod version
- Providing per-loader recipe coverage (`core`, `fabric`, `neoforge`) when applicable
- Making it easy to spot gaps before they're discovered by users

## Running the Script

From the repository root:

```bash
ruby scripts/check_wiki_status.rb
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
   1.21.1
         ✓ Home ✓ Item Details ✓ Block Details ✓ Recipes
         ✓ 14 recipes found

DIFFERENT-DOORS
----------------------------------------
   1.21.1
         ✓ Home ✓ Item Details ✓ Block Details ✓ Recipes
         ✗ no recipes found

FRIGHTSDELIGHT
----------------------------------------
   1.21.1
         ✓ Home ✓ Item Details ✓ Block Details ✓ Recipes
         core: ✓ 64 recipes found
         fabric: ✓ 58 recipes found
         neoforge: ✓ 58 recipes found

...

================================================================================
SUMMARY
================================================================================
Total versions: 35
Versions with wiki: 34
Versions without wiki: 1
Coverage: 97.1%
Versions with recipe data: 32
Versions without recipe data: 3
Recipe data coverage: 91.4%
================================================================================
```

### Legend

- **✓ Home / Item Details / Block Details / Recipes** — Corresponding wiki file exists for this version
- **✗ Home / Item Details / Block Details / Recipes** — Corresponding wiki file is missing for this version
- **✓ _N_ recipes found** — Recipe JSON files were found for that mod/version
- **✗ no recipes found** — No recipe JSON files were found for that mod/version
- **`core:`, `fabric:`, `neoforge:` lines** — Per-loader recipe counts for mods that use loader-specific recipe folders

### Summary Section

- **Total versions**: Sum of all released versions across all mods
- **Versions with wiki**: Count of versions that have `home.md`
- **Versions without wiki**: Count of versions missing `home.md`
- **Coverage**: Percentage of released versions that have `home.md`
- **Versions with recipe data**: Count of versions where one or more recipe JSON files were found
- **Versions without recipe data**: Count of versions with no recipe JSON files found
- **Recipe data coverage**: Percentage of released versions that have recipe data

## File Structure

The script looks for wiki files at:
```
minecraft-mod/<mod_name>/wiki/<version>/<wiki-file>.md
```

The script looks for recipe data at:
```
_data/<mod_data_id>/recipes/<version-with-hyphens>/
```

For mods with loader-specific folders, recipe counts are reported for:
```
core/
fabric/
neoforge/
```

### Examples

Valid wiki file paths that will be detected as `✓`:
- `minecraft-mod/breezebounce/wiki/1.21.1/home.md`
- `minecraft-mod/breezebounce/wiki/1.21.1/item-details.md`
- `minecraft-mod/breezebounce/wiki/1.21.1/block-details.md`
- `minecraft-mod/breezebounce/wiki/1.21.1/recipes.md`
- `minecraft-mod/frightsdelight/wiki/1.20.1/home.md`
- `minecraft-mod/ubesdelight/wiki/1.21.11/home.md`

Valid recipe data paths:
- `_data/breezebounce/recipes/1-21-1/crafting/*.json`
- `_data/frightsdelight/recipes/1-21-1/core/**/*.json`
- `_data/frightsdelight/recipes/1-21-1/fabric/**/*.json`
- `_data/frightsdelight/recipes/1-21-1/neoforge/**/*.json`

## What to Do If Gaps Are Found

If the script shows missing wiki files or missing recipe data:

1. **Create missing wiki files**: Add the indicated file(s) in the version wiki folder (`home.md`, `item-details.md`, `block-details.md`, `recipes.md`)
   ```bash
   mkdir -p minecraft-mod/<mod_name>/wiki/<version>
   touch minecraft-mod/<mod_name>/wiki/<version>/<file>.md
   ```

2. **Add frontmatter**: At minimum, the file should include YAML frontmatter:
   ```yaml
   ---
   layout: minecraft-mod/wiki
   title: "<Mod Name> Wiki - Minecraft <Version>"
   ---
   ```
   See [`_data/wiki_home/<mod_name>.yml`](../_data/wiki_home/) for per-mod wiki content structure.

3. **Add missing recipe JSON files**: If a version reports `✗ no recipes found`, add recipe JSON files in `_data/<mod_data_id>/recipes/<version-with-hyphens>/`.

4. **Re-run the script**: Verify wiki checks and recipe counts now show `✓`
   ```bash
   ruby scripts/check_wiki_status.rb
   ```

5. **Build and test**: Verify the wiki page renders correctly
   ```bash
   bundle exec jekyll serve
   ```
   Then browse to the mod's wiki page on localhost.

## Data Sources

- **Release info**: [`_data/minecraft_mod_release_info.yml`](../_data/minecraft_mod_release_info.yml) — All released mod versions
- **Recipe data**: [`_data/<mod_id>/recipes/`](../_data/) — Per-mod recipe JSON files by Minecraft version
- **Wiki content**: [`_data/wiki_home/<mod_name>.yml`](../_data/wiki_home/) — Shared wiki content per mod
- **Wiki structure**: [`_layouts/minecraft-mod/wiki/`](_layouts/minecraft-mod/wiki/) — Wiki page layouts

## How it Works

1. Reads `_data/minecraft_mod_release_info.yml` to get all mods and their released versions
2. For each mod and version combination, checks if these files exist:
   - `minecraft-mod/<mod_name>/wiki/<version>/home.md`
   - `minecraft-mod/<mod_name>/wiki/<version>/item-details.md`
   - `minecraft-mod/<mod_name>/wiki/<version>/block-details.md`
   - `minecraft-mod/<mod_name>/wiki/<version>/recipes.md`
3. Checks recipe data in `_data/<mod_id>/recipes/<version-with-hyphens>/`
4. Counts recipe JSON files (including per-loader counts for `core`, `fabric`, `neoforge` structures)
5. Outputs a formatted report with per-version status lines and summary statistics

## Troubleshooting

**Script exits with error:** Make sure you're running it from the repository root and that `_data/minecraft_mod_release_info.yml` exists.

**All versions show `✗` for wiki files:** Check that files are in `minecraft-mod/<mod_name>/wiki/<version>/` with exact names (`home.md`, `item-details.md`, `block-details.md`, `recipes.md`).

**All versions show `✗ no recipes found`:** Check recipe folder naming. Version folders in `_data` use hyphens (for example `1-21-1`), while wiki folders use dots (for example `1.21.1`).
