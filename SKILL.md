---
name: tech-scout
description: Daily automated scan for practical AI and dev tools. Searches GitHub, HN, Reddit, PyPI, npm via SearXNG, then verifies each find using web_fetch and agent-browser before reporting. Triggers on "run tech scout", "find new tools", "what's new in AI tools", or via daily cron.
---

# Tech Scout — Daily Tool Discovery

## Trigger
This skill runs as a **self-contained process**. When triggered:
1. The agent executes ALL steps below in order
2. Saves the report to disk
3. Announces the top finds
4. Done — no human intervention needed

Triggers: "run tech scout", "find new tools", "what's new in AI tools", daily cron, or any request for new tool discovery.

## Step 1: Gather (zero tokens)
Run the gather script to search all sources via SearXNG:
```bash
bash <skill-dir>/scripts/gather.sh
```
Report lands at `/Volumes/Shared Documents/DaVinci/tech-scout-reports/YYYY-MM-DD-scout-report.md`

If SearXNG is down, fall back to `web_fetch` + manual search queries.

## Step 2: Read the Raw Report
```bash
cat /Volumes/Shared Documents/DaVinci/tech-scout-reports/$(date +%Y-%m-%d)-scout-report.md
```

## Step 3: Verify Each Promising Find
For every item that looks real (not a listicle, guide, or blog spam):
1. **web_fetch** the project URL — read the README
2. If the page needs JS rendering, use **agent-browser** instead
3. Check: actively maintained? Last commit/release date?
4. Check: what are the actual install steps?

**Do NOT announce anything you haven't verified by reading the project page.**

## Step 4: Apply Filter (ruthlessly)
Every find MUST pass ALL four tests:

| Test | Question |
|------|----------|
| ✅ Installable | Can we `npm/brew/pip/docker install` it TODAY? |
| ✅ Useful | Does it solve a REAL problem we have? |
| ✅ Local | Does it run locally or self-hosted? |
| ✅ Tool | Is it a TOOL, not a framework/platform/theory? |

Fail any one → skip it. No "looks promising" or "might be useful someday."

## Step 5: Write Verified Report
Overwrite today's report with the verified version. Format per tool:

```markdown
### [Tool Name](url)
**What:** One sentence
**Install:** `npm i -g tool` or `docker compose up`
**Why it matters:** What problem it solves for us
**Last updated:** date or "active"
**Verdict:** ✅ INSTALL / 👀 WATCH / ❌ SKIP
```

Maximum 10 tools in the report. Quality over quantity.

## Step 6: Announce Top Finds
Post a summary of the **top 1-5 verified tools only**:

```
🔍 Tech Scout — YYYY-MM-DD

1. **Tool Name** — what it does (`install command`)
2. **Tool Name** — what it does (`install command`)

Full report: /Volumes/Shared Documents/DaVinci/tech-scout-reports/
```

If nothing passes the filter: `🔍 Tech Scout — Nothing notable today.`

## What We're Looking For
- CLI tools installable via npm/brew/pip
- Self-hosted Docker apps
- Local TTS/STT/voice tools
- Local LLM/AI inference tools
- Browser automation & scraping tools
- Memory/RAG systems
- Agent orchestration tools
- Productivity/workflow CLI tools

## What We're NOT Looking For
- AI ecosystem news or opinions
- Frameworks we'd need to build around
- Cloud-only services
- Anything requiring major infrastructure changes
- Listicles, "ultimate guides", "top 10" articles

## Environment

| Variable | Default | Purpose |
|----------|---------|---------|
| `SEARXNG_URL` | `http://localhost:8890` | SearXNG instance |
| `REPORT_DIR` | `/Volumes/Shared Documents/DaVinci/tech-scout-reports` | Report output directory |

## Requirements
- SearXNG running (port 8890)
- `web_fetch` tool (built into OpenClaw)
- `agent-browser` CLI (`npm i -g agent-browser`)
- `curl`, `python3`
