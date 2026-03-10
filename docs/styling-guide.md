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

## File References

- **Main CSS**: [`assets/css/main.css`](../assets/css/main.css)
- **Layout template**: [`_layouts/default.html`](_layouts/default.html)
- **Home page example**: [`_layouts/home.html`](_layouts/home.html)
- **Config**: `_config.yml` (theme, plugins)
