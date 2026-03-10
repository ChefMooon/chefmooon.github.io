# Styling Guide

This guide documents the design system and CSS patterns used in the updated ChefMooon website. Follow these conventions when updating pages to maintain consistency across the site.

## Design System

### Color Tokens

All colors are defined as CSS custom properties (variables) in `assets/css/main.css` and support light/dark theme switching through the `[data-theme="light"]` attribute.

#### Dark Theme (Default)
```css
--bg: #0d0f0e                          /* Background */
--surface: #151918                     /* Surface (cards, dropdowns) */
--surface2: #1c2220                    /* Surface hover state */
--border: #2a3330                      /* Borders */
--text: #e8ede9                        /* Primary text */
--muted: #6b7c72                       /* Secondary text, muted elements */
--green: #4ade80                       /* Accent color (primary interactive) */
--grid-col: rgba(255,255,255,0.03)    /* Background grid texture */
```

#### Light Theme
```css
--bg: #f4f7f5
--surface: #ffffff
--surface2: #edf2ef
--border: #d3ddd7
--text: #1a2420
--muted: #627870
--green: #4ade80                       /* Consistent across themes */
--grid-col: rgba(0,0,0,0.04)
```

### Typography

**Font Families:**
- **UI & Headings**: `'Raleway', sans-serif` (weight: 800 for headings, 400 for body)
- **Monospace/Accent**: `'Space Mono', monospace` (weight: 800 for display, 600 for nav)
- **Body Text**: `'Inter', sans-serif` (for body paragraphs)

**Font Weight Usage:**
- `300`: Subtitle/secondary content
- `400`: Body text
- `600`: Navigation items, mod names
- `800`: Headings, titles, display text

### Spacing

The layout uses rem-based spacing with standard increments:
- `0.25rem` - Minimal gaps, icon spacing
- `0.5rem` - Small padding, tight spacing
- `0.75rem` - Button/chip padding
- `1rem` - Standard component padding
- `1.25rem` - Card padding, section margins
- `2rem` - Section vertical spacing
- `3rem` - Large section spacing
- `4rem` - Full section gaps
- `5rem` - Hero top padding

**Responsive padding:**
- Container: `0 1.5rem` (horizontal padding for max-width 1100px)

### Border Radius

- `6px` - Buttons, small components, nav pills
- `10px` - Cards, icon containers
- `12px` - Dropdowns, large areas
- `20px` - Pill shapes (badges, discord badge)

### Transitions

All interactive elements use consistent transitions:
```css
transition: color 0.2s, background 0.2s;      /* Standard */
transition: all 0.2s;                         /* General */
transition: transform 0.2s;                   /* Movement */
transition: opacity 0.2s, visibility 0.2s;    /* Visibility changes */
```

The standard timing is **0.2s** for most interactions.

---

## Layout Patterns

### Container Pattern

All main content uses a centered container with maximum width and horizontal padding:

```html
<section>
  <div class="container">
    <!-- Content here -->
  </div>
</section>
```

```css
.container {
  max-width: 1100px;
  margin: 0 auto;
  padding: 0 1.5rem;
}
```

### Section Pattern

Standard sections with padding and optional top border:

```html
<section style="padding: 2rem 0;">
  <div class="container">
    <h2 class="section-heading">Section Title</h2>
    <!-- Section content -->
  </div>
</section>

<section style="padding: 2rem 0 4rem;">
  <!-- Last section with extra bottom padding -->
</section>
```

**Section Heading:**
```html
<h2 class="section-heading">Section Title</h2>
```

```css
.section-heading {
  font-family: 'Space Mono', monospace;
  font-size: 1.25rem;
  font-weight: 800;
  color: var(--text);
  margin: 0 0 1rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid var(--border);
}
```

---

## Component Patterns

### Mod Card

Used to display mod information with hover interactions:

```html
<a class="mod-card" href="/mod-id/" style="--accent-colour: #4ade80">
  <div class="mod-card-icon">
    <img src="icon.png" alt="Mod Name icon" class="mod-card-icon-img">
  </div>
  <div class="mod-card-body">
    <p class="mod-card-name">Mod Title</p>
    <p class="mod-card-desc">Description text</p>
  </div>
  <span class="mod-card-arrow">&rarr;</span>
</a>
```

**Key Features:**
- Uses `--accent-colour` custom property for per-card theming
- Icon: 64x64px with 10px border-radius
- Hover effect: left border animation + shadow + arrow movement
- Arrow floats right with transform animation on hover

