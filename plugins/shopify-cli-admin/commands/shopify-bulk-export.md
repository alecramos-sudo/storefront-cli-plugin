---
description: Export large Shopify datasets (products, orders, customers) to CSV via bulk operations
argument-hint: [resource-type] [optional filters]
allowed-tools: Read, Bash(shopify:*), Bash(jq:*), Bash(${CLAUDE_PLUGIN_ROOT}:*), Write
---

Use the shopify-admin-api skill to handle this bulk export request.

The user wants to export data from their Shopify store using bulk operations.

1. Determine the resource type from "$ARGUMENTS" (products, orders, or customers)
   - If unclear, ask which resource to export
2. Construct the bulk query (consult references/bulk-operations.md for patterns)
3. Show the query and confirm with the user
4. Run: `shopify app bulk execute --query '<bulk_query>' --store <store> --watch --output-file /tmp/bulk-results.jsonl`
   (The `--watch` flag waits for completion and `--output-file` writes results directly, avoiding manual polling)
5. Transform the JSONL output to CSV using:
   `bash ${CLAUDE_PLUGIN_ROOT}/scripts/bulk-to-csv.sh <output.jsonl> <resource-type>`
6. Report: row count, output file location, column summary
7. Offer to adjust columns, add filters, or re-export

For custom filters or field selections, modify the bulk query accordingly.
Always confirm the target store before running.
