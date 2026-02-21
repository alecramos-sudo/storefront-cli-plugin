#!/usr/bin/env bats

# Edge case and realistic usage tests for bulk-to-csv.sh

REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
SCRIPT="$REPO_ROOT/plugins/shopify-cli-admin/scripts/bulk-to-csv.sh"
FIXTURES="$REPO_ROOT/tests/fixtures"

setup() {
  TMPDIR_TEST="$(mktemp -d)"
}

teardown() {
  rm -rf "$TMPDIR_TEST"
}

# --- Empty and minimal input ---

@test "products: empty file produces no output" {
  echo -n "" > "$TMPDIR_TEST/empty.jsonl"
  run "$SCRIPT" "$TMPDIR_TEST/empty.jsonl" products
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "auto: empty file produces no output" {
  echo -n "" > "$TMPDIR_TEST/empty.jsonl"
  run "$SCRIPT" "$TMPDIR_TEST/empty.jsonl"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "products: parents with no variants produces no output" {
  # Products mode only outputs variant rows joined to parents
  cat > "$TMPDIR_TEST/no-variants.jsonl" << 'EOF'
{"id":"gid://shopify/Product/1","title":"Solo Product","handle":"solo","status":"ACTIVE"}
EOF
  run "$SCRIPT" "$TMPDIR_TEST/no-variants.jsonl" products
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "orders: orders with no line items produces no output" {
  cat > "$TMPDIR_TEST/no-items.jsonl" << 'EOF'
{"id":"gid://shopify/Order/1","name":"#1001","email":"test@example.com","createdAt":"2025-01-01T00:00:00Z","totalPriceSet":{"shopMoney":{"amount":"0","currencyCode":"USD"}}}
EOF
  run "$SCRIPT" "$TMPDIR_TEST/no-items.jsonl" orders
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

# --- Single record ---

@test "auto: single record produces header + 1 row" {
  cat > "$TMPDIR_TEST/single.jsonl" << 'EOF'
{"id":"gid://shopify/Product/1","title":"Only Product","status":"ACTIVE"}
EOF
  run "$SCRIPT" "$TMPDIR_TEST/single.jsonl"
  [ "$status" -eq 0 ]
  local line_count
  line_count=$(echo "$output" | wc -l | tr -d ' ')
  [ "$line_count" -eq 2 ]
}

@test "products: single product with single variant" {
  cat > "$TMPDIR_TEST/one.jsonl" << 'EOF'
{"id":"gid://shopify/Product/1","title":"Widget","handle":"widget","status":"ACTIVE","vendor":"Acme","productType":"Gadgets"}
{"id":"gid://shopify/ProductVariant/1","title":"Default","sku":"W-001","price":"10.00","__parentId":"gid://shopify/Product/1"}
EOF
  run "$SCRIPT" "$TMPDIR_TEST/one.jsonl" products
  [ "$status" -eq 0 ]
  local line_count
  line_count=$(echo "$output" | wc -l | tr -d ' ')
  [ "$line_count" -eq 2 ]
  [[ "$output" == *"Widget"* ]]
  [[ "$output" == *"W-001"* ]]
}

# --- Special characters in data ---

@test "products: handles commas in product titles" {
  cat > "$TMPDIR_TEST/comma.jsonl" << 'EOF'
{"id":"gid://shopify/Product/1","title":"Rose, Lavender & Chamomile","handle":"rose-blend","status":"ACTIVE","vendor":"Botanicals","productType":"Blends"}
{"id":"gid://shopify/ProductVariant/1","title":"Small, 30ml","sku":"RLC-30","price":"25.00","__parentId":"gid://shopify/Product/1"}
EOF
  run "$SCRIPT" "$TMPDIR_TEST/comma.jsonl" products
  [ "$status" -eq 0 ]
  # CSV should quote fields with commas
  [[ "$output" == *"Rose, Lavender & Chamomile"* ]]
  [[ "$output" == *"Small, 30ml"* ]]
}

@test "products: handles double quotes in titles" {
  cat > "$TMPDIR_TEST/quotes.jsonl" << 'EOF'
{"id":"gid://shopify/Product/1","title":"The \"Best\" Serum","handle":"best-serum","status":"ACTIVE","vendor":"TestCo","productType":"Skincare"}
{"id":"gid://shopify/ProductVariant/1","title":"Default","sku":"BS-01","price":"50.00","__parentId":"gid://shopify/Product/1"}
EOF
  run "$SCRIPT" "$TMPDIR_TEST/quotes.jsonl" products
  [ "$status" -eq 0 ]
  # jq @csv escapes double quotes by doubling them
  [[ "$output" == *'Best'* ]]
}

@test "customers: handles unicode in names" {
  cat > "$TMPDIR_TEST/unicode.jsonl" << 'EOF'
{"id":"gid://shopify/Customer/1","firstName":"José","lastName":"García","email":"jose@example.com","numberOfOrders":"5","amountSpent":{"amount":"200.00"},"addresses":[{"address1":"Calle Mayor 1","city":"Madrid","province":"Madrid","country":"ES","zip":"28001"}]}
EOF
  run "$SCRIPT" "$TMPDIR_TEST/unicode.jsonl" customers
  [ "$status" -eq 0 ]
  [[ "$output" == *"José"* ]]
  [[ "$output" == *"García"* ]]
  [[ "$output" == *"Madrid"* ]]
}

# --- Missing/null fields ---

@test "products: handles missing optional fields gracefully" {
  cat > "$TMPDIR_TEST/sparse.jsonl" << 'EOF'
{"id":"gid://shopify/Product/1","title":"Bare Product","handle":"bare","status":"ACTIVE"}
{"id":"gid://shopify/ProductVariant/1","__parentId":"gid://shopify/Product/1"}
EOF
  run "$SCRIPT" "$TMPDIR_TEST/sparse.jsonl" products
  [ "$status" -eq 0 ]
  # Should not crash — missing fields become empty strings
  local line_count
  line_count=$(echo "$output" | wc -l | tr -d ' ')
  [ "$line_count" -eq 2 ]
}

@test "orders: handles missing email and line item fields" {
  cat > "$TMPDIR_TEST/sparse-order.jsonl" << 'EOF'
{"id":"gid://shopify/Order/1","name":"#9999","createdAt":"2025-06-01T00:00:00Z","totalPriceSet":{"shopMoney":{"amount":"0","currencyCode":"USD"}}}
{"id":"gid://shopify/LineItem/1","title":"Mystery Item","__parentId":"gid://shopify/Order/1"}
EOF
  run "$SCRIPT" "$TMPDIR_TEST/sparse-order.jsonl" orders
  [ "$status" -eq 0 ]
  [[ "$output" == *"Mystery Item"* ]]
}

# --- Multiple parents with many children ---

@test "products: correctly joins many variants across many products" {
  cat > "$TMPDIR_TEST/multi.jsonl" << 'EOF'
{"id":"gid://shopify/Product/1","title":"Product A","handle":"a","status":"ACTIVE","vendor":"V","productType":"T"}
{"id":"gid://shopify/ProductVariant/11","title":"A-S","sku":"A-S","price":"10","__parentId":"gid://shopify/Product/1"}
{"id":"gid://shopify/ProductVariant/12","title":"A-M","sku":"A-M","price":"12","__parentId":"gid://shopify/Product/1"}
{"id":"gid://shopify/ProductVariant/13","title":"A-L","sku":"A-L","price":"14","__parentId":"gid://shopify/Product/1"}
{"id":"gid://shopify/Product/2","title":"Product B","handle":"b","status":"DRAFT","vendor":"V","productType":"T"}
{"id":"gid://shopify/ProductVariant/21","title":"B-S","sku":"B-S","price":"20","__parentId":"gid://shopify/Product/2"}
{"id":"gid://shopify/Product/3","title":"Product C","handle":"c","status":"ACTIVE","vendor":"V","productType":"T"}
{"id":"gid://shopify/ProductVariant/31","title":"C-S","sku":"C-S","price":"30","__parentId":"gid://shopify/Product/3"}
{"id":"gid://shopify/ProductVariant/32","title":"C-M","sku":"C-M","price":"32","__parentId":"gid://shopify/Product/3"}
EOF
  run "$SCRIPT" "$TMPDIR_TEST/multi.jsonl" products
  [ "$status" -eq 0 ]
  # 6 variants + 1 header = 7 lines
  local line_count
  line_count=$(echo "$output" | wc -l | tr -d ' ')
  [ "$line_count" -eq 7 ]
  # Each variant row should contain its parent product title
  [[ "$output" == *"Product A"* ]]
  [[ "$output" == *"Product B"* ]]
  [[ "$output" == *"Product C"* ]]
  [[ "$output" == *"A-S"* ]]
  [[ "$output" == *"B-S"* ]]
  [[ "$output" == *"C-M"* ]]
}

# --- Customers edge cases ---

@test "customers: customer with multiple addresses produces multiple rows" {
  cat > "$TMPDIR_TEST/multi-addr.jsonl" << 'EOF'
{"id":"gid://shopify/Customer/1","firstName":"Multi","lastName":"Address","email":"multi@example.com","numberOfOrders":"2","amountSpent":{"amount":"100.00"},"addresses":[{"address1":"Home St","city":"Portland","province":"OR","country":"US","zip":"97201"},{"address1":"Work Ave","city":"Seattle","province":"WA","country":"US","zip":"98101"}]}
EOF
  run "$SCRIPT" "$TMPDIR_TEST/multi-addr.jsonl" customers
  [ "$status" -eq 0 ]
  # 2 addresses = 2 data rows + 1 header = 3 lines
  local line_count
  line_count=$(echo "$output" | wc -l | tr -d ' ')
  [ "$line_count" -eq 3 ]
  [[ "$output" == *"Portland"* ]]
  [[ "$output" == *"Seattle"* ]]
}

# --- Output is valid CSV ---

@test "products: output rows have consistent column count" {
  run "$SCRIPT" "$FIXTURES/products.jsonl" products
  [ "$status" -eq 0 ]
  local header_cols
  header_cols=$(echo "$output" | head -1 | awk -F',' '{print NF}')
  echo "$output" | tail -n +2 | while IFS= read -r row; do
    local row_cols
    row_cols=$(echo "$row" | awk -F',' '{print NF}')
    [ "$row_cols" -eq "$header_cols" ]
  done
}

@test "orders: output rows have consistent column count" {
  run "$SCRIPT" "$FIXTURES/orders.jsonl" orders
  [ "$status" -eq 0 ]
  local header_cols
  header_cols=$(echo "$output" | head -1 | awk -F',' '{print NF}')
  echo "$output" | tail -n +2 | while IFS= read -r row; do
    local row_cols
    row_cols=$(echo "$row" | awk -F',' '{print NF}')
    [ "$row_cols" -eq "$header_cols" ]
  done
}
