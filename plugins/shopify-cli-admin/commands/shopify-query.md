---
description: Run an ad-hoc GraphQL query against the Shopify Admin API
argument-hint: [natural language description of what to query]
allowed-tools: Read, Bash(shopify:*), Bash(jq:*), Write
---

Use the shopify-admin-api skill to handle this request.

The user wants to run a GraphQL query against their Shopify store's Admin API.

If "$ARGUMENTS" is provided:
  1. Interpret the natural language description to determine the right GraphQL query
  2. Construct the query (consult references/graphql-patterns.md for common patterns)
  3. Show the query and explain what it will return
  4. Run: `shopify app execute --query '<query>' --store <store>`
  5. Parse the JSON response and present results clearly
  6. Offer to refine the query, add fields, or export results

If no arguments:
  1. Ask what data the user needs from their store
  2. Follow the same flow above

If the user says "generate a script" or "make reusable":
  Save the query as a reusable .sh script with variables for store and client-id.

Always confirm the target store before running. For mutations, confirm the store is
a dev store and show the mutation before executing.
