---
name: tech-scout
description: Daily automated scan for practical AI and dev tools. Searches GitHub, HN, Reddit, PyPI, and npm for new CLI tools, self-hosted apps, local AI models, and automation tools. Two-phase system — gather via SearXNG, then review with strict filter criteria.
---

# Tech Scout — Daily Tool Discovery

## Filter Criteria

Every find MUST pass this test:
1. **Can we install it today?** (npm/brew/pip/docker)
2. **Does it solve a real problem we have?**
3. **Does it run locally or self-hosted?** (prefer over cloud)
4. **Is it a TOOL, not a framework/platform/theory?**

If it doesn't pass all 4 — skip it.

## What We're Looking For

- CLI tools installable via npm/brew/pip
- Self-hosted Docker apps
- Local TTS/STT/voice tools
- Local image/video generation tools
- Browser automation & scraping tools
- Memory/RAG systems
- Agent orchestration tools
- Productivity/workflow CLI tools

## What We're NOT Looking For

- AI ecosystem news or opinions
- Frameworks we'd need to build around
- Cloud-only services
- Anything requiring major infrastructure changes

## Two-Phase System

### Phase 1: Gather (Zero Tokens)
```bash
bash scripts/gather.sh
```
Runs SearXNG queries against GitHub, HN, Reddit, PyPI, npm.
Writes raw report to `reports/YYYY-MM-DD-scout-report.md`.

### Phase 2: Review (Agent)
Read the report. Apply filter criteria ruthlessly.
Test-drive the best 1-3 finds. Report to the team.

## Sources

1. **GitHub** — New releases in AI/dev tools
2. **Hacker News** — "Show HN" for new tools
3. **Reddit** — r/selfhosted, r/LocalLLaMA
4. **PyPI / npm** — New AI agent packages
5. **Product Hunt** — AI tools category

## Cron Setup (OpenClaw)

```json5
{
  name: "tech-scout",
  schedule: { kind: "cron", expr: "0 7 * * *", tz: "Your/Timezone" },
  sessionTarget: "isolated",
  payload: {
    kind: "agentTurn",
    message: "Run: bash /path/to/tech-scout-kit/scripts/gather.sh\nThen review the report with the tech-scout skill filter criteria. Post top 1-3 finds or 'Nothing notable today'.",
    model: "kimi"  // or any cheap/free model
  },
  delivery: { mode: "announce" }
}
```

## Environment

| Variable | Default | Purpose |
|----------|---------|---------|
| `SEARXNG_URL` | `http://localhost:8890` | SearXNG instance |
| `REPORT_DIR` | `~/.openclaw/tech-scout/reports` | Where reports are saved |

## Requirements

- SearXNG running (see [web-intel-kit](https://github.com/ApeironOne/web-intel-kit))
- `curl`, `python3` (for URL encoding + JSON parsing)
- OpenClaw (for cron + agent review)
