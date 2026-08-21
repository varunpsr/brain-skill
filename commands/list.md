---
description: List this project's brain files with slug, date, and status
allowed-tools: Bash(git branch:*), Bash(ls:*), Bash(grep:*)
---

## Environment

- Branch: !`git branch --show-current`
- Brain files (newest first): !`ls -1t .claude/brain/*.md 2>/dev/null || echo "(none)"`
- Header lines: !`grep -H -m1 '^Slug:' .claude/brain/*.md 2>/dev/null || true`
- Status lines: !`grep -H -m1 '^Status:' .claude/brain/*.md 2>/dev/null || true`

## Task

From the environment above only (open no files, run nothing else), print one line per
brain file:

`<slug> · updated <date> · <status>`

Mark the file matching the current branch name with `←  current branch`. If a file has
no Slug/Status header, print its filename with `(no header)`.

If there are no brain files, say so in one line and mention `/brain:save`.

Do not start any work after the list.