**CSS Classes:**
```css
.mod-card              /* Container - flex, gap 1rem, padding 1.25rem */
.mod-card-icon         /* Icon wrapper - 64x64, surface2 bg, 10px radius */
.mod-card-icon-img     /* Image - object-fit: contain */
.mod-card-body         /* Flex column content area */
.mod-card-name         /* Space Mono, 1rem, bold */
.mod-card-desc         /* 0.875rem, muted, ellipsis */
.mod-card-arrow        /* 1.25rem, animated on hover */
```

**Hover Effects:**
- Left border slides up from bottom (scaleY animation)
- Border color changes to accent
- Box shadow: `0 4px 20px rgba(0,0,0,0.15)`
- translateY: -1px (slight lift)
- Arrow moves right (+4px) and changes color

### Update Card

Compact card for showing recent updates/posts:

```html
<a class="update-card" href="/post-url/">
  <span class="update-card-date">Mar 10, 2026</span>
  <div>
    <div class="update-card-mod">MOD NAME</div>
    <div class="update-card-title">Version 1.0 - Title</div>
  </div>
  <span class="update-card-arrow">&rarr;</span>
</a>
```

**Layout:**
- Grid: `7rem 1fr auto` (date, content, arrow)
- Padding: `0.875rem 1.25rem`
- Border-radius: `10px`

**Responsive (max-width: 600px):**
- Changes to single column layout
- Date and mod name hidden on mobile

**CSS Classes:**
```css
.update-card              /* Grid container */
.update-card-date         /* 0.75rem, muted, mono font */
.update-card-mod          /* 0.75rem, green color, mono */
.update-card-title        /* 0.9375rem, primary color */
.update-card-arrow        /* Arrow icon */
```

**Hover Effects:**
- translateX: 4px (slide right)
- Background: var(--surface2)

### Social Pills

Colored pill buttons for social links:

```html
<div class="social-pills">
  <a class="social-pill" href="https://discord.gg/..." target="_blank" rel="noopener" 
     style="--pill-color: #5b65ea">
    🎮 Discord
  </a>
</div>
```

**Key Features:**
- Uses `--pill-color` custom property per link
- Border: `1.5px solid var(--pill-color)`
- Transparent background with colored text
- Hover: brightness filter + translateY lift

**CSS Classes:**
```css
.social-pills         /* Flex container, gap 0.5rem, flex-wrap */
.social-pill          /* Pill styling - padding 0.5rem 1rem */
```

**Hover Effects:**
- filter: `brightness(1.2)`
- transform: `translateY(-2px)`

### Navigation Components

#### Main Navbar

```html
<nav class="site-nav-new">
  <div class="container">
    <a href="/" class="nav-logo">
      <img src="logo.png" alt="ChefMooon" class="nav-logo-img" />
      Chef<span class="accent">Mooon</span>
    </a>
    <ul class="nav-links">
      <li class="nav-dropdown">
        <button class="nav-dropdown-trigger" aria-expanded="false">
          Mods
          <svg class="dropdown-arrow"><!-- arrow --></svg>
        </button>
        <div class="nav-dropdown-menu">
          <!-- Dropdown content -->
        </div>
      </li>
      <li><a class="nav-link" href="/path">Link</a></li>
    </ul>
    <div class="nav-actions">
      <a href="https://discord.gg/..." class="discord-badge">
        <span class="discord-pulse"></span>
        <span id="discord-online-count">0 online</span>
      </a>
      {%- include theme-toggle.html -%}
    </div>
    <button class="nav-hamburger" id="mobile-menu-trigger">
      <span></span><span></span><span></span>
    </button>
  </div>
  <div class="mobile-menu" id="mobile-menu">
    <!-- Mobile menu content -->
  </div>
</nav>
```

**Navbar Features:**
- Sticky positioning (top: 0, z-index: 100)
- Backdrop blur glass morphism effect
- Height: 60px

**CSS Classes:**
```css
.site-nav-new             /* Sticky navbar */
.nav-logo                 /* Logo + text, Space Mono 1.25rem */
.nav-logo-img             /* 48px height */
.nav-links                /* Flex list, gap 0.25rem */
.nav-link                 /* Padding 0.5rem 0.75rem */
.nav-dropdown             /* Position: relative container */
.nav-dropdown-trigger     /* Flex, gap 0.375rem, border: none */
.nav-dropdown-menu        /* Absolute, min-width 280px, dropdown animations */
.discord-badge            /* Flex, padding 0.375rem 0.75rem, 1px border */
.discord-pulse            /* 8px circle, pulse animation */
```

