# Wiki Home System

This document explains how wiki home pages are rendered, where shared content lives, and how to add version-specific differences without repeating entire files.

## Goals

- Keep one shared source of truth per mod for common wiki home content.
- Keep per-version pages minimal so version navigation still works.
- Allow version-specific differences that only render when present.
- Support structured compatibility and translation tables from YAML data.

## Rendering Flow

1. A versioned page like `minecraft-mod/<mod_id>/wiki/<version>/home.md` is requested.
2. The page uses layout `_layouts/minecraft-mod/wiki/home.html`.
3. The layout loads:
   - `site.data.wiki_home[page.mod_id]` (shared mod wiki-home data)
   - `version_override = wiki_home.version_overrides[page.minecraft_version]` (optional)
4. The layout renders sections in `section_order` using include files.
5. If no data exists for that mod, the layout falls back to `{{ content }}` from the page markdown.

## Why Version `home.md` Files Still Exist

The wiki version dropdown in `_layouts/minecraft-mod/wiki/base.html` builds links based on the current page name and each available Minecraft version. Because of this, each version still needs a corresponding `home.md` file to keep links valid.

These files can now stay as frontmatter-only stubs unless a local note is needed.

## Data Location

- Shared mod wiki-home data: `_data/wiki_home/<mod_id>.yml`
- Example: `_data/wiki_home/ubesdelight.yml`

## Data Contract (High-Level)

Top-level keys in `_data/wiki_home/<mod_id>.yml`:

- `mod_id`
- `announcements`
  - `top: []`
  - `bottom: []`
- `section_order: []`
- `sections: {}`
- `version_overrides: {}`

## Supported Placeholder Tokens

Some section fields support runtime placeholders that are replaced from the current page context:

- `{mod_id}` → current page `mod_id`
- `{version}` → current page `minecraft_version`

Current usage:

- `effects.link_url` in `kind: effects`

### `sections`

Each section is keyed by an ID (for example `features`, `compatibility`) and has a `kind`.

Current section kinds supported by includes:

- `intro`
- `key_values`
- `integrations`
- `development`
- `effects`
- `compatibility`
- `translation`
- `links`
- `text`

### Compatibility Structure (`kind: compatibility`)

- `columns`: list of loader columns (`id`, `label`, optional `url`)
- `rows`: list of Minecraft rows
  - each row has `minecraft`
  - and `loaders` map keyed by column `id`
  - loader values use:
    - `status`: `supported` | `unsupported` | `planned` | `bugfix`
    - optional `version`
    - optional `text`
- `legend`: list of `{ status, label }`
- `notes`: optional markdown notes list

### Translation Structure (`kind: translation`)

- `entries`: list of rows with:
  - `language`
  - `status`
  - `version`
  - `authors`
- optional `closing_text`

## Version-Specific Content

Use `version_overrides` for historical snapshots or release-specific wiki differences.

Example shape:

```yaml
version_overrides:
  "1.21.11":
    announcements:
      top:
        - "Important: Some integrations changed in this version."
      bottom: []
    sections:
      compatibility:
        mode: replace
        kind: compatibility
        title: Compatible Versions
        columns: ...
        rows: ...
      development:
        hide: true
```

### Section Override Rules

For `version_overrides.<version>.sections.<section_id>`:

- `hide: true` → section is skipped.
- `mode: replace` → base section is replaced with override section.

If no override exists for a section, base section content is used.

## Announcement Blocks

Two announcement channels are supported:

1. Data-driven announcements
   - shared: `announcements.top` / `announcements.bottom`
   - per-version: `version_overrides.<version>.announcements.top|bottom`
2. Frontmatter page notes (quick local notes in version page)
   - `wiki_top_note`
   - `wiki_bottom_note`

All announcement blocks render only when content exists.

## Include Files

- `_includes/minecraft-mod/wiki/home-section.html`
  - dispatches by section `kind`
- `_includes/minecraft-mod/wiki/home-section-compatibility.html`
  - compatibility table + legend + notes
  - legend is rendered inline on one line
  - note pipes are normalized so markdown does not treat them as table columns
- `_includes/minecraft-mod/wiki/home-section-translation.html`
  - translation table
- `_includes/minecraft-mod/wiki/home-announcements.html`
  - top/bottom note rendering

## Formatting Rules for YAML Content

- Quote list items that contain `:` to avoid YAML interpreting them as key/value objects.
  - Example: effects bullets like `"Undead Hunger: Immune to ..."`
- Quote long markdown-heavy strings when practical (links, emphasis, symbols).
- For compatibility notes that should begin with a literal asterisk, use `"* ..."`.

## Authoring Workflow

### Add or edit shared wiki-home content

1. Edit `_data/wiki_home/<mod_id>.yml`.
2. Keep section order in `section_order`.
3. Ensure section IDs in `section_order` exist under `sections`.
4. Build site:
   - `bundle exec jekyll build`

### Add version-specific differences

1. Add/update `version_overrides.<minecraft_version>` in the same YAML.
2. Add only the differences (for example compatibility replacement).
3. Optionally add `wiki_top_note` or `wiki_bottom_note` to a specific version `home.md`.

### Add a new mod to this system

1. Create `_data/wiki_home/<new_mod_id>.yml`.
2. Add section data and order.
3. Keep each version `minecraft-mod/<new_mod_id>/wiki/<version>/home.md` present (frontmatter-only is fine).

## Fallback Behavior

If `_data/wiki_home/<mod_id>.yml` does not exist, the layout renders the markdown body of `home.md` as before. This allows gradual migration mod-by-mod.

## Troubleshooting

### YAML parse errors

- Quote values that contain a trailing colon (`:`).
- Prefer quoted strings for markdown-heavy lines.
- Validate indentation carefully (spaces only).

### Section not appearing

- Verify `section_order` contains the section key.
- Verify the key exists under `sections`.
- Check for `hide: true` in a matching version override.

### Version override not applying

- Ensure the override key exactly matches `minecraft_version` string in page frontmatter.
- Example keys: `"1.21.11"`, `"1.20.1"`.

### Effects bullets render like objects (`{"Name"=>"Value"}`)

- Cause: YAML parsed list entries containing `:` as mappings.
- Fix: quote each bullet line in YAML.

### Compatibility note renders as a table

- Cause: markdown interprets `|` as table separators.
- Fix: keep notes in `compatibility.notes`; renderer normalizes separators before markdown conversion.

## Expansion Path: Item Details and Block Details

The same data-driven approach can be applied to Item Details and Block Details pages.

Recommended transition strategy:

1. Introduce mod-scoped data files, for example:
  - `_data/wiki_item_details/<mod_id>.yml`
  - `_data/wiki_block_details/<mod_id>.yml`
2. Keep existing versioned markdown pages as routing stubs (same reason as `home.md`).
3. Add layout-level data loading with optional `version_overrides`.
4. Reuse the same conditional rendering principles:
  - shared base sections
  - version-specific replace/hide behavior
  - render only if content exists
5. Migrate mod-by-mod with fallback to `{{ content }}` during rollout.

## Current Status

- Migrated to this system:
  - Ube's Delight
  - Fright's Delight
  - Breeze Bounce
  - Different Doors
  - Colourful Clocks
  - Playful Planes
- Fright's Delight includes a historical `1.20.1` compatibility override.
