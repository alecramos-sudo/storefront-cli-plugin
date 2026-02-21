---
description: Automate dev store setup with products, inventory, and images
argument-hint: [description of desired store state]
allowed-tools: Read, Bash(shopify:*), Bash(jq:*), Write
---

Use the shopify-admin-api skill to set up a development store.

The user wants to initialize their dev store with test data.

1. If "$ARGUMENTS" describes the desired state, use it. Otherwise ask:
   - How many products to create?
   - What product types/categories?
   - How many variants per product?
   - Should inventory levels be set?
   - Any images to upload?

2. Generate productCreate mutations for each product
   (consult references/graphql-patterns.md for mutation syntax)

3. Show the plan: "I'll create X products with Y variants each"

4. Execute mutations one at a time via `shopify app execute`:
   - Create each product with variants
   - Set inventory levels if requested
   - Upload images via stagedUploadsCreate if requested

5. Report what was created with product IDs and handles

6. Offer to save the entire workflow as a reusable setup script:
   - Include all mutations
   - Parameterize store handle and client-id
   - Add a cleanup companion script (delete-all-products.sh)

IMPORTANT: Confirm the target store is a development store before any mutations.