#### Mobile Menu (max-width: 767px)

```html
<div class="mobile-menu" id="mobile-menu">
  <div class="mobile-menu-section">
    <button class="mobile-menu-toggle" id="mobile-mods-toggle">
      Mods
      <svg class="mobile-menu-arrow"><!-- arrow --></svg>
    </button>
    <ul class="mobile-submenu" id="mobile-mods-list">
      <li class="mobile-mod-item">
        <button class="mobile-mod-toggle">
          Mod Name
          <svg class="mobile-mod-arrow"><!-- arrow --></svg>
        </button>
        <ul class="mobile-mod-submenu">
          <li><a href="/path">Link</a></li>
        </ul>
      </li>
    </ul>
  </div>
  <a href="/path" class="mobile-menu-link">Link</a>
</div>
```

**Mobile Features:**
- Hidden by default, shows checkbox toggle
- 3-line hamburger animation
- Submenu expansion with smooth transitions
- Full-width menu below navbar

**CSS Classes:**
```css
.nav-hamburger            /* 24x18px, 3 lines, hidden on desktop */
.nav-hamburger.open       /* Animated X state */
.mobile-menu              /* Position absolute, full width */
.mobile-menu.open         /* display: block */
.mobile-menu-toggle       /* Full width button, padding 0.75rem 1.5rem */
.mobile-submenu           /* List with surface2 background */
.mobile-mod-toggle        /* Full width button */
.mobile-mod-submenu       /* Nested submenu with indent */
.mobile-menu-link         /* Full width link item */
```

### Hero Section

```html
<section class="hero">
  <div class="container">
    <h1 class="hero-title">ChefMooon</h1>
    <p class="hero-subtitle">Welcome to ChefMooon's Hub!</p>
    <div class="hero-socials">
      <div class="social-pills">
        <!-- Social links -->
      </div>
    </div>
  </div>
</section>
```

**CSS Classes:**
```css
.hero                     /* padding 5rem 0 3rem, text-align varies */
.hero-title               /* clamp(2.5rem, 6vw, 4rem), Space Mono 800 */
.hero-subtitle            /* 1.125rem, muted, weight 300 */
.hero-socials             /* Display flex for pill layout */
```

**Responsive:**
- Desktop (768px+): text-align left, larger font scaling
- Mobile: text-align center, clamp adjusts font size

### Discord Badge

```html
<a href="https://discord.gg/..." target="_blank" rel="noopener" class="discord-badge">
  <span class="discord-pulse"></span>
  <span id="discord-online-count">42 online</span>
</a>
```

**Features:**
- Shows live member count from Discord API
- Pulse animation on indicator dot
- Updates every 60 seconds

---

## Common Patterns

### Link Styling

```html
<!-- External links with icon/text combination -->
<a href="https://example.com" target="_blank" rel="noopener">Link Text</a>

<!-- Internal relative links -->
<a href="{{ '/path/' | relative_url }}">Link Text</a>

<!-- With icons (emoji or SVG) -->
<a href="https://discord.gg/...">🎮 Discord</a>
```

**Hover Behavior:**
- Color changes from `--muted` to `--text` or to `--green`
- Underline on footer links
- Transform effects on interactive cards

### Flex Layouts

**Standard card/row layout:**
```css
display: flex;
align-items: center;
gap: 1rem;
```

**Column layouts:**
```css
display: flex;
flex-direction: column;
gap: 0.75rem;  /* or 0.5rem for compact */
```

### Button Styling

**Navigation buttons (no background):**
```css
background: none;
border: none;
padding: 0.5rem 0.75rem;
border-radius: 6px;
color: var(--muted);
cursor: pointer;
transition: background 0.2s, color 0.2s;
```

**Hover state:**
```css
&:hover {
  background: var(--surface2);
  color: var(--text);
  /* or color: var(--green) for accent */
}
```

---

## Animations

### Standard Transitions

```css
/* Color/background changes */
transition: color 0.2s, background 0.2s;

/* All properties */
transition: all 0.2s;

/* Transform only */
transition: transform 0.2s;

/* Opacity/visibility */
transition: opacity 0.2s, visibility 0.2s, transform 0.2s;
```

