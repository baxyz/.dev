# Claude Code — baxyz workspace

Full canonical rules (commit format, restrictions, license) live in
[AGENTS.md](AGENTS.md). This file adds Claude Code-specific context.

## Workspace layout

All repos are cloned as siblings at `/workspaces/<name>` by the `org-workspace` devcontainer
feature (not host bind-mounted — that's what makes the devcontainer work on GitHub Codespaces as
well as local Docker Desktop/WSL2), and open together in `baxyz.code-workspace`. The clones live in
a named Docker volume, so a plain "Rebuild Container" keeps uncommitted/unpushed work; only a full
teardown (`docker volume rm`, deleted Codespace) resets them to a fresh clone of `origin/main`.
`.dev` itself is the one repo that's genuinely host bind-mounted, so it's unaffected either way.
**This is a safety net, not a substitute for pushing** — commit and push before anything that
could destroy the underlying Docker volumes.

| Path | Repo | Role |
| ---- | ---- | ---- |
| `/workspaces/.dev` | `.dev` | Orchestration workspace + unified DevContainer + canonical agent rules |
| `/workspaces/.github` | `.github` | Workspace-wide GitHub config (community files, templates) |
| `/workspaces/baxyz.github.io` | `baxyz.github.io` | GitHub Pages site |
| `/workspaces/gnome-extensions` | `gnome-extensions` | Monorepo for GNOME Shell extensions |
| `/workspaces/mozlz4` | `mozlz4` | Encode/decode Mozilla's mozLz40 (Firefox/Zen Browser) format |
| `/workspaces/sqlite-reader` | `sqlite-reader` | Read-only SQLite3 binary parser |

## Common gotchas

**Commit scopes**: always read `scopes.json` at the active repo root before choosing a scope.
Never invent a scope that isn't listed. Full type→emoji mapping: `/workspaces/.dev/commit-convention.json`.
Use `/commit` (Claude Code slash command) to auto-generate a message from staged changes.

**License header**: default is AGPL-3.0-only, but `mozlz4` and `sqlite-reader` are the deliberate
LGPL-3.0-or-later exceptions — check the target repo's own `LICENSE`/`AGENTS.md` before assuming
either. See AGENTS.md's Inheritance section for the license policy.

**Adding a sibling repo**: nothing to do for the devcontainer (`org-workspace` discovers the
org repos and updates `baxyz.code-workspace`); only `.distrobox/distrobox.ini` has a hardcoded
repo list (`volume=`) to update by hand.

**Git workflow**: branch, commit by subject (Conventional Commits), push only once it looks safe
(human review of the diff recommended first, ask if unsure), open a PR — never merge, merging is
always a human decision. See AGENTS.md's Git Workflow section for the full policy and how a narrow
per-task carve-out (e.g. "push straight to `main` for this one fix") can be granted.

## AI persistence

`~/.claude` is bind-mounted from a **per-devcontainer** volume and symlinked at
every container start by `claude-dev` — isolated to this project, not shared
with any other org's devcontainer. Memory, credentials, and settings survive
rebuilds of this same devcontainer. Remote Control (`claude-rc status`) lets you start sessions
in this devcontainer from claude.ai/code or the Claude mobile app.
