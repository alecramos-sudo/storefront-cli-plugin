---
description: Create dynamic test carts with specific products for testing
argument-hint: [product criteria or IDs]
allowed-tools: Read, Bash(shopify:*), Bash(jq:*), Write
---

Use the shopify-admin-api skill to create a test cart.

The user wants to create a cart with specific products for testing.

1. Determine product selection from "$ARGUMENTS":
   - If product IDs given, query those products for variant info
   - If criteria given (e.g. "3 products over $50"), search products matching criteria
   - If no arguments, ask what products should be in the cart

2. Query the store for matching products and their first available variant:
   `shopify app execute --query '{ products(first: 10, query: "...") { edges { node { id title variants(first: 1) { edges { node { id } } } } } } }'`

3. Build a cart permalink:
   Format: `https://<store>.myshopify.com/cart/<variant_id>:<quantity>,<variant_id>:<quantity>`

4. Present:
   - Products included (title, variant, price)
   - Cart permalink URL
   - Total estimated value

5. Offer alternatives:
   - Add/remove products
   - Change quantities
   - Use Cart API for more control (discount codes, attributes)

Always confirm the target store before querying.
