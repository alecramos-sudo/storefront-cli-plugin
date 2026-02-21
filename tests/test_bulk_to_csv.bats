#!/usr/bin/env bats

# Functional tests for bulk-to-csv.sh

REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
SCRIPT="$REPO_ROOT/plugins/shopify-cli-admin/scripts/bulk-to-csv.sh"
FIXTURES="$REPO_ROOT/tests/fixtures"

# --- Error handling ---

@test "exits with error for missing file" {
  run "$SCRIPT" /nonexistent/file.jsonl
  [ "$status" -eq 1 ]
  [[ "$output" == *"Error: File not found"* ]]
}

@test "shows usage on missing file error" {
  run "$SCRIPT" /nonexistent/file.jsonl
  [[ "$output" == *"Usage:"* ]]
}

# --- Products mode ---

@test "products: outputs CSV header" {
  run "$SCRIPT" "$FIXTURES/products.jsonl" products
  [ "$status" -eq 0 ]
  local header
  header=$(echo "$output" | head -1)
  [[ "$header" == *"product_id"* ]]
  [[ "$header" == *"title"* ]]
  [[ "$header" == *"variant_id"* ]]
  [[ "$header" == *"sku"* ]]
}

@test "products: outputs correct number of data rows" {
  run "$SCRIPT" "$FIXTURES/products.jsonl" products
  [ "$status" -eq 0 ]
  # 3 variants = 3 data rows + 1 header = 4 lines
  local line_count
  line_count=$(echo "$output" | wc -l | tr -d ' ')
  [ "$line_count" -eq 4 ]
}

@test "products: joins variants to parent products" {
  run "$SCRIPT" "$FIXTURES/products.jsonl" products
  [ "$status" -eq 0 ]
  # First variant row should have product title "Test T-Shirt"
  [[ "$output" == *"Test T-Shirt"* ]]
  [[ "$output" == *"TSH-SM"* ]]
}

@test "products: includes all variant SKUs" {
  run "$SCRIPT" "$FIXTURES/products.jsonl" products
  [[ "$output" == *"TSH-SM"* ]]
  [[ "$output" == *"TSH-MD"* ]]
  [[ "$output" == *"MUG-01"* ]]
}

# --- Orders mode ---

@test "orders: outputs CSV header" {
  run "$SCRIPT" "$FIXTURES/orders.jsonl" orders
  [ "$status" -eq 0 ]
  local header
  header=$(echo "$output" | head -1)
  [[ "$header" == *"order_id"* ]]
  [[ "$header" == *"order_name"* ]]
  [[ "$header" == *"line_item_title"* ]]
}

@test "orders: outputs correct number of data rows" {
  run "$SCRIPT" "$FIXTURES/orders.jsonl" orders
  [ "$status" -eq 0 ]
  # 2 line items = 2 data rows + 1 header = 3 lines
  local line_count
  line_count=$(echo "$output" | wc -l | tr -d ' ')
  [ "$line_count" -eq 3 ]
}

@test "orders: joins line items to parent orders" {
  run "$SCRIPT" "$FIXTURES/orders.jsonl" orders
  [[ "$output" == *"#1001"* ]]
  [[ "$output" == *"alice@example.com"* ]]
  [[ "$output" == *"Test T-Shirt - Small"* ]]
}

@test "orders: includes price and currency" {
  run "$SCRIPT" "$FIXTURES/orders.jsonl" orders
  [[ "$output" == *"59.98"* ]]
  [[ "$output" == *"USD"* ]]
}

# --- Customers mode ---

@test "customers: outputs CSV header" {
  run "$SCRIPT" "$FIXTURES/customers.jsonl" customers
  [ "$status" -eq 0 ]
  local header
  header=$(echo "$output" | head -1)
  [[ "$header" == *"customer_id"* ]]
  [[ "$header" == *"email"* ]]
  [[ "$header" == *"city"* ]]
}

@test "customers: outputs correct number of data rows" {
  run "$SCRIPT" "$FIXTURES/customers.jsonl" customers
  [ "$status" -eq 0 ]
  # Alice has 1 address = 1 row, Bob has 0 addresses = 1 row, + 1 header = 3 lines
  local line_count
  line_count=$(echo "$output" | wc -l | tr -d ' ')
  [ "$line_count" -eq 3 ]
}

@test "customers: includes address data for customers with addresses" {
  run "$SCRIPT" "$FIXTURES/customers.jsonl" customers
  [[ "$output" == *"Portland"* ]]
  [[ "$output" == *"97201"* ]]
}

@test "customers: handles customers without addresses" {
  run "$SCRIPT" "$FIXTURES/customers.jsonl" customers
  [[ "$output" == *"bob@example.com"* ]]
}

# --- Auto mode ---

@test "auto: outputs flat scalar fields" {
  run "$SCRIPT" "$FIXTURES/flat.jsonl"
  [ "$status" -eq 0 ]
  local header
  header=$(echo "$output" | head -1)
  [[ "$header" == *"id"* ]]
  [[ "$header" == *"title"* ]]
  [[ "$header" == *"status"* ]]
}

@test "auto: outputs correct number of rows" {
  run "$SCRIPT" "$FIXTURES/flat.jsonl"
  [ "$status" -eq 0 ]
  # 2 products + 1 header = 3 lines
  local line_count
  line_count=$(echo "$output" | wc -l | tr -d ' ')
  [ "$line_count" -eq 3 ]
}

@test "auto: excludes child rows (with __parentId)" {
  run "$SCRIPT" "$FIXTURES/products.jsonl"
  [ "$status" -eq 0 ]
  # Only 2 parent products (no __parentId), + 1 header = 3 lines
  local line_count
  line_count=$(echo "$output" | wc -l | tr -d ' ')
  [ "$line_count" -eq 3 ]
}

# --- Stdin support ---

@test "reads from stdin with - argument" {
  run bash -c "cat '$FIXTURES/flat.jsonl' | '$SCRIPT' - auto"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Widget"* ]]
  [[ "$output" == *"Gadget"* ]]
}
