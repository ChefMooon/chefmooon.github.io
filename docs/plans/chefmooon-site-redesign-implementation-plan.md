# ChefMooon Site Redesign - Implementation Plan

Created: 2026-03-09

## Goal
Implement the proposed visual/system redesign while preserving existing mod/wiki content and avoiding URL regressions.

## Current Site Analysis

### Architecture today
- Theme stack is `jekyll/minima` via `remote_theme` in `_config.yml`.
- Primary layout chain is `_layouts/home.html` -> `_layouts/base.html`.
- Global header/footer are in `_includes/header.html` and `_includes/footer.html`.
- Current styling is centralized in `assets/css/style.scss`, layered on top of Minima imports.
- Homepage (`index.md`) is content-light and rendered by `_layouts/home.html`.

### Data and content today
- Mod metadata source of truth is `_data/minecraft_mods.yml`.
- Homepage mod list is generated from `_includes/minecraft-mods-simple.html` and uses `site.data.minecraft_mods`.
- Mod landing pages already exist as pages under `minecraft-mod/*/*.md` with root-style permalinks such as `/differentdoors/`.
- Wiki/changelog/roadmap URLs are already established under each root-style slug (example: `/differentdoors/wiki/1.21.1/home`).

### Constraints identified
- Existing URLs are already public and should remain stable.
- A full swap to `_mods` without compatibility work would break internal/external links.
- The redesign asks for new layout files (`_layouts/default.html`, `_layouts/mod.html`) and a standalone design system file (`assets/css/main.css`), which can coexist with current files during migration.

## Gap Analysis (Summary -> Current Site)
- Design system: currently absent (style is Minima + custom SCSS, no theme token system).
- Theme toggle: currently absent (no `data-theme` + `localStorage` boot script).
- Fonts: currently no Google font stack matching `Syne`, `Outfit`, `Space Mono`.
- Navigation: currently dropdown-heavy mod menu; not sticky/frosted, no theme toggle, no live Discord badge component.
- Homepage: currently badge-image social links + banner-list mods; not card-based rows.
- Mod content model: currently data-driven from `_data/minecraft_mods.yml`; proposed redesign introduces `_mods` collection.

## Implementation Strategy

### Phase 0 - Decisions and compatibility guardrails (FINALIZED)
1. **URL strategy (DECIDED):** Keep existing canonical root URLs (`/differentdoors/`, `/breezebounce/`, etc.). No URL changes in this phase.
2. **Discord live count source (DECIDED):** Use static placeholder text for now (e.g., "Discord Badge"). Live member count tracking will be implemented in a future phase.
3. **Icons and accent colours (DECIDED):** Use placeholder emoji/generic icon for now. Core styling uses CSS custom properties (`--accent-colour`) to enable easy per-mod colour overrides without layout changes. Real mod icons will replace placeholders in a separate task.
4. **Data model (DECIDED):** `_data/minecraft_mods.yml` remains the single source of truth for all mod metadata. No `_mods/` collection will be created. Presentation fields (icon placeholder, accent colour) are added directly to `minecraft_mods.yml`.

### Phase 1 - Foundation and design system
1. Create `_includes/head-fonts.html` with Google Fonts preconnect + font stylesheet links.
2. Create `_includes/theme-toggle.html` with:
- Toggle markup.
- Early inline head script that reads `localStorage` and sets `<html data-theme="...">` before paint.
3. Create `assets/css/main.css`:
- Root tokens for dark/light (`--bg`, `--surface`, `--surface2`, `--border`, `--text`, `--muted`, `--green`, `--grid-col`).
- Mobile-first spacing, type scale, card primitives.
- Background grid texture (`body::before`).
- Reusable badge/pill/card/nav utilities.
4. Create `_layouts/default.html` as new base layout:
- Include `head-fonts.html` + early theme init script + main stylesheet.
- Add sticky/frosted top nav shell.
- Keep footer minimal and consistent.

### Phase 2 - Homepage redesign
1. Replace current homepage structure in `index.md` + layout usage:
- Hero with `ChefMooon` title + single subtitle line.
- Social pills sourced from new `_data/socials.yml`.
2. Replace current mod banner list with row-style cards:
- Iterate `site.data.minecraft_mods` (existing data source).
- Show placeholder icon, mod title, one-line description, arrow affordance, mod-specific accent colour hover states.
- Each card links to existing canonical mod URL (e.g., `/differentdoors/`) using `mod.id` field.
3. Replace simple recent updates list with card rows:
- Date column, mod+title center, arrow right.
- Hover translation and border accent behavior.