### Dropdown Animation

```css
opacity: 0;
visibility: hidden;
transform: translateY(-4px);
transition: opacity 0.2s, visibility 0.2s, transform 0.2s;

&.open {
  opacity: 1;
  visibility: visible;
  transform: translateY(0);
}
```

### Arrow Rotation

```css
.dropdown-arrow {
  transition: transform 0.2s;
}

&[aria-expanded="true"] .dropdown-arrow {
  transform: rotate(180deg);
}
```

### Pulse Animation

```css
@keyframes pulse {
  0% { transform: scale(1); opacity: 1; }
  50% { transform: scale(1.2); opacity: 0.7; }
  100% { transform: scale(1); opacity: 1; }
}

.discord-pulse {
  animation: pulse 2s infinite;
}
```

---

## Responsive Design

### Breakpoints

**Desktop Navigation:**
- Default: full horizontal nav with dropdowns
- `max-width: 767px`: hide nav-links, show hamburger menu

**Update Cards:**
- Desktop: 3-column grid (`7rem 1fr auto`)
- `max-width: 600px`: single column, hide date

**Dropdown Adjustments:**
- `max-width: 480px`: center dropdown, adjust min-width to 250px

### Mobile-First Approach

**Show mobile elements by default, hide on desktop:**
```css
.nav-hamburger {
  display: none;  /* Hidden on desktop */
}

@media (max-width: 767px) {
  .nav-hamburger {
    display: flex;  /* Shown on mobile */
  }
}
```

**Hide desktop elements on mobile:**
```css
.nav-links {
  display: flex;  /* Shown on desktop */
}

@media (max-width: 767px) {
  .nav-links {
    display: none;  /* Hidden on mobile */
  }
}
```

---

## Footer Pattern

```html
<footer class="site-footer-new">
  <div class="container">
    <p class="footer-text">
      Content © 2026 ChefMooon. <a href="#" class="footer-link">Link</a>
    </p>
  </div>
</footer>
```

**CSS Classes:**
```css
.site-footer-new    /* padding 1.5rem 0, border-top */
.footer-text        /* small text, center aligned, mono font */
.footer-link        /* green color, underline on hover */
```

---

## Accessibility

### ARIA Attributes

```html
<!-- Dropdown indicators -->
<button aria-expanded="false" aria-haspopup="true">Menu</button>

<!-- Mobile menu -->
<button aria-expanded="false" aria-controls="mobile-menu">Hamburger</button>

<!-- Screen reader only content -->
<span class="sr-only">Screen reader text</span>
```

### Semantic HTML

- Use `<nav>` for navigation
- Use `<section>` for content sections
- Use `<footer>` for footer
- Use `<a>` for links, `<button>` for buttons
- Use `<h1>`, `<h2>`, etc. for proper heading hierarchy

### Color Contrast

All text meets WCAG AA standards:
- `--text` on `--bg`: High contrast for readability
- `--muted` on `--surface`: Still readable but lower prominence
- `--green` accents: Sufficient contrast for interactive elements

---

## Working with Themes

The site uses `data-theme` attribute for light/dark switching:

```html
<!-- HTML has data-theme attribute -->
<html data-theme="dark">  <!-- or "light" -->

<!-- CSS targets themes -->
[data-theme="light"] {
  --bg: #f4f7f5;
  /* ... other light theme vars ... */
}
```

When styling:
1. Define variables in `:root` for dark theme
2. Override in `[data-theme="light"]` for light theme
3. Use `var(--name)` throughout CSS
4. Never hardcode colors

---

## Best Practices

### DO:
- Use CSS variables for all colors
- Apply consistent spacing and padding
- Use rem units for sizing
- Use transitions for smooth interactions
- Maintain semantic HTML
- Test on mobile (767px and below)
- Use flex/grid for layouts
- Apply consistent border-radius sizes

### DON'T:
- Hardcode colors (use variables)
- Mix px and rem inconsistently
- Skip transitions on interactive elements
- Forget hover states on buttons/links
- Neglect mobile responsive design
- Override transitions in component states
- Use display: none without responsive thought
- Add custom padding/margins without matching existing spacing

### When Updating Pages:
1. Audit existing styles on the page
2. Identify which component patterns it uses
3. Replace with matching CSS classes from this guide
4. Update spacing to match standard increments
5. Add hover states if missing
6. Test theme switching
7. Test responsiveness at 767px and 600px breakpoints
8. Verify all links work with `relative_url` filter

