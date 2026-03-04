# MCP Setup Guide

How to connect the SearchAtlas MCP server to Claude Code.

## What is MCP?

[Model Context Protocol (MCP)](https://modelcontextprotocol.io/) lets Claude Code call external tools directly. The SearchAtlas MCP server exposes 50+ tool groups with ~287 operations covering SEO, GBP, PPC, content, press releases, and more.

## Step 1: Get Your API Key

1. Log in to [SearchAtlas](https://searchatlas.com)
2. Go to **Settings → API Keys**
3. Generate a new API key
4. Copy the key — you'll need it in the next step

## Step 2: Configure Claude Code

Add the SearchAtlas MCP server to your Claude Code settings.

### Option A: Edit settings.json directly

Open `~/.claude/settings.json` and add:

```json
{
  "mcpServers": {
    "searchatlas": {
      "type": "url",
      "url": "https://mcp.searchatlas.com/sse",
      "headers": {
        "X-API-KEY": "<your-api-key>"
      }
    }
  }
}
```

Replace `<your-api-key>` with the key from Step 1.

### Option B: Use the Claude Code CLI

```bash
claude mcp add searchatlas --type url \
  --url "https://mcp.searchatlas.com/sse" \
  --header "X-API-KEY: <your-api-key>"
```

## Step 3: Verify Connection

Open Claude Code and try:

```
/my-account
```

If the connection is working, you'll see your SearchAtlas account overview with all projects, businesses, and locations.

## Troubleshooting

### "credentials not provided"

Your API key is missing or invalid. Double-check:
- The key is correctly pasted in settings.json (no extra spaces)
- The key hasn't been revoked in SearchAtlas settings
- The header name is exactly `X-API-KEY` (case-sensitive)

### "Tool not found"

The tool name may have changed. Run schema discovery:
- Call any tool with empty params `{}` to see available operations
- Check [TOOL_REFERENCE.md](TOOL_REFERENCE.md) for current tool names

### Connection timeout

- Verify you can reach `https://mcp.searchatlas.com` from your network
- Check if a firewall or VPN is blocking the connection
- Try restarting Claude Code

### "Internal Server Error"

This is a server-side issue, not your fault. Wait a minute and retry. If it persists, check the [SearchAtlas status page](https://status.searchatlas.com).

## Protocol Details

| Setting | Value |
|---------|-------|
| Protocol | JSON-RPC 2.0 |
| Transport | Server-Sent Events (SSE) |
| Auth | API key via `X-API-KEY` header |
| Endpoint | `https://mcp.searchatlas.com/sse` |

## Security Notes

- **Never commit your API key** — use `.env` files or environment variables
- The `.gitignore` in this repo already excludes `.env`
- Each API key is scoped to your SearchAtlas account
- Revoke compromised keys immediately in SearchAtlas → Settings → API Keys
