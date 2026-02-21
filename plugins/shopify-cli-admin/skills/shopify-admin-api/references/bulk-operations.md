# Bulk Operations Reference

## How Bulk Operations Work

Bulk operations process large datasets asynchronously through a four-stage lifecycle:

1. **Staging** — Submit a `bulkOperationRunQuery` mutation containing the GraphQL query. Shopify validates the query and creates a bulk operation in `CREATED` status.
2. **Processing** — Shopify transitions the operation to `RUNNING` and iterates through all matching records server-side. No pagination tokens, cursors, or rate-limit management is required.
3. **Completed** — The operation reaches `COMPLETED` status. Shopify writes all results to a temporary JSONL file hosted on Shopify's CDN.
4. **Download** — Retrieve the JSONL file from the `url` field on the completed operation. The file remains available for approximately 24 hours.

Only one bulk operation can run at a time per app per store. Attempting to start a second operation while one is active returns an error. Cancel the running operation first or wait for it to finish.

Results are always in JSONL format: one JSON object per line, with no wrapping array or envelope.

---

## Bulk Query Syntax

Bulk queries differ from standard paginated Admin API queries in two important ways:

### No Pagination Arguments

Omit `first`, `last`, `after`, and `before` arguments. Bulk operations automatically iterate through every matching record. Including pagination arguments causes an error.

**Standard paginated query (do NOT use for bulk):**

```graphql
{
  products(first: 50, after: "cursor123") {
    edges {
      node {
        id
        title
      }
    }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}
```

**Bulk query equivalent:**

```graphql
{
  products {
    edges {
      node {
        id
        title
      }
    }
  }
}
```

### Flat JSONL Output

Even though the query uses `edges { node { } }` syntax, results come back as flat JSONL lines — no `edges` or `node` wrappers. Each object appears on its own line. Nested connections (e.g., variants under products) produce separate lines linked by `__parentId`.

**Example JSONL output:**

```jsonl
{"id":"gid://shopify/Product/123","title":"Face Cream"}
{"id":"gid://shopify/ProductVariant/456","title":"30ml","sku":"FC-30","price":"45.00","__parentId":"gid://shopify/Product/123"}
{"id":"gid://shopify/ProductVariant/789","title":"60ml","sku":"FC-60","price":"75.00","__parentId":"gid://shopify/Product/123"}
```

---

## Running a Bulk Query

Use `shopify app bulk execute` to submit a bulk operation:

```bash
shopify app bulk execute \
  --query '{ products { edges { node { id title handle status variants { edges { node { id title sku price } } } } } } }' \
  --store STORE_HANDLE
```

For complex queries, write the query to a file and use `--query-file`:

```bash
cat > /tmp/bulk-products.graphql << 'GRAPHQL'
{
  products {
    edges {
      node {
        id
        title
        handle
        status
        productType
        vendor
        variants {
          edges {
            node {
              id
              title
              sku
              price
              inventoryQuantity
              barcode
            }
          }
        }
      }
    }
  }
}
GRAPHQL

shopify app bulk execute \
  --query-file /tmp/bulk-products.graphql \
  --store STORE_HANDLE
```

Other common bulk queries:

```bash
# All orders with line items
shopify app bulk execute \
  --query '{ orders { edges { node { id name createdAt totalPriceSet { shopMoney { amount currencyCode } } lineItems { edges { node { id title quantity sku } } } } } } }' \
  --store STORE_HANDLE

# All customers with addresses
shopify app bulk execute \
  --query '{ customers { edges { node { id firstName lastName email phone addresses { address1 city province country zip } } } } }' \
  --store STORE_HANDLE
```

---

## Polling for Completion

After submitting a bulk operation, poll the `currentBulkOperation` query to check status.

**Polling query:**

```graphql
{
  currentBulkOperation {
    id
    status
    errorCode
    objectCount
    fileSize
    url
    createdAt
    completedAt
  }
}
```

**Run the polling query:**

