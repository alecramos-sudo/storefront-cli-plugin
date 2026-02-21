# Shopify Admin API -- GraphQL Patterns Reference

Complete, copy-pasteable GraphQL patterns for the Shopify Admin API. Each pattern includes the full `shopify app execute` command ready to run. Replace `STORE_HANDLE` with your actual store handle (e.g., `my-store.myshopify.com` or the handle from `shopify.theme.toml`).

All queries target the **2025-01 Admin API version** (stable). Adjust the `--api-version` flag if you need a different version.

---

## Product Queries

#### List First 10 Products

Retrieve a paginated list of products with core fields.

```graphql
{
  products(first: 10) {
    edges {
      node {
        id
        title
        handle
        status
        productType
        vendor
        createdAt
        updatedAt
      }
    }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}
```

```bash
shopify app execute --query '{ products(first: 10) { edges { node { id title handle status productType vendor createdAt updatedAt } } pageInfo { hasNextPage endCursor } } }' --store STORE_HANDLE
```

#### Search Products by Title

Find products whose title matches a search string using the `query` filter argument.

```graphql
{
  products(first: 10, query: "title:*serum*") {
    edges {
      node {
        id
        title
        handle
        status
        productType
      }
    }
  }
}
```

```bash
shopify app execute --query '{ products(first: 10, query: "title:*serum*") { edges { node { id title handle status productType } } } }' --store STORE_HANDLE
```

#### Get Product by ID with Variants and Prices

Fetch a single product and its first 20 variants including pricing information.

```graphql
{
  product(id: "gid://shopify/Product/PRODUCT_ID") {
    id
    title
    handle
    status
    descriptionHtml
    productType
    vendor
    tags
    variants(first: 20) {
      edges {
        node {
          id
          title
          sku
          price
          compareAtPrice
          inventoryQuantity
          selectedOptions {
            name
            value
          }
        }
      }
    }
    images(first: 5) {
      edges {
        node {
          id
          url
          altText
        }
      }
    }
  }
}
```

```bash
shopify app execute --query '{ product(id: "gid://shopify/Product/PRODUCT_ID") { id title handle status descriptionHtml productType vendor tags variants(first: 20) { edges { node { id title sku price compareAtPrice inventoryQuantity selectedOptions { name value } } } } images(first: 5) { edges { node { id url altText } } } } }' --store STORE_HANDLE
```

#### Get Product with Metafields

Retrieve a product along with its metafields. Use the `namespace` and `key` arguments to target specific metafields, or request them all.

```graphql
{
  product(id: "gid://shopify/Product/PRODUCT_ID") {
    id
    title
    handle
    metafields(first: 20) {
      edges {
        node {
          id
          namespace
          key
          value
          type
        }
      }
    }
  }
}
```

```bash
shopify app execute --query '{ product(id: "gid://shopify/Product/PRODUCT_ID") { id title handle metafields(first: 20) { edges { node { id namespace key value type } } } } }' --store STORE_HANDLE
```

---

## Order Queries

#### List Recent 10 Orders

Fetch the 10 most recent orders with essential details. The `reverse: true` combined with `sortKey: CREATED_AT` returns newest first.

```graphql
{
  orders(first: 10, sortKey: CREATED_AT, reverse: true) {
    edges {
      node {
        id
        name
        email
        createdAt
        displayFinancialStatus
        displayFulfillmentStatus
        totalPriceSet {
          shopMoney {
            amount
            currencyCode
          }
        }
        customer {
          id
          displayName
        }
      }
    }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}
```

```bash
shopify app execute --query '{ orders(first: 10, sortKey: CREATED_AT, reverse: true) { edges { node { id name email createdAt displayFinancialStatus displayFulfillmentStatus totalPriceSet { shopMoney { amount currencyCode } } customer { id displayName } } } pageInfo { hasNextPage endCursor } } }' --store STORE_HANDLE
```

#### Filter Orders by Fulfillment Status

Use the `query` argument with the `fulfillment_status` filter to find unfulfilled orders.

```graphql
{
  orders(first: 10, query: "fulfillment_status:unfulfilled") {
    edges {
      node {
        id
        name
        email
        createdAt
        displayFulfillmentStatus
        totalPriceSet {
          shopMoney {
            amount
            currencyCode
          }
        }
      }
    }
  }
}
```

```bash
shopify app execute --query '{ orders(first: 10, query: "fulfillment_status:unfulfilled") { edges { node { id name email createdAt displayFulfillmentStatus totalPriceSet { shopMoney { amount currencyCode } } } } } }' --store STORE_HANDLE
```

Other useful fulfillment status values: `shipped`, `partial`, `unshipped`.

