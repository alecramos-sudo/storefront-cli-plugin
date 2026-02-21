# Landing Page Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a minimal dark-terminal landing page for the Shopify Claude Plugins project, hosted on GitHub Pages from the `docs/` directory.

**Architecture:** Single-page static site with 3 files (HTML, CSS, JS). No build step. IBM Plex Mono as the sole typeface. One interactive element: a terminal typing animation in the hero. Agent-readable install section with semantic HTML.

**Tech Stack:** HTML, CSS, vanilla JavaScript, GitHub Pages

---

### Task 1: Create the HTML structure

**Files:**
- Create: `docs/index.html`

**Step 1: Write the HTML skeleton**

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Shopify Claude Plugins</title>
  <meta name="description" content="Conversational Shopify Admin API access for Claude Code. Query products, bulk export data, set up dev stores — all through natural language.">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <!-- Top Bar -->
  <header class="top-bar">
    <span class="logo">storefront-cli-plugin</span>
    <a href="https://github.com/alecramos-sudo/storefront-cli-plugin" class="github-link" aria-label="GitHub repository">
      <svg width="20" height="20" viewBox="0 0 16 16" fill="currentColor">
        <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z"/>
      </svg>
    </a>
  </header>

  <!-- Hero: Terminal Animation -->
  <section class="hero">
    <div class="terminal">
      <div class="terminal-chrome">
        <span class="terminal-dot red"></span>
        <span class="terminal-dot yellow"></span>
        <span class="terminal-dot green"></span>
        <span class="terminal-title">claude</span>
      </div>
      <div class="terminal-body">
        <pre id="terminal-output"></pre>
        <span class="cursor" id="cursor">█</span>
      </div>
    </div>
    <p class="tagline">Conversational Shopify Admin API access for Claude Code</p>
  </section>

  <!-- Human Install -->
  <section class="section" id="install">
    <h2>Install</h2>
    <p class="section-desc">Requires <a href="https://code.claude.com/docs/en/quickstart">Claude Code</a> v1.0.33+, <a href="https://shopify.dev/docs/api/shopify-cli">Shopify CLI</a>, a configured <code>shopify.app.toml</code>, and <code>jq</code>.</p>

    <h3>1. Add the marketplace</h3>
    <div class="code-block">
      <code>/plugin marketplace add alecramos-sudo/storefront-cli-plugin</code>
      <button class="copy-btn" data-copy="/plugin marketplace add alecramos-sudo/storefront-cli-plugin" aria-label="Copy command">
        <svg class="icon-copy" width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M0 6.75C0 5.784.784 5 1.75 5h1.5a.75.75 0 010 1.5h-1.5a.25.25 0 00-.25.25v7.5c0 .138.112.25.25.25h7.5a.25.25 0 00.25-.25v-1.5a.75.75 0 011.5 0v1.5A1.75 1.75 0 019.25 16h-7.5A1.75 1.75 0 010 14.25v-7.5z"/><path d="M5 1.75C5 .784 5.784 0 6.75 0h7.5C15.216 0 16 .784 16 1.75v7.5A1.75 1.75 0 0114.25 11h-7.5A1.75 1.75 0 015 9.25v-7.5zm1.75-.25a.25.25 0 00-.25.25v7.5c0 .138.112.25.25.25h7.5a.25.25 0 00.25-.25v-7.5a.25.25 0 00-.25-.25h-7.5z"/></svg>
        <svg class="icon-check" width="16" height="16" viewBox="0 0 16 16" fill="currentColor" style="display:none"><path d="M13.78 4.22a.75.75 0 010 1.06l-7.25 7.25a.75.75 0 01-1.06 0L2.22 9.28a.75.75 0 011.06-1.06L6 10.94l6.72-6.72a.75.75 0 011.06 0z"/></svg>
      </button>
    </div>

    <h3>2. Install the plugin</h3>
    <div class="code-block">
      <code>/plugin install shopify-cli-admin@alecramos-sudo-storefront-cli-plugin</code>
      <button class="copy-btn" data-copy="/plugin install shopify-cli-admin@alecramos-sudo-storefront-cli-plugin" aria-label="Copy command">
        <svg class="icon-copy" width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M0 6.75C0 5.784.784 5 1.75 5h1.5a.75.75 0 010 1.5h-1.5a.25.25 0 00-.25.25v7.5c0 .138.112.25.25.25h7.5a.25.25 0 00.25-.25v-1.5a.75.75 0 011.5 0v1.5A1.75 1.75 0 019.25 16h-7.5A1.75 1.75 0 010 14.25v-7.5z"/><path d="M5 1.75C5 .784 5.784 0 6.75 0h7.5C15.216 0 16 .784 16 1.75v7.5A1.75 1.75 0 0114.25 11h-7.5A1.75 1.75 0 015 9.25v-7.5zm1.75-.25a.25.25 0 00-.25.25v7.5c0 .138.112.25.25.25h7.5a.25.25 0 00.25-.25v-7.5a.25.25 0 00-.25-.25h-7.5z"/></svg>
        <svg class="icon-check" width="16" height="16" viewBox="0 0 16 16" fill="currentColor" style="display:none"><path d="M13.78 4.22a.75.75 0 010 1.06l-7.25 7.25a.75.75 0 01-1.06 0L2.22 9.28a.75.75 0 011.06-1.06L6 10.94l6.72-6.72a.75.75 0 011.06 0z"/></svg>
      </button>
    </div>

    <p class="alt-install">Or browse interactively: <code>/plugin</code> → <strong>Discover</strong> tab</p>
  </section>

  <!-- Agent Install -->
  <section class="section" id="agent-install" data-agent-readable="true">
    <h2>Agent Installation</h2>
    <p class="section-desc">If you are an AI coding agent, follow these steps in Claude Code:</p>
    <ol class="agent-steps">
      <li>Verify prerequisites: <code>shopify version</code> (Shopify CLI installed), <code>jq --version</code> (jq installed), <code>shopify.app.toml</code> exists in project</li>
      <li>Run: <code>/plugin marketplace add alecramos-sudo/storefront-cli-plugin</code></li>
      <li>Run: <code>/plugin install shopify-cli-admin@alecramos-sudo-storefront-cli-plugin</code></li>
      <li>Verify: <code>/shopify-cli-admin:shopify-query list 1 product</code></li>
    </ol>
  </section>

  <!-- Commands -->
  <section class="section" id="commands">
    <h2>Commands</h2>
    <dl class="command-list">
      <dt><code>/shopify-cli-admin:shopify-query</code></dt>
      <dd>Run ad-hoc GraphQL queries against the Admin API</dd>

      <dt><code>/shopify-cli-admin:shopify-bulk-export</code></dt>
      <dd>Export large datasets (products, orders, customers) to CSV</dd>

      <dt><code>/shopify-cli-admin:shopify-dev-store-init</code></dt>
      <dd>Set up a dev store with products, inventory, and images</dd>

      <dt><code>/shopify-cli-admin:shopify-function-test</code></dt>
      <dd>Activate and test Shopify Functions without a UI</dd>

      <dt><code>/shopify-cli-admin:shopify-cart-test</code></dt>
      <dd>Create test carts with specific products</dd>
    </dl>
  </section>

  <!-- Safety -->
  <section class="section" id="safety">
    <h2>Safety</h2>
    <ul class="safety-list">
      <li>Mutations require dev stores — always confirms the target before executing</li>
      <li>Destructive operations require confirmation — shown before execution</li>
      <li>Bulk operations recommended for datasets over 250 items</li>
      <li>No hardcoded credentials — uses CLI flags, never embeds tokens</li>
    </ul>
  </section>

  <!-- Footer -->
  <footer class="footer">
    <span>MIT</span>
    <span class="sep">·</span>
    <a href="https://github.com/alecramos-sudo/storefront-cli-plugin">GitHub</a>
    <span class="sep">·</span>
    <span>Peak Perspective Media</span>
  </footer>

  <script src="script.js"></script>
