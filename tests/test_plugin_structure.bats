#!/usr/bin/env bats

# Test plugin structure, manifests, and command frontmatter

REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
PLUGIN_DIR="$REPO_ROOT/plugins/shopify-cli-admin"

# --- Marketplace manifest ---

@test "marketplace.json exists" {
  [ -f "$REPO_ROOT/.claude-plugin/marketplace.json" ]
}

@test "marketplace.json is valid JSON" {
  jq empty "$REPO_ROOT/.claude-plugin/marketplace.json"
}

@test "marketplace.json has required fields" {
  run jq -e '.name and .plugins' "$REPO_ROOT/.claude-plugin/marketplace.json"
  [ "$status" -eq 0 ]
}

@test "marketplace.json plugins array is non-empty" {
  run jq -e '.plugins | length > 0' "$REPO_ROOT/.claude-plugin/marketplace.json"
  [ "$status" -eq 0 ]
}

@test "marketplace.json plugin entries have required fields" {
  run jq -e '.plugins[] | .name and .description and .version and .source' \
    "$REPO_ROOT/.claude-plugin/marketplace.json"
  [ "$status" -eq 0 ]
}

# --- Plugin manifest ---

@test "plugin.json exists" {
  [ -f "$PLUGIN_DIR/.claude-plugin/plugin.json" ]
}

@test "plugin.json is valid JSON" {
  jq empty "$PLUGIN_DIR/.claude-plugin/plugin.json"
}

@test "plugin.json has required fields" {
  run jq -e '.name and .version and .description' "$PLUGIN_DIR/.claude-plugin/plugin.json"
  [ "$status" -eq 0 ]
}

@test "plugin.json name matches directory name" {
  local name
  name=$(jq -r '.name' "$PLUGIN_DIR/.claude-plugin/plugin.json")
  [ "$name" = "shopify-cli-admin" ]
}

@test "plugin.json version is semver format" {
  local version
  version=$(jq -r '.version' "$PLUGIN_DIR/.claude-plugin/plugin.json")
  [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

# --- Directory structure ---

@test "commands directory exists" {
  [ -d "$PLUGIN_DIR/commands" ]
}

@test "skills directory exists" {
  [ -d "$PLUGIN_DIR/skills" ]
}

@test "scripts directory exists" {
  [ -d "$PLUGIN_DIR/scripts" ]
}

@test "references directory exists" {
  [ -d "$PLUGIN_DIR/skills/shopify-admin-api/references" ]
}

# --- Command files ---

@test "all expected command files exist" {
  local commands=(
    shopify-query
    shopify-bulk-export
    shopify-dev-store-init
    shopify-function-test
    shopify-cart-test
  )
  for cmd in "${commands[@]}"; do
    [ -f "$PLUGIN_DIR/commands/${cmd}.md" ]
  done
}

@test "command files have YAML frontmatter" {
  for cmd_file in "$PLUGIN_DIR"/commands/*.md; do
    # First line must be ---
    local first_line
    first_line=$(head -1 "$cmd_file")
    [ "$first_line" = "---" ]
  done
}

@test "command files have description in frontmatter" {
  for cmd_file in "$PLUGIN_DIR"/commands/*.md; do
    # Extract frontmatter (between first and second ---) using awk
    awk 'NR==1{next} /^---$/{exit} {print}' "$cmd_file" | grep -q "^description:"
  done
}

@test "command files have allowed-tools in frontmatter" {
  for cmd_file in "$PLUGIN_DIR"/commands/*.md; do
    awk 'NR==1{next} /^---$/{exit} {print}' "$cmd_file" | grep -q "^allowed-tools:"
  done
}

# --- Skill files ---

@test "SKILL.md exists" {
  [ -f "$PLUGIN_DIR/skills/shopify-admin-api/SKILL.md" ]
}

@test "SKILL.md has YAML frontmatter with name" {
  local first_line
  first_line=$(head -1 "$PLUGIN_DIR/skills/shopify-admin-api/SKILL.md")
  [ "$first_line" = "---" ]
  awk 'NR==1{next} /^---$/{exit} {print}' "$PLUGIN_DIR/skills/shopify-admin-api/SKILL.md" | grep -q "^name:"
}

@test "graphql-patterns.md exists" {
  [ -f "$PLUGIN_DIR/skills/shopify-admin-api/references/graphql-patterns.md" ]
}

@test "bulk-operations.md exists" {
  [ -f "$PLUGIN_DIR/skills/shopify-admin-api/references/bulk-operations.md" ]
}

# --- Scripts ---

@test "bulk-to-csv.sh exists and is executable" {
  [ -f "$PLUGIN_DIR/scripts/bulk-to-csv.sh" ]
  [ -x "$PLUGIN_DIR/scripts/bulk-to-csv.sh" ]
}

@test "bulk-to-csv.sh has proper shebang" {
  local shebang
  shebang=$(head -1 "$PLUGIN_DIR/scripts/bulk-to-csv.sh")
  [ "$shebang" = "#!/usr/bin/env bash" ]
}
