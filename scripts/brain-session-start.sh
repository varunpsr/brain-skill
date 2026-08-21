#!/usr/bin/env bash
# Injects a pointer to the active brain file at session start, resume, clear, and
# post-compact. Stdout from a SessionStart hook is added to Claude's context.
#
# Phrased as factual project information, not as an instruction — text that reads like
# an out-of-band system command can trip Claude's prompt-injection defenses.
set -uo pipefail

cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0

BRANCH=$(git branch --show-current 2>/dev/null || true)
SLUG="${BRANCH##*/}"

FILE=""
if [ -n "$SLUG" ] && [ -f ".claude/brain/${SLUG}.md" ]; then
  FILE=".claude/brain/${SLUG}.md"
else
  # shellcheck disable=SC2012
  FILE=$(ls -t .claude/brain/*.md 2>/dev/null | head -1 || true)
fi

[ -n "$FILE" ] && [ -f "$FILE" ] || exit 0

STATUS=$(grep -m1 '^Status:' "$FILE" 2>/dev/null || echo "")

cat <<EOF
## Feature working memory

This project stores per-feature working memory at \`$FILE\`. It holds the feature's goal,
the decisions made and why, alternatives already rejected, approaches already tried and
failed, the relevant file map, and the next concrete action. It is more current than any
conversation summary. ${STATUS}

Reading that file is the fastest route to being oriented before changing anything here.
The \`/brain:load\` command reads it and verifies it against the current code.
EOF

exit 0
