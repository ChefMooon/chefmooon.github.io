# Polyglot i18n Localization — Implementation Plan

Created: 2026-03-19

## Goal

Add multi-language support to ChefMooon's Hub using [jekyll-polyglot](https://polyglot.untra.io). Start with English-only infrastructure, restructure UI strings into `_data/i18n/{lang}/` data files, update all templates to use localized lookups, add a language switcher, and deploy via the existing GitHub Actions workflow. Recipe item names stay untouched. Mod descriptions become translatable.

## Current Site Analysis

### Architecture today
- Jekyll 4.4.1 with `jekyll/minima` remote theme.
- Layout chain: `_layouts/base.html` (sets `<html lang="en">`) → `_layouts/default.html` → page layouts.
- All templates use `relative_url` filter — site is baseurl-portable.
- Custom plugins: `recipe_generator.rb`, `wiki_module_loader.rb`, `filters.rb`, `svg_icon_tag.rb`.
- Build/deploy: `.github/workflows/jekyll.yml` uses `bundle exec jekyll build` + `actions/deploy-pages@v4`.
- No `lang:` frontmatter on any existing pages.

### i18n today
- Partial: `_data/i18n/en.yml` has ~22 strings (`compatibility`, `components`, `translation` sections).
- Used in 5 wiki module files via `site.data.i18n.en.*` (hardcoded `en`):
  - `minecraft-mod/*/wiki/compatibility.md` — legend labels
  - `minecraft-mod/*/wiki/translation.md` — section titles, placeholder text
  - `_includes/minecraft-mod/wiki/item-components.html` — component labels
- All other UI text is hardcoded English in ~30 layout/include files (~100+ strings total).

### Data files with display labels
- `_data/crafting_types.yml` — 16 recipe type display names (e.g., `"Cooking Pot"`)
- `_data/mod_buttons.yml` — 10 button labels with icon mappings
- `_data/load_conditions.yml` — condition display names + tooltip descriptions
- `_data/socials.yml` — 6 social platform labels (brand names, not translatable)
- `_data/minecraft_mods.yml` — 6 mod titles + descriptions (to become translatable)

### Recipe label flow (untouched by this plan)
```
recipe_generator.rb → site.data[mod_id]['recipes'][version] → recipe YAML
                    → site.data[mod_id]['lang'][version] → en_us.json
template → page.mod_lang → item-renderer.html → matches item.id to lang data → display name
template → site.data.crafting_types[recipe_type] → "Cooking Pot"
```
The recipe generator accesses `site.data[mod_id]` directly. Polyglot does NOT alter these paths — it only intercepts `site.data[lang_code]` when language-specific data directories (`_data/en/`, `_data/es/`) exist. Since mod data lives under `_data/ubesdelight/`, etc., there is no conflict.

### Constraints
- Windows host: `parallel_localization` must be `false`.
- Jekyll 4 + polyglot: SCSS sourcemaps must be disabled (`sass: sourcemap: never`).
- `_data/i18n/en.yml` is a flat file at `_data/i18n/en.yml` — polyglot's localized `site.data` convention uses `_data/{lang}/` top-level directories. This plan uses `_data/i18n/{lang}/` for namespacing, accessed via `site.data.i18n[site.active_lang]`.
- Existing `site.data.i18n.en.*` references in wiki module files must be migrated to `site.data.i18n[site.active_lang].*` pattern.
- `jekyll-polyglot` is not natively supported by GitHub Pages, but the existing workflow (`bundle exec jekyll build`) already handles plugin execution, so no CI changes are needed.

## Decisions (FINALIZED)

1. **Data path:** `_data/i18n/{lang}/strings.yml` (e.g., `_data/i18n/en/strings.yml`). User preference over polyglot's default `_data/{lang}/`.
2. **Recipe data untouched:** Item names from `en_us.json` stay as-is. Multi-locale lang file support deferred.
3. **Mod descriptions translatable:** Stored in `_data/i18n/{lang}/mods.yml`. Structural metadata stays in `minecraft_mods.yml`.
4. **English-only first:** Only `"en"` in `languages` array. Infrastructure supports adding more.
5. **Windows compatibility:** `parallel_localization: false`.
6. **GitHub Pages:** Existing custom workflow remains compatible.
7. **Translation management:** Lokalise is the TMS. English strings in the repo are the source of truth (pushed to Lokalise). Translations are authored in Lokalise and pulled to the repo via CLI or CI action. The English source file (`_data/i18n/en/strings.yml`) is manually maintained and never overwritten by Lokalise exports.
8. **Interpolation convention (deferred):** If translatable strings need dynamic values in the future, use ICU `{variable}` syntax and configure Lokalise's placeholder format to match.

---

## Phase 1 — Polyglot Installation & Config

**Depends on:** Nothing
**Verification:** `bundle exec jekyll serve` starts without errors. Site renders identically.

