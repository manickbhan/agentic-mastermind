# Agentic Marketing Mastermind Toolkit

A Claude Code toolkit for digital marketing agencies using [SearchAtlas](https://searchatlas.com). Connect your account, onboard clients, and execute marketing workflows — all from your terminal.

## What This Does

- **Account Discovery** — See all your businesses, projects, campaigns, and GBP locations
- **Client Onboarding** — Walk through setting up a new client with SEO, GBP, PPC, content, and more
- **Workflow Execution** — Run pre-built marketing workflows (SEO audits, GBP optimization, PPC campaigns, press releases, LLM visibility)
- **Communication** — Post results to Slack or Circle communities
- **Reporting** — Deep-dive business reports with audit scores, rankings, and campaign performance

## Quick Start

### 1. Prerequisites

- [Claude Code](https://claude.ai/code) installed
- A SearchAtlas account with an API key

### 2. Clone & Setup

```bash
git clone https://github.com/Search-Atlas-Group/agentic-mastermind.git
cd agentic-mastermind
cp .env.example .env
# Edit .env and add your SearchAtlas API key
```

### 3. Install Commands

```bash
bash setup.sh
```

This copies the slash commands to `~/.claude/commands/` so they're available in Claude Code.

### 4. Connect MCP

Add the SearchAtlas MCP server to your Claude Code config (`~/.claude/settings.json`):

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

See [docs/MCP_SETUP.md](docs/MCP_SETUP.md) for detailed instructions.

### 5. Use It

Open Claude Code in this directory and try:

```
/my-account          # See all your businesses and projects
/onboard-client      # Onboard a new client
/business-report     # Deep dive on a specific business
/run-seo             # Execute SEO workflow
/run-gbp             # Optimize a GBP profile
/run-ppc             # Launch a PPC campaign
/run-content         # Generate content
/run-pr              # Create press releases
/run-visibility      # LLM visibility audit
/send-slack           # Post to Slack
/help                # List all commands
```

## Available Commands

| Command | Description |
|---------|-------------|
| `/my-account` | Show all businesses, projects, campaigns, and GBP locations |
| `/onboard-client` | Guided client onboarding — collect info, map needs to tools, execute |
| `/business-report` | Deep dive report on a single business |
| `/run-seo` | Execute SEO onboarding or monthly maintenance workflow |
| `/run-gbp` | Optimize a Google Business Profile |
| `/run-ppc` | Build and launch a PPC campaign |
| `/run-content` | Generate articles, topical maps, content briefs |
| `/run-pr` | Create and distribute press releases |
| `/run-visibility` | Run LLM visibility and sentiment analysis |
| `/send-slack` | Post a message to Slack via webhook |
| `/send-circle` | Post to a Circle community space |
| `/help` | List all available commands |

## Workflows

Pre-built workflow templates live in `workflows/`. Each defines a step-by-step tool chain:

- **seo-onboarding.yaml** — Full SEO setup: project creation, audit, keywords, content
- **monthly-seo.yaml** — Recurring SEO: suggestions, schema, indexing, grading
- **gbp-optimization.yaml** — GBP profile cleanup: recommendations, categories, services
- **gbp-monthly.yaml** — GBP maintenance: reviews, posts, automation
- **ppc-launch.yaml** — PPC campaign: business, products, keywords, campaigns
- **authority-building.yaml** — PR and link building: press releases, cloud stacks, digital PR
- **llm-visibility.yaml** — AI search monitoring: visibility, sentiment, SERP analysis

## Communication Integrations

- **Slack** — Uses Incoming Webhooks. See [integrations/slack/README.md](integrations/slack/README.md)
- **Circle** — Uses Circle API v2. See [integrations/circle/README.md](integrations/circle/README.md)

## Documentation

- [MCP Setup Guide](docs/MCP_SETUP.md) — How to get your API key and connect
- [Tool Reference](docs/TOOL_REFERENCE.md) — All available MCP tools and operations
- [Golden Rules](docs/GOLDEN_RULES.md) — Best practices for reliable tool usage
- [Workflows Guide](docs/WORKFLOWS.md) — How workflow templates work

## Updating

We add new commands and workflows regularly. To get updates:

```bash
git pull origin main
bash setup.sh
```

## License

MIT — see [LICENSE](LICENSE)