---

## Updating Existing Pages to the New Theme System

This section documents the workflow and lessons learned from updating the ChefMooon website pages to use the new design system.

### Reference Implementations

**Initial updated pages (use these as templates):**
- [`_layouts/default.html`](_layouts/default.html) — Base layout with new navbar, footer, theme toggle, and main.css integration
- [`_layouts/home.html`](_layouts/home.html) — Home page featuring hero section, mod cards, social pills, and recent updates

Both of these pages implement the design system correctly and serve as reference implementations for updating other pages.

### Update Workflow - 3 Phase Approach

When updating a page to the new theme system, follow this structured 3-phase workflow:

#### Phase 1: Layout Template & Structure (Prerequisite)
- **Objective:** Switch to new layout template and establish semantic HTML structure
- **Key Changes:**
  1. Update frontmatter `layout` to `default` (enables new navbar, footer, main.css automatically)
  2. Wrap content in semantic sections: `<section>` with `<div class="container">`
  3. Use hero section for prominent content: `<section class="hero">` with `.container`
  4. Preserve existing CSS classes for Phase 2 (structure-only update)
- **Why first:** Layout change loads the new design system CSS; all following phases build on this

#### Phase 2: Image & Responsive Styling (Independent)
- **Objective:** Eliminate hardcoded pixel dimensions, implement responsive sizing
- **Key Changes:**
  1. Create responsive image class with `max-width`, `width: 100%`, `height: auto`, `aspect-ratio`
  2. Remove inline `style` attributes (move to CSS classes)
  3. Replace old CSS classes with new design token classes
  4. Add responsive padding/margin using rem units
  5. Wrap images in centered containers using flexbox
- **Common issues:**
  - Aspect ratio distortion: Use `aspect-ratio` property or `object-fit: contain`
  - Hardcoded sizes: Replace `width: 500px` with `max-width: 500px; width: 100%`
  - Inconsistent padding: Use rem increments (1rem, 1.25rem, 2rem)

#### Phase 3: Typography & Theme Tokens (Independent)
- **Objective:** Apply design system colors, fonts, and support light/dark themes
- **Key Changes:**
  1. Apply typography classes: Use `'Inter'` for body text, `'Space Mono'` for headers
  2. Replace hardcoded colors with CSS variables: `var(--text)`, `var(--surface)`, `var(--muted)`
  3. Add hover effects: shadow enhancement + subtle transform (translateY -2px)
  4. Ensure all colors respect theme: Test in both light and dark modes
  5. Update old CSS classes to use new design tokens
- **Common issues:**
  - Theme not switching: Verify all colors use `var(--name)` not hardcoded hex
  - Hover states missing: Add `transition: all 0.2s` and `:hover` effects
  - Contrast problems: Use `var(--muted)` for secondary text on `var(--surface)`

### Parallelization Strategy

- **Phase 1** must run first (prerequisite – enables new CSS system)
- **Phases 2 & 3** can run in parallel (both build on Phase 1, independent of each other)
- After all phases complete: Run full test suite, verify Jekyll build, test both themes

### Practical Example: about.md Update

The `about.md` page was updated following this workflow:

**Phase 1:**
```markdown
---
layout: default    # Changed from "page" to "default"
title: About
permalink: /about/
---

<section class="hero">
  <div class="container">
    <!-- intro text -->
  </div>
</section>

<section class="image">
  <div class="container">
    <!-- old image HTML preserved for Phase 2/3 -->
  </div>
</section>
```

**Phase 2:** Made image responsive
```css
.image-wrapper {
  display: flex;
  justify-content: center;
  padding: 2rem;  /* desktop */
}

@media (max-width: 767px) {
  .image-wrapper { padding: 1.5rem; }
}

.about-image {
  max-width: 500px;
  width: 100%;
  height: auto;
  aspect-ratio: 1;  /* 1:1 square */
  border-radius: 10px;  /* design token */
  object-fit: contain;
}
```

**Phase 3:** Applied typography and theme tokens
```css
.about-intro {
  font-family: 'Inter', sans-serif;
  font-weight: 400;
  color: var(--text);  /* respects theme */
  margin: 0 0 2rem 0;
  line-height: 1.6;
}

.about-image-container {
  background: var(--surface);  /* card background */
  padding: 1.25rem;
  border-radius: 10px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  transition: all 0.2s;
}

.about-image-container:hover {
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
  transform: translateY(-2px);
}
```

