#!/bin/bash
# tech-scout gather — find genuinely new, installable tools (not guides/listicles)
set -euo pipefail

SEARXNG="${SEARXNG_URL:-http://localhost:8890}/search"
DATE=$(date +%Y-%m-%d)
REPORT_DIR="${REPORT_DIR:-/Volumes/Shared Documents/DaVinci/tech-scout-reports}"
REPORT="$REPORT_DIR/${DATE}-scout-report.md"

mkdir -p "$REPORT_DIR"

search() {
    local query="$1"
    local encoded
    encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$query'''))")
    curl -s "${SEARXNG}?q=${encoded}&format=json&time_range=week" 2>/dev/null | \
        python3 -c "
import sys,json
JUNK = ['medium.com/@', 'howtogeek.com', 'xda-developers', 'substack.com', 'simplehomelab',
        'homelabcraft', 'pinggy.io', 'bugbug.io', 'testdino', 'markaicode',
        'best open source', 'ultimate guide', 'top 10', 'top 5', 'top 7',
        'beginner', 'getting started', 'what you need', 'survival guide',
        'essential skills', 'complete guide to', 'key differences']
try:
    d=json.load(sys.stdin)
    count=0
    for r in d.get('results',[]):
        if count >= 4: break
        url = r.get('url','').lower()
        title = r.get('title','').lower()
        if any(j in url or j in title for j in JUNK): continue
        print(f\"- [{r['title']}]({r['url']})\")
        if r.get('content'): print(f\"  {r['content'][:150]}\")
        count+=1
except: pass
" 2>/dev/null
}

echo "# Tech Scout Report — $DATE" > "$REPORT"
echo "" >> "$REPORT"
echo "**Filter:** New releases, GitHub repos, and project pages only. No listicles, guides, or blog spam." >> "$REPORT"
echo "" >> "$REPORT"

echo "### New GitHub Releases (AI/Dev Tools)" >> "$REPORT"
search "site:github.com new release AI CLI tool" >> "$REPORT"
echo "" >> "$REPORT"

echo "### Local TTS / Voice (New Projects)" >> "$REPORT"
search "site:github.com text-to-speech voice clone local" >> "$REPORT"
echo "" >> "$REPORT"

echo "### Self-Hosted Apps (New Releases)" >> "$REPORT"
search "site:github.com self-hosted docker new release" >> "$REPORT"
echo "" >> "$REPORT"

echo "### Python/Node Packages (New)" >> "$REPORT"
search "site:pypi.org OR site:npmjs.com new AI agent tool local" >> "$REPORT"
echo "" >> "$REPORT"

echo "### Hacker News (Show HN — Tools)" >> "$REPORT"
search "site:news.ycombinator.com Show HN CLI tool open source" >> "$REPORT"
echo "" >> "$REPORT"

echo "### Reddit Finds (r/selfhosted, r/LocalLLaMA)" >> "$REPORT"
search "site:reddit.com selfhosted OR LocalLLaMA new tool release this week" >> "$REPORT"
echo "" >> "$REPORT"

echo "---" >> "$REPORT"
echo "*Raw gather complete. Awaiting review phase.*" >> "$REPORT"
echo "*Filter: Is this a NEW project/release? Can we install it? Does it solve a problem we actually have?*" >> "$REPORT"

echo "✓ Report written: $REPORT"
