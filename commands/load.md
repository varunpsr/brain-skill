---
description: Load a feature's brain file, verify it against the code, and re-orient
argument-hint: [feature-slug]
allowed-tools: Read, Glob, Grep, Bash(git status:*), Bash(git log:*), Bash(git branch:*), Bash(ls:*)
---

## Environment

- Branch: !`git branch --show-current`
- Uncommitted: !`git status --short`
- Recent commits: !`git log --oneline -15`
- Available brain files: !`ls -1 .claude/brain/*.md 2>/dev/null || echo "(none)"`

## Task

Read `.claude/brain/$1.md`. If `$1` is empty, pick the file matching the current branch;
if there's no match, list what exists and ask.

Then, **before touching any code**:

1. Open every path in "Files that matter" and confirm the brain file still describes
   reality. It was written at a point in time; the code may have moved since.
2. Run the commands in "Verification". Report actual output against what the file claims.
3. Print an orientation of **10 lines or fewer**:
   - Goal, in one line
   - Current state, in one line
   - The next action
   - Every place the brain file and the code now disagree

Rules for this step:

- **The code wins.** Where the brain file and the codebase conflict, the codebase is
  correct and the brain file is stale. Say so explicitly rather than reconciling silently.
- Do not start work. Do not "helpfully" begin the next action. Stop after the orientation
  and wait for me.
- Do not re-explore the codebase beyond the listed files. The file map exists so you don't
  burn context rediscovering the same things.