#### Get Order by ID with Line Items

Fetch a single order with complete line item details including variant and product references.

```graphql
{
  order(id: "gid://shopify/Order/ORDER_ID") {
    id
    name
    email
    createdAt
    displayFinancialStatus
    displayFulfillmentStatus
    totalPriceSet {
      shopMoney {
        amount
        currencyCode
      }
    }
    subtotalPriceSet {
      shopMoney {
        amount
        currencyCode
      }
    }
    totalShippingPriceSet {
      shopMoney {
        amount
        currencyCode
      }
    }
    totalTaxSet {
      shopMoney {
        amount
        currencyCode
      }
    }
    lineItems(first: 50) {
      edges {
        node {
          id
          title
          quantity
          sku
          originalUnitPriceSet {
            shopMoney {
              amount
              currencyCode
            }
          }
          variant {
            id
            title
          }
          product {
            id
            handle
          }
        }
      }
    }
    shippingAddress {
      address1
      address2
      city
      province
      country
      zip
    }
  }
}
```

```bash
shopify app execute --query '{ order(id: "gid://shopify/Order/ORDER_ID") { id name email createdAt displayFinancialStatus displayFulfillmentStatus totalPriceSet { shopMoney { amount currencyCode } } subtotalPriceSet { shopMoney { amount currencyCode } } totalShippingPriceSet { shopMoney { amount currencyCode } } totalTaxSet { shopMoney { amount currencyCode } } lineItems(first: 50) { edges { node { id title quantity sku originalUnitPriceSet { shopMoney { amount currencyCode } } variant { id title } product { id handle } } } } shippingAddress { address1 address2 city province country zip } } }' --store STORE_HANDLE
```

---

## Customer Queries

#### List Customers

Retrieve a list of customers with basic profile information.

```graphql
{
  customers(first: 10) {
    edges {
      node {
        id
        displayName
        email
        phone
        state
        createdAt
        numberOfOrders
        amountSpent {
          amount
          currencyCode
        }
      }
    }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}
```

```bash
shopify app execute --query '{ customers(first: 10) { edges { node { id displayName email phone state createdAt numberOfOrders amountSpent { amount currencyCode } } } pageInfo { hasNextPage endCursor } } }' --store STORE_HANDLE
```

#### Search Customer by Email

Look up a specific customer by their email address.

```graphql
{
  customers(first: 1, query: "email:customer@example.com") {
    edges {
      node {
        id
        displayName
        email
        phone
        state
        createdAt
        numberOfOrders
        amountSpent {
          amount
          currencyCode
        }
        tags
      }
    }
  }
}
```

```bash
shopify app execute --query '{ customers(first: 1, query: "email:customer@example.com") { edges { node { id displayName email phone state createdAt numberOfOrders amountSpent { amount currencyCode } tags } } } }' --store STORE_HANDLE
```

#### Get Customer with Addresses and Order Count

Fetch a single customer with their full address list and order summary.

```graphql
{
  customer(id: "gid://shopify/Customer/CUSTOMER_ID") {
    id
    displayName
    email
    phone
    state
    createdAt
    numberOfOrders
    amountSpent {
      amount
      currencyCode
    }
    tags
    addresses {
      id
      address1
      address2
      city
      province
      country
      zip
      phone
    }
    defaultAddress {
      id
      address1
      city
      province
      country
      zip
    }
  }
}
```

```bash
shopify app execute --query '{ customer(id: "gid://shopify/Customer/CUSTOMER_ID") { id displayName email phone state createdAt numberOfOrders amountSpent { amount currencyCode } tags addresses { id address1 address2 city province country zip phone } defaultAddress { id address1 city province country zip } } }' --store STORE_HANDLE
```

---

## Inventory Queries

#### Query Inventory Levels by Location

Retrieve inventory item quantities at a specific location. You need the location GID.

```graphql
{
  location(id: "gid://shopify/Location/LOCATION_ID") {
    id
    name
    inventoryLevels(first: 20) {
      edges {
        node {
          id
          quantities(names: ["available", "on_hand", "committed"]) {
            name
            quantity
          }
          item {
            id
            sku
            variant {
              id
              title
              displayName
              product {
                id
                title
              }
            }
          }
        }
      }
      pageInfo {
        hasNextPage
        endCursor
      }
    }
  }
}
```

```bash
shopify app execute --query '{ location(id: "gid://shopify/Location/LOCATION_ID") { id name inventoryLevels(first: 20) { edges { node { id quantities(names: ["available", "on_hand", "committed"]) { name quantity } item { id sku variant { id title displayName product { id title } } } } } pageInfo { hasNextPage endCursor } } } }' --store STORE_HANDLE
```

