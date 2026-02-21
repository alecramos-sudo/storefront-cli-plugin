# Storefront CLI Plugins — Landing Page Design

## Overview

A public landing page for the storefront-cli-plugins project, hosted on GitHub Pages. Serves as both a human-readable documentation site and an agent-readable install reference.

## Hosting

- **Platform**: GitHub Pages from `docs/` directory on `main` branch
- **URL**: `alecramos-sudo.github.io/storefront-cli-plugins`
- **Custom domain**: None initially (can add later via CNAME)

## File Structure

```
docs/
  index.html      # Main landing page
  styles.css      # Stylesheet
  script.js       # Terminal typing animation + copy-to-clipboard
```

No build step. Pure HTML/CSS/JS.

## Visual Design

### Aesthetic

Minimal dark terminal — inspired by arscontexta.org. Information-dense, typographically controlled, one strong interactive element (the hero terminal animation).

### Color Palette

| Token            | Value       | Usage                           |
|------------------|-------------|---------------------------------|
| bg-primary       | `#0d1117`   | Page background                 |
| bg-terminal      | `#161b22`   | Terminal window background      |
| border           | `#30363d`   | Terminal chrome, dividers       |
| text-primary     | `#e6edf3`   | Body text                       |
| text-secondary   | `#7d8590`   | Descriptions, muted text        |
| accent           | `#95BF47`   | Shopify green — links, cursor, CTA |
| accent-dark      | `#5E8E3E`   | Hover states                    |

### Typography

Full monospace page: `IBM Plex Mono` (loaded from Google Fonts) as the sole typeface. Hierarchy through weight (400/600/700) and spacing, not font changes.

### Background

Flat `#0d1117` — no patterns, no effects, no noise.

## Layout (Top to Bottom)

### 1. Top Bar
- Project name in monospace (left)
- GitHub icon link (right)
- No navigation — it's a single-page site

### 2. Hero
- Simulated terminal window with typing animation
- Terminal types out the install sequence:
  ```
  $ claude
  > /plugin marketplace add alecramos-sudo/storefront-cli-plugins
    Added marketplace: storefront-cli-plugins
  > /plugin install shopify-cli-admin@alecramos-sudo-storefront-cli-plugins
    Installed: shopify-cli-admin v1.0.0
  > /shopify-cli-admin:shopify-query list all products with prices
    Running query against Admin API...
  ```
- Below terminal: one-line tagline — "Conversational Shopify Admin API access for Claude Code"

### 3. Install — Human

Prerequisites listed, then two copy-to-clipboard command blocks:
1. Add the marketplace
2. Install the plugin

Also mentions local dev option (`claude --plugin-dir`).

### 4. Install — Agent

Semantic HTML section with `data-agent-readable="true"` attribute. Plain-text numbered steps an AI agent can follow. Includes prerequisites check commands.

### 5. Commands

Simple list — each command name in monospace bold, one-line description below. No cards, no grid. The 5 commands:
- `shopify-query` — Run ad-hoc GraphQL queries
- `shopify-bulk-export` — Export large datasets to CSV
- `shopify-dev-store-init` — Set up dev store with products
- `shopify-function-test` — Test Shopify Functions
- `shopify-cart-test` — Create test carts

### 6. Safety

Brief section noting: mutations require dev stores, destructive ops need confirmation, bulk for large datasets, no hardcoded credentials.

### 7. Footer

MIT license | GitHub link | Peak Perspective Media

## Interactive Elements

- **Terminal typing animation**: The only animation. Slow, deliberate typing with a blinking cursor. Loops or stops after completing the sequence.
- **Copy-to-clipboard**: Buttons on command blocks. Visual feedback on copy (checkmark replaces icon briefly).

## Agent Readability

The agent install section uses semantic HTML so that LLMs fetching the page can parse install instructions directly. No critical information is hidden behind JS interactions.

## Responsive

Mobile-friendly: terminal scales down, text reflows. No horizontal scroll.
