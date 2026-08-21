---
description: Write/update the feature brain file so a cold session can resume
argument-hint: [feature-slug]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git status:*), Bash(git log:*), Bash(git diff:*), Bash(git branch:*), Bash(git merge-base:*), Bash(ls:*), Bash(wc:*), Bash(mkdir:*)
---

## Environment

- Branch: !`git branch --show-current`
- Uncommitted: !`git status --short`
- Recent commits: !`git log --oneline -40`
- Existing brain files: !`ls -1 .claude/brain/*.md 2>/dev/null || echo "(none)"`

## Task

Feature slug: `$1`. If empty, derive it from the branch name (strip any `feat/` prefix).
If that still fails, list existing brain files and ask me which one.

Write or update `.claude/brain/<slug>.md`.

Assume this file is the **only** thing the next session will have. Assume that session has
zero memory of this conversation and has never opened this codebase. Assume a model reads
it, not a human.

### Rules

1. **Update in place, don't append.** If the file exists, revise it. Delete anything that
   is now false. This is a snapshot of current truth, not a chronological log.
2. **Pointers, not paste.** Write `src/db/repo.ts:142`, never paste code blocks. Code
   copied into this file is stale the moment it lands and will actively mislead.
3. **Rationale is the payload.** Every decision gets a *why* and a *what was rejected*.
   A session that doesn't know why will re-litigate the decision or silently undo it.
   This is the single highest-value thing in the file.
4. **Record failures.** Everything tried that didn't work, and why. This is what keeps the
   next session from walking into the same wall for the third time.
5. **No conversation narration.** Never write "the user asked me to" or "we then
   discussed". Write project state only.
6. **Hard cap: 200 lines.** If you exceed it, prune rather than trim quality: promote
   settled decisions into `SPEC.md` or `CLAUDE.md`, drop dead ends that are no longer
   reachable, collapse finished work into one line.
7. **Flag uncertainty.** Anything you infer rather than verify gets marked `[UNVERIFIED]`.
   A confident wrong statement is worse than a gap.

### Structure

Use exactly this structure. Omit a section only if it is genuinely empty.

```markdown
# Brain: <feature name>

Slug: <slug> · Branch: <branch> · Updated: <YYYY-MM-DD>
Status: <one line — what works, what doesn't, where we stopped>

## Goal
<2-4 sentences: what this feature is, and what "done" means.>

Done when:
- [ ] <acceptance criterion>
- [ ] <acceptance criterion>

## Constraints & invariants
<Things that must stay true: architectural rules, perf budgets, compat requirements,
API shapes that other code depends on. The next session will break these if they
aren't written down here.>

## Decisions
| Decision | Why | Rejected alternative |
|---|---|---|
| <what> | <reason> | <what we didn't do, and why not> |

## Dead ends
- **<what was tried>** → <how it failed> → <root cause if known>

## Files that matter
| Path | Role in this feature |
|---|---|
| `<path>` | <one line> |

## Where we are
- Done: <...>
- In progress: <exact file, exactly what is half-finished>
- Not started: <...>

## Next actions
1. <the single next concrete thing — specific enough to start on immediately>
2. <...>

## Open questions (blocked on me)
- <...>

## Verification
- Run: `<exact commands>`
- Green looks like: <...>
- Known-failing, expected: <...>
```

After writing, print only the diff summary: what you added, changed, and removed. Do not
echo the whole file back.