### Page Update Checklist

Use this checklist when updating pages to the new theme system:

**Phase 1 Verification:**
- [ ] Layout changed to `default` in frontmatter
- [ ] New navbar appears with logo and navigation
- [ ] New footer appears with proper styling
- [ ] Theme toggle button present and functional
- [ ] Main content renders within `<section class="container">` structure
- [ ] Jekyll build succeeds without errors

**Phase 2 Verification:**
- [ ] All images responsive (100% width on mobile, proper max-width on desktop)
- [ ] No hardcoded pixel dimensions on image elements
- [ ] Aspect ratios maintained (no distortion)
- [ ] Padding/margins use rem units consistently
- [ ] Mobile breakpoints tested (600px, 767px)
- [ ] All old inline `style` attributes removed

**Phase 3 Verification:**
- [ ] All colors use CSS variables (`var(--text)`, `var(--surface)`, etc.)
- [ ] No hardcoded hex, rgb, or named colors
- [ ] Typography uses correct font families ('Inter' for body, 'Space Mono' for headers)
- [ ] Light theme rendering correct (test with theme toggle)
- [ ] Dark theme rendering correct (default)
- [ ] Hover effects present on interactive elements (0.2s transitions)
- [ ] Box shadows and transforms smooth

**Final Verification:**
- [ ] Full test suite passes (no regressions)
- [ ] Jekyll build successful
- [ ] Page renders identically in light and dark themes
- [ ] All links work (especially with `relative_url` filter)
- [ ] Mobile layout tested at 767px and 600px breakpoints
- [ ] No console errors or warnings
- [ ] Responsive images load at correct sizes
- [ ] Theme switching doesn't cause FOUC (flash of unstyled content)

### Common Pitfalls & Solutions

| Problem | Cause | Solution |
|---------|-------|----------|
| Colors don't switch in theme toggle | Hardcoded colors (e.g., `color: #e8ede9` instead of `var(--text)`) | Replace all `#hex`, `rgb()`, named colors with `var(--name)` |
| Image distorts on smaller screens | No aspect-ratio preserved | Add `aspect-ratio: W / H` or use `object-fit` property |
| Spacing inconsistent with design | Mix of px and rem units | Use only rem: 1rem, 1.25rem, 1.5rem, 2rem, etc. |
| Hover effects missing on mobile | Transitions not applied | Add `transition: all 0.2s` to interactive elements |
| Mobile menu broken on small screens | Breakpoints misaligned | Use 767px (nav) and 600px (cards) breakpoints consistently |
| Old page layout appears briefly | Frontmatter layout incorrect | Verify frontmatter uses `layout: default` not old layout name |
| Background color wrong on card | Using wrong variable | Use `var(--surface)` for card bg, `var(--bg)` for page bg |

### Testing Strategy

1. **Desktop Testing:**
   - Test at 1200px+ resolution
   - Hover/interaction states work smoothly
   - Spacing matches design system

2. **Mobile Testing:**
   - Test at 600px (card breakpoint)
   - Test at 767px (navigation breakpoint)
   - Test at under 300px (extreme mobile)
   - Touch interactions work (buttons, links)

3. **Theme Testing:**
   - Toggle between light/dark themes
   - No FOUC occurs
   - Text contrast readable in both
   - Images/shadows visible in both themes

4. **Regression Testing:**
   - Full test suite passes
   - No broken links
   - No console errors
   - Navigation and footer work
   - All components render correctly

### Tools & Resources

- **Testing:** Run full test suite with `ruby run_tests.rb`
- **Local preview:** Start Jekyll with `bundle exec jekyll serve`
- **Theme toggle:** Use browser DevTools to inspect `[data-theme]` attribute
- **Responsive debugging:** Use Chrome DevTools device emulation at 600px, 767px
- **CSS inspection:** Use DevTools to verify `var(--name)` values in computed styles

---

## File References

- **Main CSS**: [`assets/css/main.css`](../assets/css/main.css)
- **Layout template**: [`_layouts/default.html`](_layouts/default.html)
- **Home page example**: [`_layouts/home.html`](_layouts/home.html)
- **Config**: `_config.yml` (theme, plugins)
- **Page update plan**: [`docs/plans/about-page-theme-update-plan.md`](plans/about-page-theme-update-plan.md)
- **About page (example)**: [`about.md`](../../about.md)
