#!/usr/bin/env bash
# Agentic Marketing Mastermind — Setup Verification
# Checks .env, claude.json, and optionally tests API connectivity.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_DIR/.env"
CLAUDE_CONFIG="$HOME/.claude.json"

PASS="[PASS]"
FAIL="[FAIL]"
WARN="[WARN]"
errors=0

echo "SearchAtlas MCP — Setup Verification"
echo "════════════════════════════════════════"
echo ""

# ── Check 1: .env file exists ────────────────────────────────────────────────

if [[ -f "$ENV_FILE" ]]; then
  echo "$PASS .env file exists"
else
  echo "$FAIL .env file not found at $ENV_FILE"
  echo "       Fix: run 'bash scripts/setup-interactive.sh'"
  errors=$((errors + 1))
fi

# ── Check 2: SA_API_KEY is set ───────────────────────────────────────────────

if [[ -f "$ENV_FILE" ]]; then
  # Source without exporting to avoid leaking
  SA_API_KEY=$(grep -E '^SA_API_KEY=' "$ENV_FILE" 2>/dev/null | head -1 | cut -d= -f2-)
  if [[ -n "${SA_API_KEY:-}" ]]; then
    echo "$PASS SA_API_KEY: configured"
  else
    echo "$FAIL SA_API_KEY: not set in .env"
    echo "       Fix: add SA_API_KEY=your_key_here to .env"
    errors=$((errors + 1))
  fi

  SA_STAGING_KEY=$(grep -E '^SA_STAGING_API_KEY=' "$ENV_FILE" 2>/dev/null | head -1 | cut -d= -f2-)
  if [[ -n "${SA_STAGING_KEY:-}" ]]; then
    echo "$PASS SA_STAGING_API_KEY: configured"
  else
    echo "$WARN SA_STAGING_API_KEY: not set (optional — needed for staging only)"
  fi
else
  echo "$FAIL SA_API_KEY: cannot check (no .env file)"
  errors=$((errors + 1))
fi

# ── Check 3: .env permissions ────────────────────────────────────────────────

if [[ -f "$ENV_FILE" ]]; then
  PERMS=$(stat -f "%Lp" "$ENV_FILE" 2>/dev/null || stat -c "%a" "$ENV_FILE" 2>/dev/null || echo "unknown")
  if [[ "$PERMS" == "600" ]]; then
    echo "$PASS .env permissions: 600 (owner-only)"
  else
    echo "$WARN .env permissions: $PERMS (recommended: 600)"
    echo "       Fix: chmod 600 .env"
  fi
fi

# ── Check 4: .gitignore includes .env ────────────────────────────────────────

if [[ -f "$PROJECT_DIR/.gitignore" ]] && grep -q "^\.env$" "$PROJECT_DIR/.gitignore" 2>/dev/null; then
  echo "$PASS .gitignore: .env is excluded from git"
else
  echo "$WARN .gitignore: .env not found in .gitignore"
  echo "       Fix: echo '.env' >> .gitignore"
fi

# ── Check 5: claude.json has searchatlas MCP server ──────────────────────────

if [[ -f "$CLAUDE_CONFIG" ]]; then
  if grep -q "searchatlas" "$CLAUDE_CONFIG" 2>/dev/null; then
    echo "$PASS claude.json: searchatlas MCP server configured"
  else
    echo "$FAIL claude.json: searchatlas MCP server not found"
    echo "       Fix: run 'bash scripts/setup-interactive.sh'"
    errors=$((errors + 1))
  fi
else
  echo "$FAIL claude.json: file not found at $CLAUDE_CONFIG"
  echo "       Fix: run 'bash scripts/setup-interactive.sh'"
  errors=$((errors + 1))
fi

# ── Check 6: Slack webhooks ───────────────────────────────────────────────────

if [[ -f "$ENV_FILE" ]]; then
  SLACK_URL=$(grep -E '^SLACK_WEBHOOK_URL=' "$ENV_FILE" 2>/dev/null | head -1 | cut -d= -f2-)
  SLACK_COUNT=$(grep -cE '^SLACK_WEBHOOK_' "$ENV_FILE" 2>/dev/null || echo "0")
  if [[ -n "${SLACK_URL:-}" ]]; then
    echo "$PASS Slack: configured ($SLACK_COUNT webhook(s))"
  else
    echo "$WARN Slack: not configured (optional — for /send-slack)"
  fi
fi

# ── Check 7: Discord webhook ────────────────────────────────────────────────

if [[ -f "$ENV_FILE" ]]; then
  DISCORD_URL=$(grep -E '^DISCORD_WEBHOOK_URL=' "$ENV_FILE" 2>/dev/null | head -1 | cut -d= -f2-)
  if [[ -n "${DISCORD_URL:-}" ]]; then
    echo "$PASS Discord: configured"
  else
    echo "$WARN Discord: not configured (optional — for /send-discord)"
  fi
fi

# ── Check 8: Email (Resend) ─────────────────────────────────────────────────

if [[ -f "$ENV_FILE" ]]; then
  RESEND_KEY=$(grep -E '^RESEND_API_KEY=' "$ENV_FILE" 2>/dev/null | head -1 | cut -d= -f2-)
  if [[ -n "${RESEND_KEY:-}" ]]; then
    echo "$PASS Email (Resend): configured"
  else
    echo "$WARN Email (Resend): not configured (optional — for /send-email)"
  fi
fi

# ── Check 9 (optional): API connectivity ─────────────────────────────────────

echo ""
if [[ -n "${SA_API_KEY:-}" ]] && command -v curl &>/dev/null; then
  echo "Testing API connectivity..."
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST "https://mcp.searchatlas.com/api/v1/mcp" \
    -H "Content-Type: application/json" \
    -H "X-API-KEY: $SA_API_KEY" \
    -d '{"jsonrpc":"2.0","method":"tools/list","id":1}' \
    --connect-timeout 10 2>/dev/null || echo "000")

  if [[ "$HTTP_CODE" == "200" ]]; then
    echo "$PASS API connectivity: production server reachable (HTTP $HTTP_CODE)"
  elif [[ "$HTTP_CODE" == "000" ]]; then
    echo "$WARN API connectivity: could not connect (network issue or timeout)"
  else
    echo "$WARN API connectivity: unexpected response (HTTP $HTTP_CODE)"
  fi
fi

# ── Summary ──────────────────────────────────────────────────────────────────

echo ""
echo "════════════════════════════════════════"
if [[ $errors -eq 0 ]]; then
  echo "All checks passed. You're ready to go!"
else
  echo "$errors check(s) failed. Fix the issues above and re-run."
fi