### Phase 3 - Enhance data model for mod cards
1. Update `_data/minecraft_mods.yml` with presentation fields:
- Add `icon_placeholder: "<emoji or generic icon>"` to each mod entry.
- Add `accent_colour: "<hex or CSS var>"` to each mod entry (e.g., `"#a855f7"` for ubes-delight purple).
- Add/update `description: "<one-line description>"` field to each mod entry, suitable for card display (currently placeholder).
2. No changes to URL structure or existing mod landing pages.
3. Homepage will iterate this enhanced `_data/minecraft_mods.yml` to render new card-style mod list.
4. **Out of scope for this plan:** Redesigning individual mod landing pages (e.g., `/differentdoors/`). That will be a separate implementation phase.

### Phase 4 - Navigation implementation
1. Build new nav component in `_layouts/default.html` or include partials:
- Logo wordmark with green-accented suffix.
- Links: Mods, Updates, About.
- Hide selected links below `480px` per spec.
2. Add Discord badge component:
- Pulse indicator + live/member count if data source exists.
3. Add accessible theme toggle behavior:
- Keyboard support and ARIA labels.

### Phase 5 - Validation and regression checks
1. Run local build and smoke test key pages:
- `/`
- `/recent-updates/`
- each mod landing page
- sample wiki/changelog/roadmap pages
2. Confirm no broken links with existing tooling (`htmlproofer` workflow/doc process).
3. Verify mobile-first behavior at `360px`, `480px`, `768px`, `1024px`.
4. Verify theme persistence and no flash on reload.
5. Verify reduced-motion and contrast for accessibility baselines.

## File-Level Change Plan

### New files
- `_includes/head-fonts.html`
- `_includes/theme-toggle.html`
- `_layouts/default.html`
- `assets/css/main.css`
- `_data/socials.yml`

### Updated files
- `_config.yml` (no collection changes needed)
- `index.md` (homepage content/layout reference updates)
- `_data/minecraft_mods.yml` (add `icon_placeholder`, `accent_colour` fields to each mod)

### Files NOT touched in this plan
- Existing mod landing pages under `minecraft-mod/*/*.md` (will be updated in separate phase)
- `_includes/header.html` / `_includes/footer.html` (if nav/footer logic remains include-based)

## Proposed Rollout
1. Complete Phase 0 decisions (already finalized).
2. Merge Phase 1 + Phase 3 together (design system + enhanced data model).
3. Merge Phase 2 (homepage redesign using new data fields and styling).
4. Merge Phase 4 + Phase 5 as hardening before release.

## Risks and Mitigations
- Icon/colour placeholder visibility risk: mitigate by making CSS variables and placeholder fields clearly documented so replacement is straightforward.
- Discord API reliability risk: placeholder text avoids this until live tracking is implemented.
- Browser support risk (`backdrop-filter`): include non-blur fallback background color.
- Data field consistency risk: when adding `icon_placeholder` and `accent_colour` to `minecraft_mods.yml`, ensure all six mods have identical field structure.

## Implementation Checklist
- [x] Decide canonical mod URL policy (→ keep existing root URLs).
- [x] Decide Discord count source (→ static placeholder for now).
- [x] Approve per-mod icon + accent list (→ placeholders; real icons to follow).
- [x] Build design tokens + theme toggle + default layout (Phase 1).
- [x] Enhance `minecraft_mods.yml` with icon/colour fields (Phase 3).
- [x] Redesign homepage sections (Phase 2).
- [x] Build nav component + Discord badge placeholder (Phase 4).
- [x] Run build + responsive + link checks (Phase 5).

## Notes
- This plan intentionally preserves existing wiki/changelog architecture and plugin behavior.
- Redesign work is focused on presentation and navigation layers first, without changing URL routing or mod collection structure.
- All mod metadata lives in a single, authoritative source (`_data/minecraft_mods.yml`). Presentation fields (icon, colour) use CSS variables and placeholders to enable rapid iteration.
- Real mod icons and updated descriptions will be added in a follow-up task after design system is in place.
- Live Discord member count and individual mod page redesigns are explicitly excluded from this plan and scheduled for later phases.