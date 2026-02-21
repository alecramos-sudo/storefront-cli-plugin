# Storefront CLI Plugins

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) plugin collection for Shopify Admin API development. Provides conversational access to the Admin API through the Shopify CLI — run GraphQL queries, bulk export data, set up dev stores, test functions, and create test carts, all through natural language.

> **Disclaimer:** This project is not affiliated with, endorsed by, or sponsored by Shopify Inc. or Anthropic. "Shopify" and "Claude" are registered trademarks of their respective owners. This is an independent community project.

Inspired by the [`shopify app execute` and `shopify app bulk execute` features](https://community.shopify.dev/t/admin-api-and-bulk-operations-in-shopify-cli/29467) introduced in Shopify CLI 3.90.1.

## Installation

### Prerequisites

- [Claude Code](https://code.claude.com/docs/en/quickstart) v1.0.33+ (`claude --version` to check)
- [Shopify CLI](https://shopify.dev/docs/api/shopify-cli) **3.90.1+** (`shopify version` to verify) — requires the `app execute` and `app bulk execute` commands
- A Shopify app with Admin API access (`shopify.app.toml` configured)
- `jq` (for bulk export CSV transformations)

### Add the marketplace

From within Claude Code, add this repository as a plugin marketplace:

```
/plugin marketplace add alecramos-sudo/storefront-cli-plugins
```

### Install the plugin

```
/plugin install shopify-cli-admin@alecramos-sudo-storefront-cli-plugins
```

Or browse available plugins interactively with `/plugin` and go to the **Discover** tab.

### Local development

To test the plugin locally without installing from a marketplace:

```bash
claude --plugin-dir ./plugins/shopify-cli-admin
```

## Plugins

### shopify-cli-admin

Conversational Shopify Admin API access via `shopify app execute` and bulk operations.

#### Commands

| Command | Description |
|---------|-------------|
| `/shopify-cli-admin:shopify-query` | Run an ad-hoc GraphQL query against the Admin API |
| `/shopify-cli-admin:shopify-bulk-export` | Export large datasets (products, orders, customers) to CSV |
| `/shopify-cli-admin:shopify-dev-store-init` | Set up a dev store with products, inventory, and images |
| `/shopify-cli-admin:shopify-function-test` | Activate and test Shopify Functions without a UI |
| `/shopify-cli-admin:shopify-cart-test` | Create test carts with specific products |

#### Examples

```
> /shopify-cli-admin:shopify-query list all products with their prices
> /shopify-cli-admin:shopify-bulk-export products
> /shopify-cli-admin:shopify-dev-store-init 10 products with 3 variants each
> /shopify-cli-admin:shopify-function-test my-discount-function
> /shopify-cli-admin:shopify-cart-test 3 products over $50
```

## Demo Walkthrough

A step-by-step walkthrough using a real Shopify dev store. Run these inside Claude Code with the plugin loaded.

### 0. Setup — connect to your store

If you don't have a Shopify app configured yet, create one in the Partner Dashboard and get your client ID. Then verify your CLI is working:

```
/shopify-cli-admin:shopify-query what's the shop name?
```

Claude will run `shopify app execute --query '{ shop { name id } }'` and prompt you for your store handle if needed. You should see your store's name in the response.

### 1. Query products

```
/shopify-cli-admin:shopify-query list the first 5 products with title, price, and inventory
```

### 2. Search for specific products

```
/shopify-cli-admin:shopify-query find products with "shirt" in the title
```

### 3. Check a single order

```
/shopify-cli-admin:shopify-query show me the most recent order with line items and shipping address
```

### 4. Bulk export products to CSV

```
/shopify-cli-admin:shopify-bulk-export products
```

This runs a bulk operation, waits for completion, downloads the JSONL, and transforms it to CSV using the included `bulk-to-csv.sh` script.

### 5. Create a test cart

```
/shopify-cli-admin:shopify-cart-test 2 products
```

Claude will query your store for products, pick variants, and generate a cart permalink URL you can open in a browser.

### 6. Initialize a dev store with sample data

```
/shopify-cli-admin:shopify-dev-store-init 3 products with 2 variants each
```

Claude will generate `productCreate` mutations and execute them one by one, reporting each created product.

## Project Structure

```
.claude-plugin/
  marketplace.json            # Plugin registry manifest
plugins/
  shopify-cli-admin/
    .claude-plugin/
      plugin.json             # Plugin manifest
    commands/                 # Slash command definitions
      shopify-query.md
      shopify-bulk-export.md
      shopify-dev-store-init.md
      shopify-function-test.md
      shopify-cart-test.md
    skills/
      shopify-admin-api/
        SKILL.md              # Core skill (procedural knowledge)
        references/
          graphql-patterns.md # Common Admin API query/mutation patterns
          bulk-operations.md  # Bulk operation workflows and jq transforms
    scripts/
      bulk-to-csv.sh          # JSONL-to-CSV transformer for bulk exports
tests/
  test_plugin_structure.bats  # Plugin structure and manifest tests
  test_bulk_to_csv.bats       # bulk-to-csv.sh functional tests
  fixtures/                   # Test data (JSONL fixtures)
```

## Running Tests

Tests use [Bats](https://github.com/bats-core/bats-core) (Bash Automated Testing System).

```bash
# Install bats (macOS)
brew install bats-core

# Run all tests
bats tests/

# Run specific test file
bats tests/test_plugin_structure.bats
bats tests/test_bulk_to_csv.bats
```

## Safety

The plugin enforces safety rules for Shopify API operations:

- **Mutations require dev stores** — always confirms the target is a development store
- **Destructive operations require confirmation** — delete/update mutations are shown before execution
- **Bulk for large datasets** — recommends bulk operations for >250 items
- **No hardcoded credentials** — uses CLI flags, never embeds tokens

## License

MIT