```bash
shopify app execute \
  --query '{ currentBulkOperation { id status errorCode objectCount fileSize url createdAt completedAt } }' \
  --store STORE_HANDLE
```

### Status Values

| Status | Meaning |
|--------|---------|
| `CREATED` | Operation accepted, queued for processing |
| `RUNNING` | Actively iterating through records |
| `COMPLETED` | Finished successfully; `url` field contains the results file |
| `FAILED` | Encountered an unrecoverable error; check `errorCode` |
| `CANCELED` | Manually canceled before completion |

Poll every 5-10 seconds until `status` is `COMPLETED`, `FAILED`, or `CANCELED`. The `objectCount` field increments during `RUNNING` and indicates progress.

**Simple polling loop:**

```bash
while true; do
  STATUS=$(shopify app execute \
    --query '{ currentBulkOperation { status url objectCount } }' \
    --store STORE_HANDLE \
    --output-file /tmp/bulk-status.json 2>/dev/null && \
    jq -r '.data.currentBulkOperation.status' /tmp/bulk-status.json)

  echo "Status: $STATUS"

  if [ "$STATUS" = "COMPLETED" ]; then
    URL=$(jq -r '.data.currentBulkOperation.url' /tmp/bulk-status.json)
    echo "Downloading results..."
    curl -s "$URL" -o /tmp/bulk-results.jsonl
    break
  elif [ "$STATUS" = "FAILED" ] || [ "$STATUS" = "CANCELED" ]; then
    echo "Operation $STATUS"
    break
  fi

  sleep 10
done
```

---

## Downloading Results

When status is `COMPLETED`, the `url` field contains a pre-signed URL to the JSONL file. Download it with `curl`:

```bash
URL=$(jq -r '.data.currentBulkOperation.url' /tmp/bulk-status.json)
curl -s "$URL" -o /tmp/bulk-results.jsonl
```

### JSONL Format

Each line is a self-contained JSON object. Parent-child relationships are expressed through the `__parentId` field:

- Top-level objects (e.g., products, orders) have no `__parentId`.
- Nested objects (e.g., variants, line items) include `__parentId` set to the `id` of their parent.
- Children always appear after their parent in the file.

---

## Transforming with jq

### Products with Variants (Flatten Parent-Child)

Merge each variant line with its parent product into a single flat row:

```bash
# Build a lookup of parent products, then join variants to their parent
jq -s '
  [
    ([.[] | select(.__parentId == null)] | map({(.id): .}) | add) as $parents |
    .[] |
    select(.__parentId != null) |
    $parents[.__parentId] as $parent |
    {
      product_id: $parent.id,
      product_title: $parent.title,
      handle: $parent.handle,
      status: $parent.status,
      variant_id: .id,
      variant_title: .title,
      sku: .sku,
      price: .price
    }
  ]
' /tmp/bulk-results.jsonl
```

### Orders with Line Items

```bash
jq -s '
  [
    ([.[] | select(.__parentId == null)] | map({(.id): .}) | add) as $orders |
    .[] |
    select(.__parentId != null) |
    $orders[.__parentId] as $order |
    {
      order_id: $order.id,
      order_name: $order.name,
      created_at: $order.createdAt,
      total: $order.totalPriceSet.shopMoney.amount,
      currency: $order.totalPriceSet.shopMoney.currencyCode,
      line_item_id: .id,
      line_item_title: .title,
      quantity: .quantity,
      sku: .sku
    }
  ]
' /tmp/bulk-results.jsonl
```

### Customers with Addresses

Customers with inline `addresses` (not a connection) appear as single lines. Extract and flatten:

```bash
jq -s '
  [
    .[] |
    . as $c |
    if (.addresses | length) > 0 then
      .addresses[] |
      {
        customer_id: $c.id,
        first_name: $c.firstName,
        last_name: $c.lastName,
        email: $c.email,
        phone: $c.phone,
        address1: .address1,
        city: .city,
        province: .province,
        country: .country,
        zip: .zip
      }
    else
      {
        customer_id: $c.id,
        first_name: $c.firstName,
        last_name: $c.lastName,
        email: $c.email,
        phone: $c.phone
      }
    end
  ]
' /tmp/bulk-results.jsonl
```

