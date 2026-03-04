# Implementation Plan — Agentic Marketing Mastermind

> This file tracks what's been built and what still needs to be done.
> Delete this file before the repo goes fully public.

## Status

- [x] Phase 1: Foundation (.gitignore, .env.example, LICENSE, README, CLAUDE.md, setup.sh)
- [ ] Phase 2: Core Skills (commands/)
- [ ] Phase 3: Workflow Templates (workflows/)
- [ ] Phase 4: Communication Integrations (integrations/)
- [ ] Phase 5: Documentation (docs/)

---

## Phase 2: Core Skills — Commands to Build

Each command is a markdown file in `commands/` that Claude Code loads as a slash command.

### Priority Order

1. **`/help`** — List all commands (simplest, do first)
2. **`/my-account`** — Account discovery (foundation for everything else)
3. **`/onboard-client`** — THE core skill (guided wizard)
4. **`/business-report`** — Deep dive on one business
5. **`/run-seo`** — SEO workflow execution
6. **`/run-gbp`** — GBP workflow execution
7. **`/run-ppc`** — PPC workflow execution
8. **`/run-content`** — Content generation
9. **`/run-pr`** — Press releases + authority building
10. **`/run-visibility`** — LLM visibility audit
11. **`/send-slack`** — Slack webhook integration
12. **`/send-circle`** — Circle API integration

### Command Template Pattern

Each command file should follow this structure:
```markdown
# /command-name

Description of what the command does.

## Instructions

Step-by-step instructions for Claude to follow when this command is invoked.
Reference MCP tools by name, use the golden rules from CLAUDE.md.

## Output Format

How to present results to the user.
```

---

## Phase 3: Workflow Templates — YAMLs to Port

Port from `D:/SADEV/Orchestrator/plans/templates/` — sanitize all IDs, domains, staging refs.

| Template | Source | Status |
|----------|--------|--------|
| seo-onboarding.yaml | new-client-seo.yaml | [ ] |
| monthly-seo.yaml | monthly-seo.yaml | [ ] |
| gbp-optimization.yaml | gbp-optimization.yaml | [ ] |
| gbp-monthly.yaml | gbp-monthly.yaml | [ ] |
| ppc-launch.yaml | ppc-launch.yaml | [ ] |
| authority-building.yaml | authority-building.yaml | [ ] |
| llm-visibility.yaml | llm-visibility.yaml | [ ] |

---

## Phase 4: Communication Integrations

| Integration | Status |
|-------------|--------|
| Slack (Incoming Webhook) | [ ] |
| Circle (API v2) | [ ] |
| Google Sheets (stretch) | [ ] |

---

## Phase 5: Documentation

| Doc | Status |
|-----|--------|
| docs/MCP_SETUP.md | [ ] |
| docs/TOOL_REFERENCE.md | [ ] Port from Orchestrator tools-catalog.md |
| docs/GOLDEN_RULES.md | [ ] Port from Orchestrator operational/golden-rules.md |
| docs/WORKFLOWS.md | [ ] |

---

## Source Material Locations

- **Orchestrator**: `D:/SADEV/Orchestrator/` (Mac: `/Users/usuario/coding/Orquestrator/`)
  - `tools-catalog.md` — 52 tool groups, ~287 operations
  - `intent-mapping.md` — Keyword → tool routing
  - `operational/golden-rules.md` — 7 hard-won rules
  - `operational/ppc-campaign-playbook.md` — PPC strategy
  - `plans/templates/*.yaml` — All 7 workflow templates

- **MCP-agent**: `D:/SADEV/MCP-agent/`
  - `AGENT_PLAYBOOK.md` — 537-line tool registry + golden rules
  - `scripts/discover_tools.sh` — Schema discovery script
  - `tools_list.json` — Full 112-tool registry (reference only)

## Security Reminders

- No API keys, tokens, or credentials
- No staging URLs — production only
- No specific account IDs, business IDs, domain names
- No internal SearchAtlas engineering details
- All examples use placeholders: `your-business.com`, `<your-api-key>`, `<project-id>`
