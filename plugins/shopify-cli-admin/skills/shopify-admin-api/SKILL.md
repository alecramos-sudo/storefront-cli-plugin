---
name: shopify-admin-api
description: >
  This skill should be used when the user asks to "run a GraphQL query on my store",
  "query the Shopify Admin API", "export products to CSV", "export orders",
  "export customers", "list products", "get orders", "check inventory",
  "adjust inventory", "create a product", "delete a product",
  "set up my dev store", "initialize dev store",
  "test my Shopify function", "create a test cart", "shopify app execute",
  "shopify app bulk execute", "bulk operation", "bulk export",
  or needs to run any Shopify Admin API GraphQL operation via the CLI.
version: 1.0.0
---

# Shopify Admin API via CLI

## Overview

This skill provides procedural knowledge for executing Shopify Admin API operations
using the Shopify CLI. It covers single queries/mutations via `shopify app execute`
and large-scale data operations via `shopify app bulk execute`.

## Prerequisites

Before running any commands, verify the Shopify CLI is available and the user has
an app context configured:

- Run `shopify version` to confirm CLI is installed
- Check for `shopify.app.toml` or ask the user for their `--client-id` and `--store`
- Confirm target store is a development store before running any mutations

## Core Commands

### Single Query/Mutation: `shopify app execute`

Execute a single GraphQL operation against the Admin API.

**Syntax:**

```bash
# Inline query
shopify app execute --query '{ shop { name id } }' --store STORE_HANDLE

# Query from file
shopify app execute --query-file query.graphql --store STORE_HANDLE

# With variables
shopify app execute --query-file mutation.graphql \
  --variables '{"input": {"title": "New Product"}}' \
  --store STORE_HANDLE

# Save output to file
shopify app execute --query '{ shop { id } }' \
  --store STORE_HANDLE --output-file result.json
```

**Key flags:**

| Flag | Purpose |
|------|---------|
| `--query` / `-q` | Inline GraphQL string |
| `--query-file` | Path to .graphql file |
| `--variables` / `-v` | Inline JSON variables |
| `--variable-file` | Path to JSON variables file |
| `--store` / `-s` | Target store handle |
| `--client-id` | App client ID |
| `--version` | API version (default: latest stable) |
| `--output-file` | Write result to file |

### Bulk Operations: `shopify app bulk execute`

Execute bulk queries for large datasets (>250 items). Avoids pagination and rate limits.

**Syntax:**

```bash
shopify app bulk execute --query '{ products { edges { node { id title } } } }' \
  --store STORE_HANDLE
```

Bulk operations return JSONL (one JSON object per line). Pipe through `jq` for
transformation. See `references/bulk-operations.md` for complete workflow.

## Safety Rules

1. **Mutations require dev stores** — always confirm the target is a dev store before mutations
2. **Confirm destructive operations** — before running delete/update mutations, display the mutation and ask for confirmation
3. **Use bulk for large datasets** — if querying >250 items, recommend bulk execute over paginated single queries
4. **Never hardcode credentials** — use `--store` and `--client-id` flags, never embed tokens

## Operating Modes

### Interactive Mode (Default)

When the user describes what they need in natural language:

1. Identify the GraphQL operation needed (consult `references/graphql-patterns.md`)
2. Construct the query/mutation with appropriate fields
3. Show the constructed query and explain what it does
4. Run via `shopify app execute` after user confirmation
5. Parse and explain the results
6. Offer to refine, export, or build on the results

### Script Generation Mode

Triggered when the user says "generate a script", "make this reusable", "save as script",
or "create a shell script":

1. Wrap the workflow in a bash script with:
   - Shebang and set -euo pipefail
   - Variable declarations for store, client-id, API version
   - Usage function with argument documentation
   - The GraphQL operation(s)
   - Error handling (check exit codes, parse error responses)
   - Output formatting
2. Save to a user-specified location or suggest a sensible default
3. Make executable with `chmod +x`

## Common Workflows

### Ad-hoc Queries
Construct and run single queries. Start simple, refine based on results.
See `references/graphql-patterns.md` for common patterns.

### Bulk Data Export
Export large datasets to CSV. Use `shopify app bulk execute`, transform with jq.
Use the helper script at `${CLAUDE_PLUGIN_ROOT}/scripts/bulk-to-csv.sh`.
See `references/bulk-operations.md` for the full workflow.

### Dev Store Initialization
Create products, set inventory, upload images via scripted mutations.
Generate a setup script that can be re-run for new dev stores.
See the `/shopify-dev-store-init` command for a guided workflow.

### Function Testing
Activate Shopify Functions, create test discounts, generate cart permalinks.
Clean up test data after validation.
See the `/shopify-function-test` command for a guided workflow.

### Dynamic Cart Creation
Query products, build cart permalinks with specific variants for testing.
See the `/shopify-cart-test` command for a guided workflow.

## Additional Resources

### Reference Files

For detailed patterns and techniques, consult:
- **`references/graphql-patterns.md`** — Common Admin API queries and mutations with variables
- **`references/bulk-operations.md`** — Bulk operation workflow, jq transforms, CSV export

### Scripts

- **`${CLAUDE_PLUGIN_ROOT}/scripts/bulk-to-csv.sh`** — Reusable JSONL-to-CSV transform
