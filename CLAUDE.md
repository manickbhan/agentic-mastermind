# Agentic Marketing Mastermind — Claude Code Context

> This file provides context to Claude Code when working in this repository.

---

## 1. What This Repo Is

A public toolkit for digital marketing agencies using SearchAtlas. Users clone this repo, connect their SearchAtlas MCP, and use slash commands to manage clients and execute marketing workflows.

**This is NOT an internal tool.** No confidential data, no hardcoded keys, no internal references.

---

## 2. MCP Server Configuration

**Production endpoint:** The SearchAtlas MCP server provides tools for SEO, GBP, PPC, content, press releases, and more.

**Connection:** Users configure MCP in `~/.claude/settings.json` with their own API key.

**Protocol:** JSON-RPC 2.0 via SSE transport.

**Tool call format:**
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {
    "name": "<tool_name>",
    "arguments": {
      "op": "<operation>",
      "params": { ... }
    }
  }
}
```

---

## 3. Golden Rules

### Rule 1: Schema Discovery First
Before calling ANY tool for the first time, send it with empty params `{}` to discover the real schema. Documentation may be outdated — the actual API response shows the correct parameter names, types, and required fields.

```
Example: Call tool with op: "help" and params: {} to see all operations
Then call with the specific op and params: {} to see that operation's schema
```

### Rule 2: Read Error Messages
- **Parameter Validation Error** → Wrong params. The error response contains the correct schema.
- **Internal Server Error** → Backend issue, not your fault. Retry later.
- **"credentials not provided"** → Auth issue. Check API key.
- **"Tool not found"** → Tool name changed. Run discovery again.

### Rule 3: Poll Async Tasks
Many operations return a task ID instead of immediate results. Poll for completion:
- Use `get_otto_task_status` or `get_otto_ppc_task_status` to check status
- Use `otto_wait` between polls (5-10 second intervals)
- Continue polling until `status = SUCCESS`

### Rule 4: Watch for Tool Name Collisions
Some short tool names map to multiple underlying tools. If a tool behaves unexpectedly:
- Try the full prefixed name (e.g., `otto_project_management` instead of `project_management`)
- Use schema discovery to verify which tool you're actually calling

### Rule 5: Never Hardcode IDs
- Project IDs, location IDs, business IDs — always discover them via API first
- Use `/my-account` to get the user's current resources before running workflows

### Rule 6: Never Expose Secrets
- API keys come from `.env` or MCP config — never print them
- When sharing results (Slack, Circle), only include public-safe data

---

## 4. Account Discovery Flow

When a user asks about their account, follow this order:

1. **OTTO Projects** — Call `project_management` → list all projects (domains, health scores)
2. **Brand Vaults** — Call `brand_vault` → list vaults (brand identity, assets)
3. **GBP Locations** — Call `gbp_locations` → list connected locations
4. **PPC Campaigns** — Call `business_crud` → list businesses, then `campaign` → list campaigns
5. **Content** — Call `content` tools to see articles, topical maps
6. **LLM Visibility** — Call `ai_visibility` tools for brand monitoring

Present results as a clean summary with counts and key metrics.

---

## 5. Workflow Execution Pattern

When running a workflow (e.g., `/run-seo`):

1. **Load the YAML template** from `workflows/`
2. **Ask which business** the user wants to target (use account discovery)
3. **Execute steps in order**, respecting `depends_on` declarations
4. **Report results** at each step with emoji status indicators
5. **Summarize** what was completed, what failed, and next steps

**Output format:**
```
✅  Step Name     Result/count    [View →](link)
⏳  Step Name     In progress...
❌  Step Name     Error: description
```

---

## 6. Slash Commands

All commands live in `commands/` as markdown files. They are installed to `~/.claude/commands/` via `setup.sh`.

| Command | File | Purpose |
|---------|------|---------|
| `/onboard-client` | `commands/onboard-client.md` | Core onboarding wizard |
| `/my-account` | `commands/my-account.md` | Account overview |
| `/business-report` | `commands/business-report.md` | Single business deep dive |
| `/run-seo` | `commands/run-seo.md` | SEO workflow |
| `/run-gbp` | `commands/run-gbp.md` | GBP workflow |
| `/run-ppc` | `commands/run-ppc.md` | PPC workflow |
| `/run-content` | `commands/run-content.md` | Content generation |
| `/run-pr` | `commands/run-pr.md` | Press releases |
| `/run-visibility` | `commands/run-visibility.md` | LLM visibility |
| `/send-slack` | `commands/send-slack.md` | Slack integration |
| `/send-circle` | `commands/send-circle.md` | Circle integration |
| `/help` | `commands/help.md` | Command listing |

---

## 7. Communication Integrations

### Slack
Uses Incoming Webhooks. The webhook URL is stored in `.env` as `SLACK_WEBHOOK_URL`.
Script: `integrations/slack/send-message.sh`

### Circle
Uses Circle API v2. API key stored in `.env` as `CIRCLE_API_KEY`.
Script: `integrations/circle/post-to-space.sh`

---

## 8. Important Conventions

- **Never fabricate data** — If a tool call fails, report the failure honestly
- **Always confirm before destructive actions** — Creating campaigns, publishing content, etc.
- **Use the workflow YAML templates** — Don't improvise multi-step processes
- **Keep output clean** — Use emoji + label + count/link format, not verbose paragraphs
- **Respect rate limits** — Space out rapid API calls, use polling for async operations
