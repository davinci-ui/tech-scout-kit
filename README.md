# Tech Scout Kit for OpenClaw

Automated daily tool discovery for [OpenClaw](https://github.com/openclaw/openclaw) agents. Finds new CLI tools, self-hosted apps, local AI models, and dev tools — then filters out the noise.

## What It Does

Every day, your agent:
1. **Searches** GitHub, Hacker News, Reddit, PyPI, and npm via SearXNG
2. **Filters** ruthlessly — only tools you can install today, that solve real problems
3. **Reports** the top 1-3 finds with install instructions

No listicles. No "ultimate guides." No cloud-only services. Just tools you can `npm install` or `docker compose up` right now.

## Quick Start

### 1. Install SearXNG

Tech Scout uses SearXNG for search. If you don't have it:

```bash
# From web-intel-kit (https://github.com/ApeironOne/web-intel-kit)
cd docker && docker compose up -d
```

Or set `SEARXNG_URL` to your existing instance.

### 2. Run Manually

```bash
bash scripts/gather.sh
```

Report saved to `~/.openclaw/tech-scout/reports/YYYY-MM-DD-scout-report.md`.

### 3. Set Up Daily Cron (OpenClaw)

```json5
{
  name: "tech-scout",
  schedule: { kind: "cron", expr: "0 7 * * *", tz: "Your/Timezone" },
  sessionTarget: "isolated",
  payload: {
    kind: "agentTurn",
    message: "Run: bash /path/to/tech-scout-kit/scripts/gather.sh\nThen review the report. Apply these filters to each find:\n1. Can we install it today?\n2. Does it solve a real problem?\n3. Does it run locally/self-hosted?\n4. Is it a TOOL, not a framework?\nPost top 1-3 finds or 'Nothing notable today'.",
    model: "kimi"
  },
  delivery: { mode: "announce" }
}
```

### 4. Install the Skill

```bash
cp SKILL.md /path/to/your/skills/tech-scout/SKILL.md
```

Or point OpenClaw at this repo:

```json5
{
  skills: {
    load: {
      extraDirs: ["/path/to/tech-scout-kit"],
      watch: true
    }
  }
}
```

## The Filter

Every find MUST pass all four tests:

| Test | Question |
|------|----------|
| ✅ Installable | Can we install it today? (npm/brew/pip/docker) |
| ✅ Useful | Does it solve a real problem we have? |
| ✅ Local | Does it run locally or self-hosted? |
| ✅ Tool | Is it a TOOL, not a framework/platform/theory? |

**Fail any one? Skip it.** No padding, no "might be useful someday."

## Sources Searched

- **GitHub** — New releases, trending repos
- **Hacker News** — "Show HN" posts
- **Reddit** — r/selfhosted, r/LocalLLaMA
- **PyPI** — New Python packages
- **npm** — New Node packages

## Structure

```
tech-scout-kit/
├── README.md
├── SKILL.md              # OpenClaw skill definition
├── scripts/
│   └── gather.sh         # SearXNG search + report generator
└── reports/              # Generated reports land here
```

## Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `SEARXNG_URL` | `http://localhost:8890` | SearXNG instance URL |
| `REPORT_DIR` | `~/.openclaw/tech-scout/reports` | Report output directory |

## Previous Discoveries

Tools originally found by Tech Scout:
- **SearXNG** — Self-hosted search engine (now in [web-intel-kit](https://github.com/ApeironOne/web-intel-kit))
- **agent-browser** — Headless Chrome CLI for AI agents
- **MLX tools** — Local LLM inference on Apple Silicon

## Related

- [web-intel-kit](https://github.com/ApeironOne/web-intel-kit) — SearXNG + web tools (required dependency)
- [memory-alpha-kit](https://github.com/ApeironOne/memory-alpha-kit) — Agent memory system

## License

MIT
