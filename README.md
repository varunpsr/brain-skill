# Brain: working memory for Claude Code

Per-feature working memory that survives `/clear`, auto-compact, and a three-day gap.
You save the state of a feature to a small markdown file while the session still has
context; a fresh session reads it back, verifies it against the code, and picks up where
you stopped, without burning tokens rediscovering the codebase.

## How it works

Four pieces cooperate:

| Piece | What it does |
|---|---|
| `/brain:save <slug>` | Writes or updates `.claude/brain/<slug>.md` in the project: the feature's goal, decisions and *why*, rejected alternatives, dead ends, file map, exact next action. Hard-capped at 200 lines, pointers instead of pasted code. |
| `/brain:load <slug>` | Reads the file, opens every path it names to confirm it still matches reality, runs the verification commands, and prints a 10-line orientation. The code always wins over the file. |
| SessionStart hook | On every session start (including after `/clear` and compaction), injects a pointer to the active brain file so Claude knows it exists and reads it before exploring. |
| PreCompact hook | Snapshots the raw transcript to `.claude/brain/.transcripts/` right before compaction, so even a bad compaction is recoverable. Keeps the last 20 snapshots. Safety net only; the brain file is the real mechanism. |

Config is global (the plugin), data is per-repo: a brain file lives next to the code it
describes. See [examples/brain-file.md](examples/brain-file.md) for what a saved brain
file actually looks like.

## Install

```
/plugin marketplace add varunpsr/brain-skill
/plugin install brain@brain-marketplace
```

To try it from a local clone instead:

```bash
claude --plugin-dir /path/to/brain-skill
```

**Requirements:** none beyond Claude Code itself. The transcript-snapshot hook uses `jq`
if installed and falls back to `python3` otherwise (present on macOS and virtually every
Linux). The hooks are bash scripts, so this is a macOS/Linux plugin; on Windows it is
untested and would need WSL or Git Bash.

**If you previously hand-installed the v1/v2 "brain kit"** (files copied into
`~/.claude/commands/brain/` and `~/.claude/hooks/`), remove those and their two hook
entries in `~/.claude/settings.json` before installing the plugin, or the commands will
appear twice and the hooks will fire twice.

## Recommended one-time setup

Two things a plugin can't do for you.

Keep brain files out of every repo by default:

```bash
git config --global core.excludesFile ~/.gitignore_global
echo '.claude/brain/' >> ~/.gitignore_global
```

Add this to `~/.claude/CLAUDE.md` so saving doesn't depend on your memory:

```markdown
## Working memory

Feature state lives in `.claude/brain/<slug>.md` in the project root. Run `/brain:save`
after landing a decision, after a failed approach is ruled out, and before any large
refactor, not only when asked. If context is running low, save before continuing.
```

## Use

| Command | When |
|---|---|
| `/brain:save <slug>` | after a decision lands, after an approach is ruled out, before `/clear` or any large refactor |
| `/brain:load <slug>` | first thing in a fresh session |

Omit the slug and it derives one from the branch name (`feat/rto-reduction` →
`rto-reduction`).

## Committing brain files

They're globally gitignored by the setup above, which is the right call for most repos.
On a project where the decisions table would help PR review, negate it in that repo's own
`.gitignore`:

```
!.claude/brain/
.claude/brain/.transcripts/
```

Delete the brain file when the branch merges. Anything still load-bearing should have
graduated into `SPEC.md`, `CLAUDE.md`, or a commit message by then.

## Uninstall

```
/plugin uninstall brain
```

Brain files and transcript snapshots in your repos are plain files; delete
`.claude/brain/` per repo if you want them gone too.
