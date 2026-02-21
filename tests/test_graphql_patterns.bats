#!/usr/bin/env bats

# Validate GraphQL patterns in reference docs are well-formed

REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
PATTERNS="$REPO_ROOT/plugins/shopify-cli-admin/skills/shopify-admin-api/references/graphql-patterns.md"
BULK_OPS="$REPO_ROOT/plugins/shopify-cli-admin/skills/shopify-admin-api/references/bulk-operations.md"

# Helper: extract all ```graphql code blocks from a file
extract_graphql_blocks() {
  awk '/^```graphql$/{ capture=1; next } /^```$/{ if(capture) { print "---BLOCK---"; capture=0 } next } capture{ print }' "$1"
}

# Helper: check balanced braces in a string
check_balanced_braces() {
  local text="$1"
  local open close
  open=$(echo "$text" | tr -cd '{' | wc -c | tr -d ' ')
  close=$(echo "$text" | tr -cd '}' | wc -c | tr -d ' ')
  [ "$open" -eq "$close" ]
}

# Helper: check balanced parens in a string
check_balanced_parens() {
  local text="$1"
  local open close
  open=$(echo "$text" | tr -cd '(' | wc -c | tr -d ' ')
  close=$(echo "$text" | tr -cd ')' | wc -c | tr -d ' ')
  [ "$open" -eq "$close" ]
}

# --- GraphQL blocks have balanced braces ---

@test "graphql-patterns.md: all GraphQL blocks have balanced braces" {
  local blocks block
  blocks=$(extract_graphql_blocks "$PATTERNS")
  local IFS_OLD="$IFS"
  echo "$blocks" | while IFS= read -r line; do
    if [ "$line" = "---BLOCK---" ]; then
      if [ -n "${block:-}" ]; then
        check_balanced_braces "$block"
        check_balanced_parens "$block"
      fi
      block=""
    else
      block="${block:-}${line} "
    fi
  done
  # Check the last block
  if [ -n "${block:-}" ]; then
    check_balanced_braces "$block"
    check_balanced_parens "$block"
  fi
}

@test "bulk-operations.md: all GraphQL blocks have balanced braces" {
  local blocks block
  blocks=$(extract_graphql_blocks "$BULK_OPS")
  echo "$blocks" | while IFS= read -r line; do
    if [ "$line" = "---BLOCK---" ]; then
      if [ -n "${block:-}" ]; then
        check_balanced_braces "$block"
        check_balanced_parens "$block"
      fi
      block=""
    else
      block="${block:-}${line} "
    fi
  done
  if [ -n "${block:-}" ]; then
    check_balanced_braces "$block"
    check_balanced_parens "$block"
  fi
}

# --- GraphQL blocks contain expected query structure ---

@test "graphql-patterns.md: queries use connection pattern or single-resource lookup" {
  # Every GraphQL block should contain edges/node (connections), mutation keyword,
  # or a single-resource query pattern (product/order/customer/location by id)
  local failed=0
  while IFS= read -r block; do
    if ! echo "$block" | grep -qE '(edges|node|mutation|deletedProductId|product\(id:|order\(id:|customer\(id:|location\(id:)'; then
      echo "Block missing expected pattern: $block" >&2
      failed=1
    fi
  done < <(awk '/^```graphql$/{ capture=1; block="" ; next } /^```$/{ if(capture) { print block; capture=0 } next } capture{ block=block " " $0 }' "$PATTERNS")
  [ "$failed" -eq 0 ]
}

@test "graphql-patterns.md: mutations include userErrors field" {
  # Every mutation block should request userErrors for proper error handling
  awk '/^```graphql$/{ capture=1; block="" ; next } /^```$/{ if(capture) { print block; capture=0 } next } capture{ block=block " " $0 }' "$PATTERNS" | while read -r block; do
    if echo "$block" | grep -q 'mutation'; then
      echo "$block" | grep -q 'userErrors'
    fi
  done
}

# --- JSON variable blocks are valid ---

@test "graphql-patterns.md: all JSON variable blocks are valid JSON" {
  # Extract ```json blocks and validate each
  awk '/^```json$/{ capture=1; block="" ; next } /^```$/{ if(capture) { printf "%s\n", block; capture=0 } next } capture{ block=block $0 }' "$PATTERNS" | while read -r block; do
    echo "$block" | jq empty 2>/dev/null
  done
}

# --- Bash command blocks use valid shopify CLI flags ---

@test "graphql-patterns.md: bash blocks with shopify execute use --query flag" {
  # Only check actual bash code blocks, not prose mentioning the command
  local failed=0
  while IFS= read -r block; do
    if echo "$block" | grep -q 'shopify app execute'; then
      if ! echo "$block" | grep -qE '\-\-query'; then
        echo "Missing --query in bash block: $block" >&2
        failed=1
      fi
    fi
  done < <(awk '/^```bash$/{ capture=1; block=""; next } /^```$/{ if(capture) { print block; capture=0 } next } capture{ block=block " " $0 }' "$PATTERNS")
  [ "$failed" -eq 0 ]
}

@test "graphql-patterns.md: bash blocks with shopify execute include --store flag" {
  # Only check actual bash code blocks, not prose
  local failed=0
  while IFS= read -r block; do
    if echo "$block" | grep -q 'shopify app execute'; then
      if ! echo "$block" | grep -q '\-\-store'; then
        echo "Missing --store in bash block: $block" >&2
        failed=1
      fi
    fi
  done < <(awk '/^```bash$/{ capture=1; block=""; next } /^```$/{ if(capture) { print block; capture=0 } next } capture{ block=block " " $0 }' "$PATTERNS")
  [ "$failed" -eq 0 ]
}

@test "bulk-operations.md: shopify bulk execute commands use --query flag" {
  # Bulk execute commands may span multiple lines; check that --query appears
  # in at least the same bash block as 'shopify app bulk execute'
  local failed=0
  while IFS= read -r block; do
    if echo "$block" | grep -q 'shopify app bulk execute'; then
      if ! echo "$block" | grep -qE '\-\-query'; then
        echo "Missing --query in block: $block" >&2
        failed=1
      fi
    fi
  done < <(awk '/^```bash$/{ capture=1; block=""; next } /^```$/{ if(capture) { print block; capture=0 } next } capture{ block=block " " $0 }' "$BULK_OPS")
  [ "$failed" -eq 0 ]
}

# --- Coverage: all major resource types documented ---

@test "graphql-patterns.md: covers products, orders, customers, inventory" {
  grep -q '## Product Queries' "$PATTERNS"
  grep -q '## Order Queries' "$PATTERNS"
  grep -q '## Customer Queries' "$PATTERNS"
  grep -q '## Inventory Queries' "$PATTERNS"
}

@test "graphql-patterns.md: covers CRUD mutations" {
  grep -q 'productCreate' "$PATTERNS"
  grep -q 'productUpdate' "$PATTERNS"
  grep -q 'productDelete' "$PATTERNS"
  grep -q 'collectionCreate' "$PATTERNS"
  grep -q 'inventoryAdjustQuantities' "$PATTERNS"
}

@test "bulk-operations.md: covers the complete lifecycle" {
  grep -q 'bulkOperationRunQuery' "$BULK_OPS"
  grep -q 'currentBulkOperation' "$BULK_OPS"
  grep -q 'COMPLETED' "$BULK_OPS"
  grep -q 'FAILED' "$BULK_OPS"
  grep -q '__parentId' "$BULK_OPS"
}
