#!/usr/bin/env bash
set -euo pipefail

# bulk-to-csv.sh — Transform Shopify bulk operation JSONL output to CSV
#
# Bulk JSONL uses flat lines with __parentId for parent-child relationships.
# This script joins children to parents and outputs CSV.
#
# Usage:
#   bulk-to-csv.sh <input.jsonl> [resource-type]
#
# Resource types: products, orders, customers (determines column selection)
# If no resource type given, outputs all top-level scalar fields (no joins).
#
# Examples:
#   bulk-to-csv.sh products.jsonl products > products.csv
#   bulk-to-csv.sh orders.jsonl orders > orders.csv
#   cat input.jsonl | bulk-to-csv.sh - customers > customers.csv

INPUT="${1:--}"
TYPE="${2:-auto}"

if [[ "$INPUT" != "-" ]] && [[ ! -f "$INPUT" ]]; then
  echo "Error: File not found: $INPUT" >&2
  echo "Usage: bulk-to-csv.sh <input.jsonl> [products|orders|customers]" >&2
  exit 1
fi

case "$TYPE" in
  products)
    # Bulk JSONL: products are parent lines (no __parentId),
    # variants are child lines (with __parentId pointing to product).
    # Join each variant to its parent product for a flat CSV row.
    jq -sr '
      ([.[] | select(.__parentId == null)] | map({(.id): .}) | add) as $parents |
      [
        .[] |
        select(.__parentId != null) |
        $parents[.__parentId] as $parent |
        {
          product_id: $parent.id,
          title: $parent.title,
          handle: $parent.handle,
          status: $parent.status,
          vendor: ($parent.vendor // ""),
          product_type: ($parent.productType // ""),
          variant_id: .id,
          variant_title: (.title // ""),
          sku: (.sku // ""),
          price: (.price // "")
        }
      ] |
      if length == 0 then empty
      else
        (.[0] | keys_unsorted) as $keys |
        ($keys | @csv),
        (.[] | [.[$keys[]]] | @csv)
      end
    ' "$INPUT"
    ;;
  orders)
    # Bulk JSONL: orders are parent lines, line items are child lines.
    # Join each line item to its parent order.
    jq -sr '
      ([.[] | select(.__parentId == null)] | map({(.id): .}) | add) as $orders |
      [
        .[] |
        select(.__parentId != null) |
        $orders[.__parentId] as $order |
        {
          order_id: $order.id,
          order_name: ($order.name // ""),
          email: ($order.email // ""),
          created_at: ($order.createdAt // ""),
          total_price: ($order.totalPriceSet.shopMoney.amount // ""),
          currency: ($order.totalPriceSet.shopMoney.currencyCode // ""),
          line_item_id: .id,
          line_item_title: (.title // ""),
          quantity: (.quantity // ""),
          sku: (.sku // "")
        }
      ] |
      if length == 0 then empty
      else
        (.[0] | keys_unsorted) as $keys |
        ($keys | @csv),
        (.[] | [.[$keys[]]] | @csv)
      end
    ' "$INPUT"
    ;;
  customers)
    # Customers with inline addresses (not a connection) appear as single lines.
    # Flatten each address into its own row, or output one row if no addresses.
    jq -sr '
      [
        .[] |
        . as $c |
        if (.addresses // [] | length) > 0 then
          .addresses[] |
          {
            customer_id: $c.id,
            first_name: ($c.firstName // ""),
            last_name: ($c.lastName // ""),
            email: ($c.email // ""),
            orders_count: ($c.numberOfOrders // ""),
            total_spent: ($c.amountSpent.amount // ""),
            address1: (.address1 // ""),
            city: (.city // ""),
            province: (.province // ""),
            country: (.country // ""),
            zip: (.zip // "")
          }
        else
          {
            customer_id: $c.id,
            first_name: ($c.firstName // ""),
            last_name: ($c.lastName // ""),
            email: ($c.email // ""),
            orders_count: ($c.numberOfOrders // ""),
            total_spent: ($c.amountSpent.amount // ""),
            address1: "",
            city: "",
            province: "",
            country: "",
            zip: ""
          }
        end
      ] |
      if length == 0 then empty
      else
        (.[0] | keys_unsorted) as $keys |
        ($keys | @csv),
        (.[] | [.[$keys[]]] | @csv)
      end
    ' "$INPUT"
    ;;
  *)
    # Auto mode: output all top-level scalar fields from each line (no joins).
    # Useful for simple flat exports or when the resource type is unknown.
    jq -sr '
      [.[] | select(.__parentId == null) | with_entries(select(.value | type != "object" and type != "array"))] |
      if length == 0 then empty
      else
        (.[0] | keys_unsorted) as $keys |
        ($keys | @csv),
        (.[] | [.[$keys[]]] | @csv)
      end
    ' "$INPUT"
    ;;
esac
