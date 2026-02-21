#!/usr/bin/env bats

# Integration tests: cross-references between plugin files resolve correctly

REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
PLUGIN_DIR="$REPO_ROOT/plugins/shopify-cli-admin"

# --- Commands reference the skill ---

@test "all commands reference the shopify-admin-api skill" {
  for cmd_file in "$PLUGIN_DIR"/commands/*.md; do
    local body
    body=$(awk '/^---$/{ if(++n==2) found=1; next } found' "$cmd_file")
    echo "$body" | grep -qi "shopify-admin-api"
  done
}

# --- Skill references valid files ---

@test "SKILL.md references to references/ files all exist" {
  # Extract referenced files like references/graphql-patterns.md
  local refs
  refs=$(grep -oE 'references/[a-z-]+\.md' "$PLUGIN_DIR/skills/shopify-admin-api/SKILL.md" | sort -u)
  for ref in $refs; do
    [ -f "$PLUGIN_DIR/skills/shopify-admin-api/$ref" ]
  done
}

@test "SKILL.md references to scripts exist" {
  # The skill references scripts/bulk-to-csv.sh via CLAUDE_PLUGIN_ROOT
  grep -q 'bulk-to-csv.sh' "$PLUGIN_DIR/skills/shopify-admin-api/SKILL.md"
  [ -f "$PLUGIN_DIR/scripts/bulk-to-csv.sh" ]
}

@test "bulk-operations.md references bulk-to-csv.sh helper" {
  grep -q 'bulk-to-csv.sh' "$PLUGIN_DIR/skills/shopify-admin-api/references/bulk-operations.md"
}

# --- Commands reference valid reference docs ---

@test "shopify-query command references graphql-patterns.md" {
  grep -q 'graphql-patterns.md' "$PLUGIN_DIR/commands/shopify-query.md"
}

@test "shopify-bulk-export command references bulk-to-csv.sh" {
  grep -q 'bulk-to-csv.sh' "$PLUGIN_DIR/commands/shopify-bulk-export.md"
}

@test "shopify-dev-store-init command references graphql-patterns.md" {
  grep -q 'graphql-patterns.md' "$PLUGIN_DIR/commands/shopify-dev-store-init.md"
}

# --- Marketplace references valid plugin source paths ---

@test "marketplace.json plugin source paths exist" {
  local sources
  sources=$(jq -r '.plugins[].source' "$REPO_ROOT/.claude-plugin/marketplace.json")
  for src in $sources; do
    [ -d "$REPO_ROOT/$src" ]
  done
}

@test "marketplace.json plugin sources contain plugin.json" {
  local sources
  sources=$(jq -r '.plugins[].source' "$REPO_ROOT/.claude-plugin/marketplace.json")
  for src in $sources; do
    [ -f "$REPO_ROOT/$src/.claude-plugin/plugin.json" ]
  done
}

# --- Version consistency ---

@test "marketplace.json version matches plugin.json version" {
  local mp_version plugin_version
  mp_version=$(jq -r '.plugins[] | select(.name == "shopify-cli-admin") | .version' \
    "$REPO_ROOT/.claude-plugin/marketplace.json")
  plugin_version=$(jq -r '.version' "$PLUGIN_DIR/.claude-plugin/plugin.json")
  [ "$mp_version" = "$plugin_version" ]
}

@test "SKILL.md version matches plugin.json version" {
  local skill_version plugin_version
  skill_version=$(awk 'NR==1{next} /^---$/{exit} {print}' \
    "$PLUGIN_DIR/skills/shopify-admin-api/SKILL.md" | grep '^version:' | awk '{print $2}')
  plugin_version=$(jq -r '.version' "$PLUGIN_DIR/.claude-plugin/plugin.json")
  [ "$skill_version" = "$plugin_version" ]
}