### Generic JSONL-to-CSV Conversion

Convert any flat JSONL (or jq-flattened output) to CSV:

```bash
# Pipe jq-transformed JSON array to CSV
jq -r '
  (.[0] | keys_unsorted) as $cols |
  ($cols | @csv),
  (.[] | [.[$cols[]]] | @csv)
' /tmp/transformed.json > /tmp/output.csv
```

Combine with a transform in one pipeline:

```bash
jq -s '
  [.[] | select(.__parentId == null) | {id, title, handle, status}]
' /tmp/bulk-results.jsonl | jq -r '
  (.[0] | keys_unsorted) as $cols |
  ($cols | @csv),
  (.[] | [.[$cols[]]] | @csv)
' > /tmp/products.csv
```

---

## Using bulk-to-csv.sh Helper

The plugin includes a reusable helper script for common export workflows.

**Invoke the helper:**

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/bulk-to-csv.sh <input.jsonl> <type>
```

**Supported types:**

| Type | Behavior |
|------|----------|
| `products` | Flattens product-variant parent-child pairs into rows |
| `orders` | Flattens order-lineItem parent-child pairs into rows |
| `customers` | Extracts customer fields and inline addresses |
| `auto` | Outputs all top-level scalar fields from parent lines (no joins). Useful for quick flat exports. |

**Example:**

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/bulk-to-csv.sh /tmp/bulk-results.jsonl products > /tmp/products.csv
```

The script reads JSONL from the input file, applies the appropriate jq transform, and outputs CSV to stdout. Redirect to a file or pipe to other tools as needed.

---

## Error Handling

### Failed Operations

When `status` is `FAILED`, inspect the `errorCode` field on the bulk operation:

```bash
shopify app execute \
  --query '{ currentBulkOperation { id status errorCode } }' \
  --store STORE_HANDLE
```

Common error codes:

| Error Code | Cause |
|------------|-------|
| `ACCESS_DENIED` | App lacks required API scopes |
| `INTERNAL_SERVER_ERROR` | Shopify-side failure; retry after a delay |
| `TIMEOUT` | Query exceeded the server-side execution limit |

### Partial Results

Some failures still produce a partial results file. Check whether the `url` field is populated even when status is `FAILED`. If present, download and inspect the partial data.

### Timeout Behavior

Bulk queries that run longer than approximately 5 minutes on the server may time out. Narrow the query scope to reduce processing time:

- Add filters: `products(query: "status:active")` instead of all products.
- Reduce requested fields to only what is needed.
- Split into multiple operations (e.g., by product type or date range).

### Retry Strategy

1. Wait 30 seconds after a failure before retrying.
2. Confirm no operation is already running by checking `currentBulkOperation`.
3. Re-submit the same query. Transient errors (e.g., `INTERNAL_SERVER_ERROR`) often succeed on retry.
4. After three consecutive failures, surface the error to the user with the full `errorCode` and `id`.

---

## Limitations

- **One at a time** — Only one bulk operation can run per app per store. Cancel a running operation with `bulkOperationCancel` before starting another.
- **Query timeout** — Queries that take longer than ~5 minutes server-side may fail with a timeout error.
- **Result expiry** — JSONL result files are available for approximately 24 hours after completion. Download promptly.
- **Queries only** — Bulk operations support queries, not mutations. For bulk writes, use `shopify app execute` in a loop with individual mutations, respecting rate limits.
- **No real-time results** — Results are only available after the entire operation completes. There is no streaming or incremental download.
- **Connection fields only** — Only top-level `QueryRoot` connection fields (e.g., `products`, `orders`, `customers`) can be bulk-queried. Non-connection fields like `shop` are not supported.