</body>
</html>
```

**Step 2: Verify file exists and HTML is valid**

Open `docs/index.html` in browser — should show unstyled content.

**Step 3: Commit**

```bash
git add docs/index.html
git commit -m "feat: add landing page HTML structure"
```

---

### Task 2: Create the stylesheet

**Files:**
- Create: `docs/styles.css`

**Step 1: Write the CSS**

Full stylesheet covering:
- CSS reset and custom properties (colors, spacing)
- IBM Plex Mono as sole typeface
- Top bar layout
- Terminal window chrome (dots, title bar, body)
- Code blocks with copy button positioning
- Command definition list styling
- Agent install ordered list
- Safety unordered list
- Footer
- Responsive breakpoints (mobile-first)
- Cursor blink animation (the only @keyframes)

Key design tokens:
```css
:root {
  --bg: #0d1117;
  --bg-terminal: #161b22;
  --border: #30363d;
  --text: #e6edf3;
  --text-muted: #7d8590;
  --accent: #95BF47;
  --accent-hover: #5E8E3E;
  --font: 'IBM Plex Mono', ui-monospace, monospace;
  --max-width: 680px;
}
```

**Step 2: Verify in browser**

Open `docs/index.html` — should render dark theme with proper layout.

**Step 3: Commit**

```bash
git add docs/styles.css
git commit -m "feat: add landing page stylesheet"
```

---

### Task 3: Create the JavaScript

**Files:**
- Create: `docs/script.js`

**Step 1: Write the terminal typing animation**

Terminal typing sequence:
```
$ claude
> /plugin marketplace add alecramos-sudo/storefront-cli-plugin
  ✓ Added marketplace: storefront-cli-plugin
