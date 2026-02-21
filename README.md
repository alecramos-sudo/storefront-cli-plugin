# Shopify Claude Plugins

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) plugin collection for Shopify development. Provides conversational access to the Shopify Admin API through the Shopify CLI — run GraphQL queries, bulk export data, set up dev stores, test functions, and create test carts, all through natural language.

## Installation

Install the plugin from within Claude Code:

```
/install-plugin https://github.com/alecramosnv/shopify-claude-plugins
```

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- [Shopify CLI](https://shopify.dev/docs/api/shopify-cli) (`shopify version` to verify)
- A Shopify app with Admin API access (`shopify.app.toml` configured)
- `jq` (for bulk export CSV transformations)

## Plugins

### shopify-cli-admin

Conversational Shopify Admin API access via `shopify app execute` and bulk operations.

#### Commands

| Command | Description |
|---------|-------------|
| `/shopify-query` | Run an ad-hoc GraphQL query against the Admin API |
| `/shopify-bulk-export` | Export large datasets (products, orders, customers) to CSV |
| `/shopify-dev-store-init` | Set up a dev store with products, inventory, and images |
| `/shopify-function-test` | Activate and test Shopify Functions without a UI |
| `/shopify-cart-test` | Create test carts with specific products |

#### Examples

```
> /shopify-query list all products with their prices
> /shopify-bulk-export products
> /shopify-dev-store-init 10 products with 3 variants each
> /shopify-function-test my-discount-function
> /shopify-cart-test 3 products over $50
```

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