To list available locations first:

```bash
shopify app execute --query '{ locations(first: 10) { edges { node { id name isActive address { address1 city province country zip } } } } }' --store STORE_HANDLE
```

---

## Common Mutations

#### productCreate

Create a new product. Uses the `productCreate` mutation which accepts a `ProductInput`. A default variant is created automatically.

> **Note (2025-01 API):** The `variants` field was removed from `ProductInput`. Products are created with a default variant. To add or customize variants after creation, use `productVariantsBulkCreate`.

```graphql
mutation productCreate($input: ProductInput!) {
  productCreate(input: $input) {
    product {
      id
      title
      handle
      status
      variants(first: 10) {
        edges {
          node {
            id
            title
            price
            sku
          }
        }
      }
    }
    userErrors {
      field
      message
    }
  }
}
```

Variables:

```json
{
  "input": {
    "title": "Rose Quartz Facial Roller",
    "descriptionHtml": "<p>Handcrafted rose quartz facial roller for lymphatic drainage and skin toning.</p>",
    "productType": "Tools",
    "vendor": "Angela Caglia",
    "tags": ["skincare", "tools", "facial-roller"],
    "status": "DRAFT"
  }
}
```

```bash
shopify app execute --query 'mutation productCreate($input: ProductInput!) { productCreate(input: $input) { product { id title handle status variants(first: 10) { edges { node { id title price sku } } } } userErrors { field message } } }' --variables '{"input":{"title":"Rose Quartz Facial Roller","descriptionHtml":"<p>Handcrafted rose quartz facial roller.</p>","productType":"Tools","vendor":"Angela Caglia","tags":["skincare","tools"],"status":"DRAFT"}}' --store STORE_HANDLE
```

#### productVariantsBulkCreate

Add variants to an existing product. Use after `productCreate` to set up multiple variants with pricing and inventory.

```graphql
mutation productVariantsBulkCreate($productId: ID!, $variants: [ProductVariantsBulkInput!]!) {
  productVariantsBulkCreate(productId: $productId, variants: $variants) {
    productVariants {
      id
      title
      price
      sku
      selectedOptions {
        name
        value
      }
    }
    userErrors {
      field
      message
    }
  }
}
```

Variables:

```json
{
  "productId": "gid://shopify/Product/PRODUCT_ID",
  "variants": [
    {
      "price": "68.00",
      "sku": "AC-RQ-ROLLER-001",
      "optionValues": [
        { "optionName": "Size", "name": "Standard" }
      ]
    },
    {
      "price": "42.00",
      "sku": "AC-RQ-ROLLER-TRAVEL",
      "optionValues": [
        { "optionName": "Size", "name": "Travel" }
      ]
    }
  ]
}
```

```bash
shopify app execute --query 'mutation productVariantsBulkCreate($productId: ID!, $variants: [ProductVariantsBulkInput!]!) { productVariantsBulkCreate(productId: $productId, variants: $variants) { productVariants { id title price sku } userErrors { field message } } }' --variables '{"productId":"gid://shopify/Product/PRODUCT_ID","variants":[{"price":"68.00","sku":"AC-RQ-ROLLER-001","optionValues":[{"optionName":"Size","name":"Standard"}]},{"price":"42.00","sku":"AC-RQ-ROLLER-TRAVEL","optionValues":[{"optionName":"Size","name":"Travel"}]}]}' --store STORE_HANDLE
```

#### productUpdate

Update an existing product. Pass the product GID and only the fields you want to change.

```graphql
mutation productUpdate($input: ProductInput!) {
  productUpdate(input: $input) {
    product {
      id
      title
      handle
      status
      descriptionHtml
    }
    userErrors {
      field
      message
    }
  }
}
```

Variables:

```json
{
  "input": {
    "id": "gid://shopify/Product/PRODUCT_ID",
    "title": "Rose Quartz Facial Roller -- Limited Edition",
    "status": "ACTIVE",
    "tags": ["skincare", "tools", "facial-roller", "limited-edition"]
  }
}
```

```bash
shopify app execute --query 'mutation productUpdate($input: ProductInput!) { productUpdate(input: $input) { product { id title handle status } userErrors { field message } } }' --variables '{"input":{"id":"gid://shopify/Product/PRODUCT_ID","title":"Rose Quartz Facial Roller -- Limited Edition","status":"ACTIVE"}}' --store STORE_HANDLE
```

#### productDelete

Delete a product by its GID. This is irreversible.

```graphql
mutation productDelete($input: ProductDeleteInput!) {
  productDelete(input: $input) {
    deletedProductId
    userErrors {
      field
      message
    }
  }
}
```

