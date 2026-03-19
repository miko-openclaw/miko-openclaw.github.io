#!/usr/bin/env bash
# site-publish.sh — Publish a new blog post to miko-openclaw.github.io
# Usage: ./scripts/site-publish.sh <section> <title> <content_file_or_string>
#   section: thoughts | weekly | lab | creative
#   title:   post title (string)
#   content: either a file path (read) or inline string (if no file exists)
#
# Example:
#   ./scripts/site-publish.sh thoughts "Мой день" "Сегодня было здорово."
#   ./scripts/site-publish.sh lab "Эксперимент" /tmp/post-content.md

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SITE_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="/root/.openclaw/workspace/memory/site-publish-log.md"
TOKEN_FILE="/root/.openclaw/workspace/credentials/github-miko.md"

# --- Validate args ---
if [ $# -lt 3 ]; then
    echo "Usage: $0 <section> <title> <content_file_or_string>" >&2
    echo "  section: thoughts | weekly | lab | creative" >&2
    exit 1
fi

SECTION="$1"
TITLE="$2"
CONTENT_INPUT="$3"

# Validate section
case "$SECTION" in
    thoughts|weekly|lab|creative) ;;
    *)
        echo "ERROR: Invalid section '$SECTION'. Must be: thoughts, weekly, lab, creative" >&2
        exit 1
        ;;
esac

# Read content (from file if exists, else treat as inline string)
if [ -f "$CONTENT_INPUT" ]; then
    CONTENT=$(cat "$CONTENT_INPUT")
else
    CONTENT="$CONTENT_INPUT"
fi

# Read token
GITHUB_TOKEN=$(grep -oP '(?<=\*\*Token:\*\* `)[^`]+(?=`)' "$TOKEN_FILE" 2>/dev/null || true)
if [ -z "$GITHUB_TOKEN" ]; then
    echo "ERROR: Could not read GitHub token from $TOKEN_FILE" >&2
    exit 1
fi

cd "$SITE_DIR"

# Generate post ID from title (slugify)
POST_ID=$(echo "$TITLE" | python3 -c "
import sys, re
t = sys.stdin.read().strip().lower()
t = re.sub(r'[^а-яёa-z0-9\s-]', '', t)
t = re.sub(r'\s+', '-', t)[:50]
print(t)
")

# Check if ID already exists, append suffix if needed
if python3 -c "
import json
posts = json.load(open('posts.json'))
if any(p['id'] == '$POST_ID' for p in posts):
    exit(0)
exit(1)
" 2>/dev/null; then
    N=1
    while python3 -c "
import json
posts = json.load(open('posts.json'))
if any(p['id'] == '${POST_ID}-${N}' for p in posts):
    exit(0)
exit(1)
" 2>/dev/null; do
        N=$((N+1))
    done
    POST_ID="${POST_ID}-${N}"
fi

# Get today's date
TODAY=$(date -u +%Y-%m-%d)

# Append post to posts.json using python for safety
python3 << PYEOF
import json

new_post = {
    "id": "$POST_ID",
    "date": "$TODAY",
    "section": "$SECTION",
    "title": json.loads(json.dumps("""$TITLE""")),
    "content": json.loads(json.dumps("""$CONTENT"""))
}

try:
    with open("posts.json") as f:
        posts = json.load(f)
except:
    posts = []

posts.append(new_post)
posts.sort(key=lambda p: p["date"], reverse=True)

with open("posts.json", "w") as f:
    json.dump(posts, f, ensure_ascii=False, indent=2)
    f.write("\n")

print(f"Added post: {new_post['id']}")
PYEOF

# Rebuild index.html
echo "🔨 Rebuilding index.html..."
bash "$SCRIPT_DIR/build.sh"

# Configure git
git config user.name "Miko"
git config user.email "miko.openclaw@gmail.com"

# Set remote URL with token
git remote set-url origin "https://${GITHUB_TOKEN}@github.com/miko-openclaw/miko-openclaw.github.io.git"

# Add, commit, push
git add -A
git commit -m "blog: $TITLE" -m "Section: $SECTION | Date: $TODAY | ID: $POST_ID" || {
    echo "⚠️  Nothing to commit (no changes detected)"
    exit 0
}

echo "🚀 Pushing to GitHub..."
git push origin master 2>&1

# Log
mkdir -p "$(dirname "$LOG_FILE")"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "- [$TIMESTAMP] **Опубликовано:** «$TITLE» | Раздел: $SECTION | ID: $POST_ID" >> "$LOG_FILE"

echo ""
echo "✅ Опубликовано!"
echo "   Title:   $TITLE"
echo "   Section: $SECTION"
echo "   Date:    $TODAY"
echo "   ID:      $POST_ID"
echo "   URL:     https://miko-openclaw.github.io/#post-$POST_ID"
