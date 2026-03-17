---
name: tech-scout
description: Daily automated scan for practical AI and dev tools. Searches GitHub, HN, Reddit, PyPI, npm via SearXNG, then verifies each find using web_fetch and agent-browser before reporting. Triggers on "run tech scout", "find new tools", "what's new in AI tools", or via daily cron.
---

# Tech Scout — Daily Tool Discovery

## Full Workflow

When triggered (by cron or manually), execute ALL steps in order:

### Step 1: Gather (SearXNG)
Run the gather script to search across all sources:
```bash
bash scripts/gather.sh
```
This creates a raw report at `${REPORT_DIR}/YYYY-MM-DD-scout-report.md`

### Step 2: Verify Each Find (web_fetch + agent-browser)
For every item in the raw report:
1. **web_fetch** the project URL — read the README, check what it actually does
2. If the page is a SPA or needs JS, use **agent-browser** instead
3. Check: is it actively maintained? When was the last commit/release?
4. Check: what are the actual install steps?

### Step 3: Apply Filter (ruthlessly)
Every find MUST pass ALL four tests:

| Test | Question | Fail = Skip |
|------|----------|-------------|
| ✅ Installable | Can we `npm/brew/pip/docker install` it TODAY? | Skip |
| ✅ Useful | Does it solve a REAL problem we have? | Skip |
| ✅ Local | Does it run locally or self-hosted? | Skip |
| ✅ Tool | Is it a TOOL, not a framework/platform/theory? | Skip |

**No "looks promising" or "might be useful someday." If it doesn't pass all 4, kill it.**

### Step 4: Write Report
Save the verified report (up to 10 tools) to the reports directory.

Report format per tool:
```markdown
### [Tool Name](url)
**What:** One sentence description
**Install:** `npm i -g tool` or `docker compose up`
**Why it matters:** One sentence on what problem it solves
**Last updated:** date or "active"
**Verdict:** ✅ INSTALL / 👀 WATCH / ❌ SKIP
```

### Step 5: Announce (Top 5 only)
Post a brief summary — **maximum 5 tools**, even if the report has 10.

Format:
```
🔍 **Tech Scout — YYYY-MM-DD**

1. **Tool Name** — what it does (`install command`)
2. **Tool Name** — what it does (`install command`)
3. ...

Full report saved to reports/
```

If nothing passes the filter: `🔍 Tech Scout — Nothing notable today.`

## What We're Looking For
- CLI tools (npm/brew/pip)
- Self-hosted Docker apps
- Local TTS/STT/voice tools
- Local LLM/AI inference tools
- Browser automation & scraping
- Memory/RAG systems
- Agent orchestration tools

## What We're NOT Looking For
- AI ecosystem news or opinions
- Frameworks we'd need to build around
- Cloud-only services
- Anything requiring major infrastructure changes

## Sources
1. **GitHub** — New releases, trending repos
2. **Hacker News** — "Show HN" posts
3. **Reddit** — r/selfhosted, r/LocalLLaMA
4. **PyPI / npm** — New packages

## Cron Setup (OpenClaw)

```json5
{
  name: "tech-scout",
  schedule: { kind: "cron", expr: "0 7 * * *", tz: "Your/Timezone" },
  sessionTarget: "isolated",
  payload: {
    kind: "agentTurn",
    message: "You are a Tech Scout agent. Read and follow the tech-scout skill. Execute the FULL workflow: gather, verify, filter, report, announce top 5. Do NOT announce anything you haven't verified by reading the project page.",
    model: "kimi"
  },
  delivery: { mode: "announce" }
}
```

## Environment

| Variable | Default | Purpose |
|----------|---------|---------|
| `SEARXNG_URL` | `http://localhost:8890` | SearXNG instance |
| `REPORT_DIR` | `~/.openclaw/tech-scout/reports` | Report output directory |

## Requirements
- SearXNG running (see [web-intel-kit](https://github.com/ApeironOne/web-intel-kit))
- `web_fetch` (built into OpenClaw)
- `agent-browser` (`npm i -g agent-browser`)
- `curl`, `python3`