Variables:

```json
{
  "input": {
    "id": "gid://shopify/Product/PRODUCT_ID"
  }
}
```

```bash
shopify app execute --query 'mutation productDelete($input: ProductDeleteInput!) { productDelete(input: $input) { deletedProductId userErrors { field message } } }' --variables '{"input":{"id":"gid://shopify/Product/PRODUCT_ID"}}' --store STORE_HANDLE
```

#### collectionCreate

Create a smart collection using rules (automatic collection) or a manual collection.

```graphql
mutation collectionCreate($input: CollectionInput!) {
  collectionCreate(input: $input) {
    collection {
      id
      title
      handle
      ruleSet {
        appliedDisjunctively
        rules {
          column
          relation
          condition
        }
      }
    }
    userErrors {
      field
      message
    }
  }
}
```

Variables (smart collection with rules):

```json
{
  "input": {
    "title": "Best Sellers",
    "descriptionHtml": "<p>Our most popular skincare products.</p>",
    "ruleSet": {
      "appliedDisjunctively": false,
      "rules": [
        {
          "column": "TAG",
          "relation": "EQUALS",
          "condition": "best-seller"
        },
        {
          "column": "PRODUCT_TYPE",
          "relation": "EQUALS",
          "condition": "Skincare"
        }
      ]
    }
  }
}
```

```bash
shopify app execute --query 'mutation collectionCreate($input: CollectionInput!) { collectionCreate(input: $input) { collection { id title handle ruleSet { appliedDisjunctively rules { column relation condition } } } userErrors { field message } } }' --variables '{"input":{"title":"Best Sellers","descriptionHtml":"<p>Our most popular skincare products.</p>","ruleSet":{"appliedDisjunctively":false,"rules":[{"column":"TAG","relation":"EQUALS","condition":"best-seller"},{"column":"PRODUCT_TYPE","relation":"EQUALS","condition":"Skincare"}]}}}' --store STORE_HANDLE
```

#### inventoryAdjustQuantities

Adjust inventory quantities for one or more inventory items at a location. Uses the `inventoryAdjustQuantities` mutation which expects a `reason`, a `name` for the quantity type, and a list of changes.

```graphql
mutation inventoryAdjustQuantities($input: InventoryAdjustQuantitiesInput!) {
  inventoryAdjustQuantities(input: $input) {
    inventoryAdjustmentGroup {
      createdAt
      reason
      changes {
        name
        delta
        quantityAfterChange
        item {
          id
          sku
        }
        location {
          id
          name
        }
      }
    }
    userErrors {
      field
      message
    }
  }
}
```

Variables:

```json
{
  "input": {
    "reason": "correction",
    "name": "available",
    "changes": [
      {
        "delta": 25,
        "inventoryItemId": "gid://shopify/InventoryItem/INVENTORY_ITEM_ID",
        "locationId": "gid://shopify/Location/LOCATION_ID"
      }
    ]
  }
}
```

```bash
shopify app execute --query 'mutation inventoryAdjustQuantities($input: InventoryAdjustQuantitiesInput!) { inventoryAdjustQuantities(input: $input) { inventoryAdjustmentGroup { createdAt reason changes { name delta quantityAfterChange item { id sku } location { id name } } } userErrors { field message } } }' --variables '{"input":{"reason":"correction","name":"available","changes":[{"delta":25,"inventoryItemId":"gid://shopify/InventoryItem/INVENTORY_ITEM_ID","locationId":"gid://shopify/Location/LOCATION_ID"}]}}' --store STORE_HANDLE
```

Use negative `delta` values to decrease inventory. Valid `reason` values include: `correction`, `cycle_count_available`, `damaged`, `movement_created`, `movement_received`, `promotion`, `quality_control`, `received`, `reservation_created`, `reservation_deleted`, `reservation_updated`, `restock`, `safety_stock`, `shrinkage`.

---

## Tips

- **Pagination**: Use `pageInfo.endCursor` with `after` argument to paginate: `products(first: 10, after: "CURSOR")`.
- **GIDs**: All Shopify IDs in GraphQL are Global IDs like `gid://shopify/Product/123456789`. The numeric part corresponds to the REST API ID.
- **userErrors**: Always request `userErrors { field message }` in mutations. A successful HTTP response does not guarantee the operation succeeded -- check `userErrors` for validation failures.
- **Rate limits**: The Admin API uses a cost-based throttle. Complex queries with many nested connections consume more points. Simplify field selections if you hit limits.
- **Query filter syntax**: The `query` argument uses Shopify's search syntax. Combine filters with `AND`/`OR`: `query: "title:serum AND status:active"`.
