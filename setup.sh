#!/usr/bin/env bash
# Agentic Marketing Mastermind — Setup Script
# Installs slash commands to ~/.claude/commands/ for use in Claude Code

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMANDS_SRC="$SCRIPT_DIR/commands"
COMMANDS_DST="$HOME/.claude/commands"

echo "=== Agentic Marketing Mastermind Setup ==="
echo ""

# Create commands directory if it doesn't exist
mkdir -p "$COMMANDS_DST"

# Copy all command files
if [ -d "$COMMANDS_SRC" ] && [ "$(ls -A "$COMMANDS_SRC" 2>/dev/null)" ]; then
    cp "$COMMANDS_SRC"/*.md "$COMMANDS_DST/" 2>/dev/null || true
    echo "Installed commands:"
    for f in "$COMMANDS_SRC"/*.md; do
        name=$(basename "$f" .md)
        echo "  /$name"
    done
else
    echo "No commands found in $COMMANDS_SRC"
    echo "Commands will be available after they are created."
fi

echo ""

# Check for .env
if [ ! -f "$SCRIPT_DIR/.env" ]; then
    echo "NOTE: No .env file found."
    echo "  Copy .env.example to .env and add your SearchAtlas API key:"
    echo "  cp .env.example .env"
    echo ""
fi

# Check for MCP configuration
SETTINGS_FILE="$HOME/.claude/settings.json"
if [ -f "$SETTINGS_FILE" ]; then
    if grep -q "searchatlas" "$SETTINGS_FILE" 2>/dev/null; then
        echo "SearchAtlas MCP server found in Claude Code settings."
    else
        echo "NOTE: SearchAtlas MCP server not found in Claude Code settings."
        echo "  See docs/MCP_SETUP.md for configuration instructions."
    fi
else
    echo "NOTE: Claude Code settings file not found at $SETTINGS_FILE"
    echo "  See docs/MCP_SETUP.md for configuration instructions."
fi

echo ""
echo "Setup complete! Open Claude Code in this directory and try /help"
