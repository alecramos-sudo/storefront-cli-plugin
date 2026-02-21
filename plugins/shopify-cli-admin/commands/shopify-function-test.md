---
description: Activate and test Shopify Functions without a UI
argument-hint: [function-id or function-name]
allowed-tools: Read, Bash(shopify:*), Bash(jq:*), Write
---

Use the shopify-admin-api skill to test a Shopify Function.

The user wants to activate and test a Shopify Function on their dev store.

1. If "$ARGUMENTS" identifies a function, use it. Otherwise:
   - Query available functions: `shopify app execute --query '{ shopifyFunctions(first: 25) { nodes { id title apiType } } }'`
   - Present the list and ask which to test

2. Based on the function's apiType, create the appropriate configuration:
   - For discount functions: create a discount via discountAutomaticAppCreate or discountCodeAppCreate
   - For other function types: create the appropriate resource

3. Show the mutation and confirm before running

4. After activation, generate a test scenario:
   - Query products that would trigger the function
   - Build a cart permalink with those products
   - Provide the checkout URL for manual testing

5. After testing, offer cleanup:
   - Deactivate/delete the test discount
   - Remove any test resources created

IMPORTANT: Functions can only be tested on dev stores. Confirm before proceeding.
