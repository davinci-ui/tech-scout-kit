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

## Our Environment (know this before filtering)

We run a hospitality business (Falafel Brothers, Tokyo) with an AI-powered office:

**Hardware:** Mac Studio, 128GB unified RAM, Apple Silicon (M-series)
**AI Runtime:** OpenClaw gateway + Ollama (local LLM inference, Apple Silicon GPU)
**Agents:** DaVinci (orchestrator), HAL (coder), Sherry (HR analyst)
**Docker stack:** Qdrant, SearXNG, PostgreSQL + pgvector, Ollama embedders, data ingestion
**Data:** Synology NAS (SFTP), markdown knowledge base, vector embeddings
**Languages:** Python, Node.js, shell scripts
**Workflow:** Local-first, zero API cost where possible, Docker for services

Tools are useful to us if they can:
- Run on macOS / Apple Silicon / Docker
- Integrate with or enhance OpenClaw agents
- Plug into our existing stack (Ollama, Qdrant, PostgreSQL, SearXNG)
- Improve office operations (reporting, communication, data processing)
- Enhance our NAS-based document pipeline
- Add new capabilities (voice, vision, automation, monitoring)
- Be installed and running within an hour

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

Every find MUST pass ALL five tests:

| Test | Question |
|------|----------|
| ✅ Installable | Can we install it TODAY? (npm/brew/pip/docker) |
| ✅ Runs on our stack | Works on macOS ARM64, Docker, or our existing infra? |
| ✅ Solves a real problem | Does it improve something we actually do? (not theoretical) |
| ✅ Local/self-hosted | Runs without cloud dependencies or paid API keys? |
| ✅ Tool, not framework | Is it a tool we USE, not a framework we'd build around? |

**Fail any one → skip it. No padding.**

When judging "solves a real problem," think about:
- Would this help our agents work better? (memory, search, coding, automation)
- Would this help our office? (reporting, scheduling, communication, document processing)
- Would this add a new capability we don't have? (voice, vision, monitoring, dashboards)
- Would this replace something we're doing manually?

## Step 5: Write Verified Report
Overwrite today's report with the verified version. Format per tool:

```markdown
### [Tool Name](url)
**What:** One sentence
**Install:** `npm i -g tool` or `docker compose up`
**How it fits us:** How specifically this plugs into our stack or workflow
**Last updated:** date or "active"
**Verdict:** ✅ INSTALL / 👀 WATCH / ❌ SKIP
```

Maximum 10 tools in the report. Quality over quantity.

## Step 6: Announce Top Finds
Post a summary of the **top 1-5 verified tools only**:

```
🔍 Tech Scout — YYYY-MM-DD

1. **Tool Name** — what it does + how it fits us (`install command`)
2. **Tool Name** — what it does + how it fits us (`install command`)

Full report: /Volumes/Shared Documents/DaVinci/tech-scout-reports/
```

If nothing passes the filter: `🔍 Tech Scout — Nothing notable today.`

## What We're Looking For
- CLI tools that enhance agent workflows
- Self-hosted Docker apps for office operations
- Local TTS/STT/voice tools (Apple Silicon optimized)
- Local LLM tools, quantization, inference optimizations
- Ollama-compatible models and tools
- Browser automation & scraping tools
- Memory/RAG/vector DB tools (Qdrant-compatible)
- Document processing & OCR tools
- Monitoring & dashboard tools
- macOS automation tools

## What We're NOT Looking For
- Cloud-only services or paid API wrappers
- Frameworks that require building an app around them
- AI news, opinions, or ecosystem commentary
- Tools that only work on Linux x86 with NVIDIA GPUs
- Anything that duplicates what we already have working

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