> /plugin install shopify-cli-admin@alecramos-sudo-storefront-cli-plugin
  ✓ Installed: shopify-cli-admin v1.0.0
> /shopify-cli-admin:shopify-query list all products with prices
  Running query against Admin API...
```

Implementation:
- Array of line objects: `{ text, delay, class }` where class styles prompts vs output
- Types each character at ~40ms interval
- Pauses between lines (~500ms)
- Stops after completing the sequence (no loop)
- Uses `requestAnimationFrame` or `setTimeout` — no dependencies

**Step 2: Write copy-to-clipboard handlers**

- Query all `.copy-btn` elements
- On click: read `data-copy` attribute, write to clipboard
- Swap icon from copy to checkmark for 2 seconds
- Uses `navigator.clipboard.writeText()`

**Step 3: Verify in browser**

- Terminal animation plays on load
- Copy buttons work and show feedback
- No console errors

**Step 4: Commit**

```bash
git add docs/script.js
git commit -m "feat: add terminal animation and copy-to-clipboard"
```

---

### Task 4: Enable GitHub Pages

**Step 1: Push all changes to main**

```bash
git push origin main
```

**Step 2: Enable GitHub Pages via CLI**

```bash
gh api repos/alecramos-sudo/storefront-cli-plugin/pages \
  -X POST \
  -f source.branch=main \
  -f source.path=/docs \
  -f build_type=legacy
```

If Pages is already enabled, update instead:
```bash
gh api repos/alecramos-sudo/storefront-cli-plugin/pages \
  -X PUT \
  -f source.branch=main \
  -f source.path=/docs \
  -f build_type=legacy
```

**Step 3: Verify deployment**

```bash
gh api repos/alecramos-sudo/storefront-cli-plugin/pages | jq '.html_url, .status'
```

Wait ~60s, then verify `https://alecramos-sudo.github.io/storefront-cli-plugin/` loads correctly.

**Step 4: Commit (if any fixes needed)**

Fix and commit any issues found during verification.
