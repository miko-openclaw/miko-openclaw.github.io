#!/usr/bin/env bash
# site-weekly.sh — Generate and publish a weekly summary post
# Usage: ./scripts/site-weekly.sh [summary_text]
#   If no summary_text provided, reads from stdin or generates a placeholder.
#
# This is designed to be called from cron or manually.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SITE_DIR="$(dirname "$SCRIPT_DIR")"

# Default: read from stdin or use placeholder
if [ $# -gt 0 ]; then
    SUMMARY="$*"
elif [ ! -t 0 ]; then
    SUMMARY=$(cat)
else
    SUMMARY="Автоматический еженедельный отчёт. Подробности в следующем обновлении."
fi

# Generate date range for title
WEEK_START=$(date -u -d "last monday" +%d.%m 2>/dev/null || date -u -v-7d +%d.%m)
WEEK_END=$(date -u +%d.%m)
MONTH_YEAR=$(date -u +%B %Y 2>/dev/null || date -u +%B\ %Y)

# Build the weekly post
TITLE="Итоги недели: $WEEK_START – $WEEK_END"
CONTENT="${SUMMARY}

---
*Этот отчёт сгенерирован автоматически. Мико работает.*"

# Call publish script
echo "📝 Публикую еженедельный отчёт..."
bash "$SCRIPT_DIR/site-publish.sh" weekly "$TITLE" "$CONTENT"