### Step 1.1 — Add gem dependency

Edit `Gemfile`. Add inside the `:jekyll_plugins` group:

```ruby
gem "jekyll-polyglot"
```

Run `bundle install`.

### Step 1.2 — Configure `_config.yml`

Add these keys to `_config.yml` (after the existing `plugins:` block):

```yaml
# i18n / Polyglot
languages: ["en"]
default_lang: "en"
exclude_from_localization: ["assets", "images", "fonts", "sitemap.xml", "robots.txt", "feed.xml"]
parallel_localization: false
```

Also add under the existing `sass:` key:

```yaml
sass:
  quiet_deps: true
  sourcemap: never
```

### Step 1.3 — Update `_config_debug.yml`

Add to `_config_debug.yml`:

```yaml
parallel_localization: false
```

### Step 1.4 — Verify GitHub Actions workflow

Read `.github/workflows/jekyll.yml`. Confirm it uses `bundle exec jekyll build`. No changes should be needed — polyglot integrates as a plugin via the `Gemfile` group. If the workflow pins specific gems or excludes plugins, adjust accordingly.

---

## Phase 2 — Restructure i18n Data Files

**Depends on:** Phase 1
**Verification:** `site.data.i18n.en.strings` accessible in Liquid. Old `site.data.i18n.en` path ceases to exist (file moved to directory).

### Step 2.1 — Move existing i18n file

Move the existing file from a flat YAML into a directory structure:
- Delete `_data/i18n/en.yml`
- Create `_data/i18n/en/strings.yml` containing the original keys plus all new keys from Step 2.2

**IMPORTANT:** After this step, all existing `site.data.i18n.en.*` references become `site.data.i18n.en.strings.*`. Templates that currently reference `site.data.i18n.en.compatibility.*` will need to reference `site.data.i18n.en.strings.compatibility.*` (or use the `t` alias from Phase 3).

### Step 2.2 — Create comprehensive English strings file

Create `_data/i18n/en/strings.yml` with the following content. This consolidates all translatable UI strings from across the site.

**Lokalise note:** YAML comments (e.g., `# Navigation`, `# used in ...`) will be stripped when Lokalise exports translated YAML files. This is expected — only non-English files are generated by Lokalise. The English source file is manually maintained in the repo and never overwritten by Lokalise export. Translator context for game-domain keys (crafting types, load conditions, components) should be provided via Lokalise key descriptions or tags instead of YAML comments.

