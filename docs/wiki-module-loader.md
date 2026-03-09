# Wiki Module Loader

This document explains what `_plugins/wiki_module_loader.rb` does and how wiki home pages consume modular markdown content.

## Purpose

`wiki_module_loader.rb` loads shared wiki section content from markdown files so each mod wiki home page does not need duplicated prose across Minecraft versions.

It targets pages using layout `minecraft-mod/wiki/home`.

## What It Loads

For a page like:
- `minecraft-mod/ubesdelight/wiki/1.21.1/home.md`

The plugin resolves modules from:
1. `minecraft-mod/ubesdelight/wiki/1.21.1/{module}.md` (version override)
2. `minecraft-mod/ubesdelight/wiki/{module}.md` (shared fallback)

Examples of module names:
- `intro`
- `features`
- `effects`
- `mod_integrations`
- `development`
- `compatibility`
- `translation`
- `links`

## Module Order

Module order is resolved in this order:
1. `page.wiki_module_order` in frontmatter (if present)
2. Legacy order from `_data/wiki_home/{mod_id}.yml` (if present)
3. Auto-discovery of module files in the mod wiki root, sorted with preferred defaults first

## Build-Time Behavior

During site generation the plugin:
1. Finds wiki home pages.
2. Resolves module file path (override first, then shared).
3. Reads module markdown.
4. Renders Liquid in module content using current page/site context.
5. Stores results in `page.wiki_modules`.

Each entry in `page.wiki_modules` includes:
- `id`
- `path`
- `is_override`
- `content`

## How Layout Uses It

`_layouts/minecraft-mod/wiki/home.html` checks `page.wiki_modules` and renders each module as markdown.

If no modules are found, the layout can still fall back to existing page content behavior.

## Reserved Filenames

The plugin ignores these base names when auto-discovering modules:
- `home`
- `recipes`
- `item-details`
- `block-details`
- `translations-overview`

## Notes

- The plugin is intentionally separate from `recipe_generator.rb` to keep concerns isolated.
- Liquid rendering errors are logged and the raw markdown is used as fallback.
- This system supports per-version wiki customization without duplicating shared sections.
