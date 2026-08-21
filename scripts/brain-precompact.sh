#!/usr/bin/env bash
# Fires immediately before compaction (auto or manual). Snapshots the raw transcript to
# disk so that even a bad compaction is recoverable: you can grep the .jsonl later.
#
# This is a safety net, not the brain file. The brain file is written deliberately by
# /brain:save while the model still has headroom. Uses jq if installed, python3 otherwise.
set -uo pipefail

cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0

INPUT=$(cat)

json_get() {
  printf '%s' "$INPUT" | python3 -c \
    'import json,sys; print(json.load(sys.stdin).get(sys.argv[1], ""))' "$1" 2>/dev/null || true
}

if command -v jq >/dev/null 2>&1; then
  TRANSCRIPT=$(printf '%s' "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null || true)
  TRIGGER=$(printf '%s' "$INPUT" | jq -r '.trigger // "unknown"' 2>/dev/null || echo unknown)
else
  TRANSCRIPT=$(json_get transcript_path)
  TRIGGER=$(json_get trigger)
  [ -n "$TRIGGER" ] || TRIGGER=unknown
fi

[ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ] || exit 0

mkdir -p .claude/brain/.transcripts
cp "$TRANSCRIPT" ".claude/brain/.transcripts/$(date +%Y%m%d-%H%M%S)-${TRIGGER}.jsonl"

# Keep the last 20 snapshots only.
# (No `xargs -r` here: that flag is a GNU extension and BSD/macOS xargs rejects it.)
# shellcheck disable=SC2012
ls -1t .claude/brain/.transcripts/*.jsonl 2>/dev/null | tail -n +21 | while IFS= read -r old; do
  rm -f "$old"
done

exit 0