```yaml
# =============================================================================
# English UI Strings
# =============================================================================
# This file contains all translatable UI strings for the site.
# To add a new language, copy this file to _data/i18n/{lang_code}/strings.yml
# and translate the values.
# =============================================================================

# Navigation (used in _layouts/default.html, _includes/header.html)
nav:
  home: "Home"
  mods: "Mods"
  updates: "Updates"
  about: "About"
  wiki: "Wiki"
  changelog: "Changelog"
  roadmap: "Roadmap"

# Mod page buttons (used in _layouts/minecraft-mod/wiki/base.html, mod nav)
# These replace the `label` field lookups from _data/mod_buttons.yml
buttons:
  home: "Home"
  wiki: "Wiki"
  changelog: "Changelog"
  roadmap: "Roadmap"
  source: "Source"
  issues: "Issues"
  wiki_home: "Wiki Home"
  item_details: "Item Details"
  block_details: "Block Details"
  recipes: "Recipes"

# Recipe wiki UI (used in recipe-info.html, recipe-list.html)
recipe:
  type: "Type"
  category: "Category"
  recipe_book_tab: "Recipe Book Tab"
  cooking_time: "Cooking Time"
  processing_time: "Processing Time"
  experience: "Experience"
  tool: "Tool"
  load_conditions: "Load Conditions"
  tag_notice: "Items marked with * are tags. Hover to see the tag name."
  base: "Base"
  fabric: "Fabric"
  neoforge: "NeoForge"

# Crafting type display names (replaces _data/crafting_types.yml for display)
# Keys match recipe type identifiers from the recipe generator
crafting_types:
  "minecraft:crafting_shapeless": "Shapeless Crafting"
  "minecraft:crafting_shaped": "Shaped Crafting"
  "minecraft:smithing_transform": "Smithing"
  "minecraft:smelting": "Smelting"
  "minecraft:smoking": "Smoking"
  "minecraft:campfire_cooking": "Campfire Cooking"
  "farmersdelight:cutting": "Cutting"
  "farmersdelight:cooking": "Cooking Pot"
  "ubesdelight:baking_mat": "Baking Mat"
  "create:milling": "Milling"
  "create:mixing": "Mixing"
  "create:emptying": "Emptying"
  "create:filling": "Filling"
  "differentdoors:slide_to_swing": "Slide to Swing (Shapeless Crafting)"
  "differentdoors:swing_to_slide": "Swing to Slide (Shapeless Crafting)"
  "differentdoors:waxed_copper": "Waxed Copper (Shapeless Crafting)"

# Load condition display names (used in recipe-info.html)
# Tooltip descriptions remain in _data/load_conditions.yml
load_conditions:
  "fabric:all_mods_loaded": "Mod(s) Loaded"
  "fabric:any_mod_loaded": "Mod(s) Loaded"
  "neoforge:mod_loaded": "Mod(s) Loaded"
  "forge:mod_loaded": "Mod(s) Loaded"
  "neoforge:and": "All Conditions Met"
  "ubesdelight:ud_crates_enabled": "Configuration - Crop Crates Enabled"
  "frightsdelight:frd_vanilla_crates_enabled": "Configuration - Crop Crates Enabled"

# Layout strings (used across multiple layout files)
layout:
  recent_updates: "Recent Updates"
  view_all_updates: "View all updates →"
  minecraft_mods: "Minecraft Mods"
  previous: "← Previous"
  next: "Next →"
  page: "Page"
  back_to_top: "Back to Top"
  all_entries: "All Entries"
  tags: "Tags"
  categories: "Categories"
  minecraft_version: "Minecraft Version"
  version_prefix: "V"

# Roadmap layout
roadmap:
  title: "Mod Roadmaps"
  description: "Here you will find an overview of upcoming features, changes, and bug fixes for all mods."
  updates_listed: "Updates are listed in order of priority."
  will_be_updated: "This roadmap will be updated as development progresses."

# Fluid renderer (used in fluid-renderer.html)
fluid:
  millibucket: "mB of"
  show_nbt: "Show NBT data"

# Footer (used in _includes/footer.html)
footer:
  built_by: "Built by"
  hosted_on: "Hosted on"
  rss: "RSS"

# Compatibility section (migrated from old _data/i18n/en.yml)
compatibility:
  legend_label: "Legend"
  supported_label: "Supported Version"
  unsupported_label: "Not Supported"
  bugfix_label: "Bug Fix Only"
  planned_label: "Planned"

# Item/block components section (migrated from old _data/i18n/en.yml)
components:
  section_title: "Components"
  labels:
    "minecraft:block_state": "Block State"
    "playful_planes:paper_plane_data": "Paper Plane Data"
  keys:
    swing: "Swing"
    type: "Type"

# Translation wiki section (migrated from old _data/i18n/en.yml)
translation:
  section_title: "Translation"
  submit_heading: "Contribute a Translation"
  submit_placeholder: "Greatly appreciate all translations. Submit translations by creating a pull request in the GitHub repository."
  no_contributors_yet: "No translations yet, please consider contributing."
  language: "Language"
  status: "Status"
  version: "Version"
  authors: "Authors"

# Wiki home sections
wiki_home:
  current: "Current"
  planned: "Planned"

# Fallback notice (shown when a page is not yet translated)
fallback:
  notice: "This page is not yet available in your language. Showing English version."
```

### Step 2.3 — Create mod descriptions file

Create `_data/i18n/en/mods.yml` with translatable mod titles and descriptions. Extract values from the current `_data/minecraft_mods.yml`:

```yaml
# =============================================================================
# English Mod Titles & Descriptions
# =============================================================================
# Non-translatable metadata (icons, versions, URLs) stays in minecraft_mods.yml.
# To translate, copy this file to _data/i18n/{lang_code}/mods.yml.
# =============================================================================

ubesdelight:
  title: "Ube's Delight"
  description: "<copy from minecraft_mods.yml>"

differentdoors:
  title: "Different Doors"
  description: "<copy from minecraft_mods.yml>"

breezebounce:
  title: "Breeze Bounce"
  description: "<copy from minecraft_mods.yml>"

colourfulclocks:
  title: "Colourful Clocks"
  description: "<copy from minecraft_mods.yml>"

frightsdelight:
  title: "Fright's Delight"
  description: "<copy from minecraft_mods.yml>"

playfulplanes:
  title: "Playful Planes"
  description: "<copy from minecraft_mods.yml>"
```

**Action:** Read `_data/minecraft_mods.yml` and copy each mod's `title` and `description` values verbatim into this file.

### Step 2.4 — Keep existing data files as fallback/structural

