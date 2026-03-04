#!/usr/bin/env bash
# Agentic Marketing Mastermind — Interactive Setup Wizard
# Creates .env with API keys and configures Claude Code MCP servers.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_DIR/.env"
CLAUDE_CONFIG="$HOME/.claude.json"

echo ""
echo "  Agentic Marketing Mastermind — Setup Wizard"
echo "  ============================================"
echo ""

# ── Step 1/4: SearchAtlas API Key (required) ─────────────────────────────────

echo "Step 1/4: SearchAtlas API Key (REQUIRED)"
echo "  Get yours at: https://searchatlas.com -> Settings -> API Keys"
echo ""

read -s -p "  Enter your SearchAtlas API key: " SA_API_KEY
echo ""

if [[ -z "$SA_API_KEY" ]]; then
  echo "  ERROR: SearchAtlas API key is required. Aborting."
  exit 1
fi

read -s -p "  Staging API key (Enter to skip): " SA_STAGING_API_KEY
echo ""
echo ""

# ── Step 2/4: Slack Webhook (optional) ───────────────────────────────────────

echo "Step 2/4: Slack Webhook URL (optional — for /send-slack)"
echo "  Create one at: https://api.slack.com/messaging/webhooks"
echo ""

read -p "  Slack Webhook URL (Enter to skip): " SLACK_WEBHOOK_URL
echo ""

# ── Step 3/4: Circle API (optional) ─────────────────────────────────────────

echo "Step 3/4: Circle Community API (optional — for /send-circle)"
echo "  Get your key at: https://app.circle.so -> Settings -> API"
echo ""

read -p "  Circle API Key (Enter to skip): " CIRCLE_API_KEY
CIRCLE_COMMUNITY_ID=""
if [[ -n "${CIRCLE_API_KEY:-}" ]]; then
  read -p "  Circle Community ID: " CIRCLE_COMMUNITY_ID
fi
echo ""

# ── Write .env ───────────────────────────────────────────────────────────────

echo "Writing .env..."

cat > "$ENV_FILE" <<EOF
# Agentic Marketing Mastermind — Environment Variables
# DO NOT COMMIT this file.

# SearchAtlas API Key (required)
SA_API_KEY=$SA_API_KEY
SA_STAGING_API_KEY=${SA_STAGING_API_KEY:-}

# Slack Integration (optional)
SLACK_WEBHOOK_URL=${SLACK_WEBHOOK_URL:-}

# Circle Community Integration (optional)
CIRCLE_API_KEY=${CIRCLE_API_KEY:-}
CIRCLE_COMMUNITY_ID=${CIRCLE_COMMUNITY_ID:-}
EOF

chmod 600 "$ENV_FILE"
echo "  Created $ENV_FILE (permissions: 600)"

# Ensure .env is in .gitignore
if [[ -f "$PROJECT_DIR/.gitignore" ]]; then
  if ! grep -q "^\.env$" "$PROJECT_DIR/.gitignore" 2>/dev/null; then
    echo ".env" >> "$PROJECT_DIR/.gitignore"
    echo "  Added .env to .gitignore"
  fi
else
  echo ".env" > "$PROJECT_DIR/.gitignore"
  echo "  Created .gitignore with .env entry"
fi

# ── Step 4/4: Configure Claude Code MCP servers ─────────────────────────────

echo ""
echo "Step 4/4: Configuring Claude Code MCP servers"

# Use python3 for reliable JSON manipulation (jq fallback)
if command -v python3 &>/dev/null; then
  JSON_TOOL="python3"
elif command -v jq &>/dev/null; then
  JSON_TOOL="jq"
else
  echo "  WARNING: Neither python3 nor jq found. Skipping MCP config."
  echo "  Please manually add MCP server config. See docs/MCP_SETUP.md"
  echo ""
  echo "Setup complete (partial). Run: bash scripts/verify-setup.sh"
  exit 0
fi

PROJECT_PATH="$PROJECT_DIR"

if [[ "$JSON_TOOL" == "python3" ]]; then
  python3 - "$CLAUDE_CONFIG" "$PROJECT_PATH" "$SA_API_KEY" "${SA_STAGING_API_KEY:-}" <<'PYEOF'
import json, sys, os

config_path = sys.argv[1]
project_path = sys.argv[2]
api_key = sys.argv[3]
staging_key = sys.argv[4] if len(sys.argv) > 4 else ""

# Read existing config or create skeleton
if os.path.exists(config_path):
    with open(config_path, 'r') as f:
        config = json.load(f)
else:
    config = {}

# Ensure structure
if "projects" not in config:
    config["projects"] = {}
if project_path not in config["projects"]:
    config["projects"][project_path] = {}
if "mcpServers" not in config["projects"][project_path]:
    config["projects"][project_path]["mcpServers"] = {}

servers = config["projects"][project_path]["mcpServers"]

# Add/update production server
servers["searchatlas"] = {
    "type": "http",
    "url": "https://mcp.searchatlas.com/api/v1/mcp",
    "headers": {
        "X-API-KEY": api_key
    }
}

# Add/update staging server if key provided
if staging_key:
    servers["searchatlas-staging"] = {
        "type": "http",
        "url": "https://mcp.staging.searchatlas.com/api/v1/mcp",
        "headers": {
            "X-API-KEY": staging_key
        }
    }

with open(config_path, 'w') as f:
    json.dump(config, f, indent=2)

print(f"  Updated {config_path}")
if staging_key:
    print("  Configured: searchatlas (production) + searchatlas-staging")
else:
    print("  Configured: searchatlas (production)")
PYEOF

else
  # jq fallback
  TEMP_FILE=$(mktemp)
  if [[ -f "$CLAUDE_CONFIG" ]]; then
    cp "$CLAUDE_CONFIG" "$TEMP_FILE"
  else
    echo '{}' > "$TEMP_FILE"
  fi

  PROD_SERVER="{\"type\":\"http\",\"url\":\"https://mcp.searchatlas.com/api/v1/mcp\",\"headers\":{\"X-API-KEY\":\"$SA_API_KEY\"}}"

  jq --arg path "$PROJECT_PATH" --argjson server "$PROD_SERVER" \
    '.projects[$path].mcpServers.searchatlas = $server' "$TEMP_FILE" > "${TEMP_FILE}.out" \
    && mv "${TEMP_FILE}.out" "$TEMP_FILE"

  if [[ -n "${SA_STAGING_API_KEY:-}" ]]; then
    STAGING_SERVER="{\"type\":\"http\",\"url\":\"https://mcp.staging.searchatlas.com/api/v1/mcp\",\"headers\":{\"X-API-KEY\":\"$SA_STAGING_API_KEY\"}}"
    jq --arg path "$PROJECT_PATH" --argjson server "$STAGING_SERVER" \
      '.projects[$path].mcpServers["searchatlas-staging"] = $server' "$TEMP_FILE" > "${TEMP_FILE}.out" \
      && mv "${TEMP_FILE}.out" "$TEMP_FILE"
  fi

  mv "$TEMP_FILE" "$CLAUDE_CONFIG"
  echo "  Updated $CLAUDE_CONFIG"
fi

# ── Done ─────────────────────────────────────────────────────────────────────

echo ""
echo "  ============================================"
echo "  Setup complete!"
echo ""
echo "  Next steps:"
echo "    1. Verify:  bash scripts/verify-setup.sh"
echo "    2. Open Claude Code in this directory"
echo "    3. Try:     /my-account"
echo "  ============================================"