These files are NOT deleted or restructured:
- `_data/crafting_types.yml` — retained as fallback; templates switch primary lookup to `t.crafting_types`
- `_data/mod_buttons.yml` — retained for `id` and `icon` fields; label display moves to `t.buttons`
- `_data/load_conditions.yml` — retained for `description` tooltip field; display name moves to `t.load_conditions`
- `_data/socials.yml` — unchanged (brand names don't need translation)

---

## Phase 2.5 — Lokalise Project Setup

**Depends on:** Phase 2
**Verification:** `lokalise2 file upload` succeeds. Keys appear in Lokalise dashboard. Round-trip download produces identical key structure.

### Step 2.5.1 — Install Lokalise CLI

Install `lokalise2` CLI via npm, brew, or direct binary download.

### Step 2.5.2 — Create `.lokalise.yml` config

Create a Lokalise CLI config at the project root:

```yaml
project_id: "<your-project-id>"
token: "%LOKALISE_API_TOKEN%"
files:
  upload:
    - file: _data/i18n/en/strings.yml
      lang_iso: en
      format: yaml
      convert_placeholders: false
      tags:
        - ui-strings
    - file: _data/i18n/en/mods.yml
      lang_iso: en
      format: yaml
      convert_placeholders: false
      tags:
        - mod-descriptions
  download:
    format: yaml
    original_filenames: true
    directory_prefix: ""
    export_empty_as: base
    bundle_structure: "_data/i18n/%LANG_ISO%/"
```

**Key settings:**
- `convert_placeholders: false` — prevents Lokalise from interpreting colon-containing YAML keys (e.g., `minecraft:crafting_shapeless`) as placeholders.
- `export_empty_as: base` — untranslated keys export with the English value, providing file-level fallback alongside the Liquid template fallback.

### Step 2.5.3 — Upload source strings

Push English source files to Lokalise. Add key descriptions for game-domain terms:
- Tag `crafting_types.*`, `load_conditions.*`, and `components.*` keys with a `game-terms` tag in Lokalise.
- Add key descriptions explaining Minecraft-specific terms (e.g., `"Baking Mat"` → "A crafting station from the Ube's Delight mod").

### Step 2.5.4 — Verify round-trip fidelity

Upload `strings.yml` to Lokalise, immediately download, and diff against the original. All keys — including colon-containing keys like `minecraft:crafting_shapeless` — must round-trip identically. If colon-containing keys break, replace colons with `__` in YAML keys and update template lookups.

### Step 2.5.5 — Add CI sync (optional)

Add a GitHub Action or script to pull translations on schedule or on demand:
- On push to `main`: upload updated English source files to Lokalise.
- On schedule or manual trigger: download translations from Lokalise, commit to a PR.
- Validate downloaded YAML parses correctly before committing.

---

## Phase 3 — Translation Helper Pattern

**Depends on:** Phase 2
**Verification:** In a test layout, `{{ t.nav.home }}` outputs `"Home"`.

### Step 3.1 — Establish the `t` variable pattern

Every layout that needs translated strings must assign `t` near the top of the file (after frontmatter, before content):

```liquid
{%- assign t = site.data.i18n[site.active_lang].strings -%}
{%- unless t -%}{%- assign t = site.data.i18n.en.strings -%}{%- endunless -%}
```

This gives a `t` variable with automatic English fallback. All string references then use `{{ t.section.key }}`.

**Do NOT create a separate include file for this.** Liquid `assign` in an include does not propagate to the parent scope reliably. Each layout must assign `t` itself.

### Step 3.2 — Establish the mod i18n pattern

For templates displaying mod titles/descriptions:

```liquid
{%- assign mod_i18n = site.data.i18n[site.active_lang].mods[mod.id] -%}
{%- unless mod_i18n -%}{%- assign mod_i18n = site.data.i18n.en.mods[mod.id] -%}{%- endunless -%}
{{ mod_i18n.title }}
{{ mod_i18n.description }}
```

### Step 3.3 — Pattern for includes receiving `t` from parent

Includes that need `t` should expect it to already be assigned by the parent layout. If an include is used in a context where `t` might not be set, guard at the top:

```liquid
{%- unless t -%}
  {%- assign t = site.data.i18n[site.active_lang].strings -%}
  {%- unless t -%}{%- assign t = site.data.i18n.en.strings -%}{%- endunless -%}
{%- endunless -%}
```

---

## Phase 4 — Update Templates

**Depends on:** Phase 3
**Verification:** Site renders identically to before. All strings resolve through `t.*` lookups. Grep for remaining hardcoded English UI strings returns zero results.

Each step below is independent and can be executed in parallel.

### Step 4.1 — Navigation: `_includes/header.html` + `_layouts/default.html`

Add `t` assignment at top of `_layouts/default.html`.

Replace all hardcoded nav labels:
| Hardcoded | Replacement |
|-----------|-------------|
| `"Home"` | `{{ t.nav.home }}` |
| `"Mods"` | `{{ t.nav.mods }}` |
| `"Updates"` | `{{ t.nav.updates }}` |
| `"About"` | `{{ t.nav.about }}` |
| `"Wiki"` | `{{ t.nav.wiki }}` |
| `"Changelog"` | `{{ t.nav.changelog }}` |
| `"Roadmap"` | `{{ t.nav.roadmap }}` |

Also replace mod-specific nav labels generated in dropdowns. Aria-labels that currently say things like "Toggle mod menu" can remain English or be moved to `t.nav.*`.

### Step 4.2 — Footer: `_includes/footer.html`

Replace:
| Hardcoded | Replacement |
|-----------|-------------|
| `"Built by"` | `{{ t.footer.built_by }}` |
| `"Hosted on"` | `{{ t.footer.hosted_on }}` |
| `"RSS"` | `{{ t.footer.rss }}` |

### Step 4.3 — Recipe info: `_includes/minecraft-mod/wiki/recipe-info.html`

The parent layout (`_layouts/minecraft-mod/wiki/recipes.html`) must assign `t` before including recipe partials.

Replace all field labels:
| Hardcoded | Replacement |
|-----------|-------------|
| `"Type"` or `"Type:"` | `{{ t.recipe.type }}` |
| `"Category"` | `{{ t.recipe.category }}` |
| `"Recipe Book Tab"` | `{{ t.recipe.recipe_book_tab }}` |
| `"Cooking Time"` | `{{ t.recipe.cooking_time }}` |
| `"Processing Time"` | `{{ t.recipe.processing_time }}` |
| `"Experience"` | `{{ t.recipe.experience }}` |
| `"Tool"` | `{{ t.recipe.tool }}` |
| `"Load Conditions"` | `{{ t.recipe.load_conditions }}` |

For crafting type display names, change:
```liquid
<!-- BEFORE -->
{{ site.data.crafting_types[recipe_type] | default: recipe_type }}
<!-- AFTER -->
{{ t.crafting_types[recipe_type] | default: site.data.crafting_types[recipe_type] | default: recipe_type }}
```

For load condition display names, change:
```liquid
<!-- BEFORE -->
{{ site.data.load_conditions[condition_type].id }}
<!-- AFTER — display name from strings, tooltip description stays from load_conditions.yml -->
{{ t.load_conditions[condition_type] | default: site.data.load_conditions[condition_type].id }}
```

### Step 4.4 — Recipe list: `_includes/minecraft-mod/wiki/recipe-list.html`

Replace:
| Hardcoded | Replacement |
|-----------|-------------|
| `"Base"` | `{{ t.recipe.base }}` |
| `"Fabric"` | `{{ t.recipe.fabric }}` |
| `"NeoForge"` | `{{ t.recipe.neoforge }}` |
| `"Items marked with * are tags..."` | `{{ t.recipe.tag_notice }}` |

### Step 4.5 — Fluid renderer: `_includes/minecraft-mod/wiki/fluid-renderer.html`

Replace:
| Hardcoded | Replacement |
|-----------|-------------|
| `"mB of"` | `{{ t.fluid.millibucket }}` |
| `"Show NBT data"` | `{{ t.fluid.show_nbt }}` |

### Step 4.6 — Wiki home sections

**`_includes/minecraft-mod/wiki/home-section-compatibility.html`:**
| Hardcoded | Replacement |
|-----------|-------------|
| `"Minecraft Version"` (table header) | `{{ t.layout.minecraft_version }}` |

**`_includes/minecraft-mod/wiki/home-section-translation.html`:**
| Hardcoded | Replacement |
|-----------|-------------|
| `"Language"` | `{{ t.translation.language }}` |
| `"Status"` | `{{ t.translation.status }}` |
| `"Version"` | `{{ t.translation.version }}` |
| `"Authors"` | `{{ t.translation.authors }}` |

**`_includes/minecraft-mod/wiki/home-section.html`:**
| Hardcoded | Replacement |
|-----------|-------------|
| `"Current:"` | `{{ t.wiki_home.current }}:` |
| `"Planned:"` | `{{ t.wiki_home.planned }}:` |

### Step 4.7 — Main layouts: `home.html`, `recent-updates.html`, `roadmap.html`, `tag_page.html`

Add `t` assignment to each layout.

**`_layouts/home.html`:**
| Hardcoded | Replacement |
|-----------|-------------|
| `"Minecraft Mods"` | `{{ t.layout.minecraft_mods }}` |
| `"Recent Updates"` | `{{ t.layout.recent_updates }}` |
| `"View all updates →"` | `{{ t.layout.view_all_updates }}` |

**`_layouts/recent-updates.html`:**
| Hardcoded | Replacement |
|-----------|-------------|
| `"← Previous"` | `{{ t.layout.previous }}` |
| `"Next →"` | `{{ t.layout.next }}` |
| `"Page"` | `{{ t.layout.page }}` |

**`_layouts/roadmap.html`:**
| Hardcoded | Replacement |
|-----------|-------------|
| `"Mod Roadmaps"` | `{{ t.roadmap.title }}` |
| `"Here you will find..."` | `{{ t.roadmap.description }}` |

**`_layouts/tag_page.html`:**
| Hardcoded | Replacement |
|-----------|-------------|
| `"Tags:"` | `{{ t.layout.tags }}:` |

### Step 4.8 — Mod page layouts

Add `t` assignment to each layout.

**`_layouts/minecraft-mod/page.html`:**
| Hardcoded | Replacement |
|-----------|-------------|
| `"Updates"` | `{{ t.nav.updates }}` |
| `"← Previous"` | `{{ t.layout.previous }}` |
| `"Next →"` | `{{ t.layout.next }}` |
| `"Page"` | `{{ t.layout.page }}` |

**`_layouts/minecraft-mod/changelog.html`:**
| Hardcoded | Replacement |
|-----------|-------------|
| `"Changelog"` | `{{ t.nav.changelog }}` |
| `"All Entries"` | `{{ t.layout.all_entries }}` |

**`_layouts/minecraft-mod/roadmap.html`:**
| Hardcoded | Replacement |
|-----------|-------------|
| `"Roadmap"` | `{{ t.nav.roadmap }}` |
| `"Upcoming features..."` | translatable string or keep as page content |

**`_layouts/minecraft-mod/post/changelog.html`:**
| Hardcoded | Replacement |
|-----------|-------------|
| `"V"` (version prefix) | `{{ t.layout.version_prefix }}` |
| `"Categories"` | `{{ t.layout.categories }}` |

### Step 4.9 — Wiki base: `_layouts/minecraft-mod/wiki/base.html`

Add `t` assignment.

Replace:
| Hardcoded | Replacement |
|-----------|-------------|
| `"Minecraft Version:"` | `{{ t.layout.minecraft_version }}:` |
| Button labels from `site.data.mod_buttons[*].label` | `{{ t.buttons[button.id] \| default: button.label }}` |

### Step 4.10 — Mod listing: `_includes/minecraft-mods.html`

Replace mod descriptions with i18n lookups:
```liquid
<!-- BEFORE -->
{{ mod.description }}
<!-- AFTER -->
{%- assign mod_i18n = site.data.i18n[site.active_lang].mods[mod.id] -%}
{%- unless mod_i18n -%}{%- assign mod_i18n = site.data.i18n.en.mods[mod.id] -%}{%- endunless -%}
{{ mod_i18n.description | default: mod.description }}
```

Replace mod titles similarly:
```liquid
{{ mod_i18n.title | default: mod.title }}
```

### Step 4.11 — Item components: `_includes/minecraft-mod/wiki/item-components.html`

This file already uses `site.data.i18n.en.components`. Migrate to the `t` pattern:

```liquid
<!-- BEFORE -->
{%- assign components_i18n = site.data.i18n.en.components -%}
<!-- AFTER -->
{%- assign components_i18n = t.components -%}
```

### Step 4.12 — Wiki module content files

These markdown files currently hardcode `site.data.i18n.en.*`:

**Files to update:**
- `minecraft-mod/ubesdelight/wiki/compatibility.md`
- `minecraft-mod/ubesdelight/wiki/translation.md`
- `minecraft-mod/different-doors/wiki/compatibility.md`
- `minecraft-mod/different-doors/wiki/translation.md`
- `minecraft-mod/breezebounce/wiki/translation.md`
- `minecraft-mod/colourfulclocks/wiki/translation.md`

**Pattern change:**
```liquid
<!-- BEFORE -->
{{ site.data.i18n.en.compatibility.legend_label }}
{{ site.data.i18n.en.translation.section_title }}
<!-- AFTER -->
{%- assign t = site.data.i18n[site.active_lang].strings -%}
{%- unless t -%}{%- assign t = site.data.i18n.en.strings -%}{%- endunless -%}
{{ t.compatibility.legend_label }}
{{ t.translation.section_title }}
```

**Note:** These are wiki module `.md` files rendered via `wiki_module_loader.rb` with Liquid. The `t` variable may or may not be available from the parent layout context. If not, each file must assign `t` at its own top. Test this — if `site.active_lang` is available in wiki module rendering, the assignment will work. If not, fall back to `site.data.i18n.en.strings.*` which is functionally equivalent to today's behavior.

---

## Phase 5 — Language Switcher UI

**Depends on:** Phase 4
**Verification:** Language switcher renders in the header. With only `"en"` configured, it is hidden (only shown when `site.languages.size > 1`).

### Step 5.1 — Create `_includes/language-switcher.html`

```liquid
{%- if site.languages.size > 1 -%}
<nav class="language-switcher" aria-label="Language">
  {%- for lang in site.languages -%}
    {%- if lang == site.active_lang -%}
      <span class="language-switcher__current" aria-current="true">{{ lang }}</span>
    {%- else -%}
      <a {% static_href %}href="{% if lang != site.default_lang %}/{{ lang }}{% endif %}{{ page.url }}"{% endstatic_href %} hreflang="{{ lang }}">{{ lang }}</a>
    {%- endif -%}
    {%- unless forloop.last %} • {% endunless -%}
  {%- endfor -%}
</nav>
{%- endif -%}
```

### Step 5.2 — Add SEO i18n headers

In `_layouts/base.html`, add inside `<head>`:

```liquid
{% I18n_Headers %}
```

This generates `<link rel="alternate" hreflang="...">` and `<link rel="canonical">` tags automatically.

### Step 5.3 — Integrate switcher into header

Add `{% include language-switcher.html %}` to the header area in `_layouts/default.html` (or `_includes/header.html`), positioned near the theme toggle or nav links.

---

## Phase 6 — Fallback Page Notice

**Depends on:** Phase 5
**Verification:** When a second language is eventually added, untranslated pages show the notice banner. With English-only, the notice never appears.

### Step 6.1 — Create `_includes/translation-notice.html`

```liquid
{%- if page.rendered_lang and page.rendered_lang != site.active_lang -%}
<div class="translation-notice" role="alert">
  {{ t.fallback.notice | default: "This page is not yet available in your language. Showing English version." }}
</div>
{%- endif -%}
```

### Step 6.2 — Include in base layout

In `_layouts/default.html` (or `_layouts/base.html`), add immediately after the `<main>` opening tag:

```liquid
{% include translation-notice.html %}
```

### Step 6.3 — Add minimal CSS

In the site's main CSS file, add:

```css
.translation-notice {
  background: var(--surface2, #2a2a2a);
  border-left: 4px solid var(--accent, #f59e0b);
  padding: 0.75rem 1rem;
  margin-bottom: 1rem;
  font-size: 0.9rem;
}
```

---

## File-Level Change Summary

### New files
| File | Purpose |
|------|---------|
| `_data/i18n/en/strings.yml` | All translatable UI strings |
| `_data/i18n/en/mods.yml` | Translatable mod titles & descriptions |
| `.lokalise.yml` | Lokalise CLI configuration for push/pull |
| `_includes/language-switcher.html` | Language toggle UI component |
| `_includes/translation-notice.html` | Fallback page notice banner |

### Deleted files
| File | Reason |
|------|--------|
| `_data/i18n/en.yml` | Replaced by `_data/i18n/en/strings.yml` |

### Updated files — Configuration
| File | Changes |
|------|---------|
| `Gemfile` | Add `gem "jekyll-polyglot"` |
| `_config.yml` | Add `languages`, `default_lang`, `exclude_from_localization`, `parallel_localization`, `sass.sourcemap` |
| `_config_debug.yml` | Add `parallel_localization: false` |

### Updated files — Layouts (add `t` assignment + replace hardcoded strings)
| File | ~Strings |
|------|----------|
| `_layouts/default.html` | ~15 |
| `_layouts/home.html` | ~3 |
| `_layouts/recent-updates.html` | ~3 |
| `_layouts/roadmap.html` | ~4 |
| `_layouts/tag_page.html` | ~1 |
| `_layouts/base.html` | ~2 (back-to-top, I18n_Headers) |
| `_layouts/minecraft-mod/page.html` | ~4 |
| `_layouts/minecraft-mod/changelog.html` | ~2 |
| `_layouts/minecraft-mod/roadmap.html` | ~2 |
| `_layouts/minecraft-mod/post/changelog.html` | ~3 |
| `_layouts/minecraft-mod/wiki/base.html` | ~3 |
| `_layouts/minecraft-mod/wiki/recipes.html` | ~5 |

### Updated files — Includes (expect `t` from parent, replace hardcoded strings)
| File | ~Strings |
|------|----------|
| `_includes/header.html` | ~6 |
| `_includes/footer.html` | ~5 |
| `_includes/minecraft-mods.html` | ~7 |
| `_includes/minecraft-mod/wiki/recipe-info.html` | ~8 |
| `_includes/minecraft-mod/wiki/recipe-list.html` | ~5 |
| `_includes/minecraft-mod/wiki/fluid-renderer.html` | ~2 |
| `_includes/minecraft-mod/wiki/item-components.html` | ~4 |
| `_includes/minecraft-mod/wiki/home-section.html` | ~2 |
| `_includes/minecraft-mod/wiki/home-section-compatibility.html` | ~1 |
| `_includes/minecraft-mod/wiki/home-section-translation.html` | ~4 |

### Updated files — Wiki module content (migrate `site.data.i18n.en.*` to `t.*`)
| File |
|------|
| `minecraft-mod/ubesdelight/wiki/compatibility.md` |
| `minecraft-mod/ubesdelight/wiki/translation.md` |
| `minecraft-mod/different-doors/wiki/compatibility.md` |
| `minecraft-mod/different-doors/wiki/translation.md` |
| `minecraft-mod/breezebounce/wiki/translation.md` |
| `minecraft-mod/colourfulclocks/wiki/translation.md` |

### Untouched files
- `_plugins/recipe_generator.rb` — `site.data[mod_id]` access is polyglot-safe
- `_plugins/wiki_module_loader.rb` — no i18n changes
- `lib/recipe_generator/` — all modules unchanged
- `_data/{mod_id}/recipes/` — recipe YAML files
- `_data/{mod_id}/lang/` — item name lang files (`en_us.json`)
- `_data/crafting_types.yml` — kept as fallback
- `_data/mod_buttons.yml` — kept for structural data
- `_data/load_conditions.yml` — kept for tooltip descriptions
- `_data/socials.yml` — brand names, no translation needed
- `.github/workflows/jekyll.yml` — no changes expected

---

## Verification Checklist

After each phase, run `bundle exec jekyll serve` and verify:

- [ ] **Phase 1:** Site builds without errors. No visual changes.
- [ ] **Phase 2:** `site.data.i18n.en.strings.nav.home` returns `"Home"` in a test template.
- [ ] **Phase 3:** `{{ t.nav.home }}` outputs `"Home"` when `t` is assigned in a layout.
- [ ] **Phase 4:** All hardcoded English strings replaced. Site renders identically. Run: `grep -r "\"Home\"\|\"Wiki\"\|\"Changelog\"\|\"Type:\"\|\"mB of\"" _layouts/ _includes/` returns zero false positives.
- [ ] **Phase 4:** Recipe pages render all crafting types, item names, and load conditions correctly.
- [ ] **Phase 4:** Wiki module pages (compatibility, translation) render labels correctly.
- [ ] **Phase 5:** Language switcher is hidden (only `en` configured). Page source contains `<link rel="alternate" hreflang="en">`.
- [ ] **Phase 6:** Translation notice does not appear (all pages are English, `rendered_lang == active_lang`).
- [ ] **Phase 2.5:** Upload `strings.yml` to Lokalise, immediately download, and diff. All keys (including colon-containing ones like `minecraft:crafting_shapeless`) must round-trip identically.
- [ ] **Phase 2.5:** Verify `export_empty_as: base` fills untranslated keys with English values in downloaded files.
- [ ] **Smoke test:** Add `"es"` to `languages` in `_config.yml`, create `_data/i18n/es/strings.yml` with `nav: { home: "Inicio" }`. Verify `/es/` homepage shows "Inicio" in nav, all other strings fall back to English. Then revert.
- [ ] **GitHub Actions:** Push to branch, verify workflow builds successfully.

---

## Adding a New Language (Future Reference)

When ready to add a second language (e.g., Spanish):

1. Add the language in the Lokalise dashboard.
2. Translators work in Lokalise (with key descriptions, screenshots, and `game-terms` tags for context).
3. Run `lokalise2 file download` (or trigger via CI) to pull translated YAML files to `_data/i18n/{lang_code}/`.
4. Add `"{lang_code}"` to the `languages` array in `_config.yml`.
5. The language switcher automatically shows all configured languages.
6. All pages without a `lang:` frontmatter version fall back to English with a translation notice.
7. To create translated pages, add `lang: es` frontmatter. E.g., `about.es.md` with `lang: es`.
8. Blog posts: `_posts/ubesdelight/2024-01-01-update.es.md` with `lang: es`.
9. Commit the downloaded YAML files and updated `_config.yml`, then deploy.

---

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Polyglot interferes with `site.data[mod_id]` access in recipe generator | Verified: polyglot only intercepts `site.data[lang_code]`. Mod data paths (`site.data.ubesdelight`) are unaffected since `ubesdelight` is not a language code. |
| Wiki module `.md` files can't access `site.active_lang` | Test during Phase 4.12. Fallback: keep `site.data.i18n.en.strings.*` directly for wiki modules. |
| `_data/i18n/en.yml` → `_data/i18n/en/` directory restructure breaks existing references | Phase 4.12 migrates all existing `site.data.i18n.en.*` references simultaneously with the file move. |
| SCSS sourcemap breakage with polyglot + Jekyll 4 | `sass: sourcemap: never` added in Phase 1. |
| Windows parallel build issues | `parallel_localization: false` set in Phase 1. |
| Build time increase with multiple languages | Minimal with single language. Monitor when adding second language. |
| Lokalise YAML export strips comments from English source file | Never overwrite `_data/i18n/en/strings.yml` from Lokalise. English is manually maintained in the repo; only non-English files are Lokalise-generated. |
| Colon-containing YAML keys mangle during Lokalise round-trip | Test during Phase 2.5.4 initial upload. Set `convert_placeholders: false`. If keys still break, replace colons with `__` in YAML keys and update template lookups. |
| Translators lack Minecraft domain context for game-specific terms | Tag game-domain keys (`crafting_types`, `load_conditions`, `components`) with `game-terms` in Lokalise. Add key descriptions explaining mod-specific terms. |
| Lokalise export format drift (key ordering, quoting changes) | Pin Lokalise export settings in `.lokalise.yml`. Add a CI step that validates downloaded YAML parses correctly before committing. |
