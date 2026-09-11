# Claude Code — baxyz workspace

Full canonical rules (commit format, restrictions, license) live in
[AGENTS.md](AGENTS.md). This file adds Claude Code-specific context.

## Workspace layout

Every repo is cloned into its own named Docker volume at `/workspaces/<name>` by
`setup-container.sh` on first run, and they open together in `baxyz.code-workspace`:

| Path | Repo | Role |
| ---- | ---- | ---- |
| `/workspaces/.dev` | `.dev` | Orchestration — canonical AGENTS.md, devcontainer |
| `/workspaces/.github` | `.github` | Workspace-wide GitHub config |
| `/workspaces/baxyz.github.io` | `baxyz.github.io` | GitHub Pages site |
| `/workspaces/gnome-extensions` | `gnome-extensions` | Monorepo for GNOME Shell extensions |
| `/workspaces/mozlz4` | `mozlz4` | mozLz40 encode/decode library |
| `/workspaces/sqlite-reader` | `sqlite-reader` | Read-only SQLite3 binary parser |

There's no cross-repo script runner anymore — run `git`/`pnpm` commands directly in each repo, or
loop over `$BAXYZ_REPOS` (set in `containerEnv`) from a shell one-liner if needed across all of them.

## Common gotchas

**Commit scopes**: always read `scopes.json` at the active repo root before choosing a scope.
Never invent a scope that isn't listed. Full type→emoji mapping: `/workspaces/.dev/commit-convention.json`.
Use `/commit` (Claude Code slash command) to auto-generate a message from staged changes.

**License header**: default is AGPL-3.0-only, but `mozlz4` and `sqlite-reader` are the deliberate
LGPL-3.0-or-later exceptions — check the target repo's own `LICENSE`/`AGENTS.md` before assuming
either. See AGENTS.md's Inheritance section for the license policy.

**Adding a sibling repo**: update `baxyz.code-workspace`, `.devcontainer/devcontainer.json`
(`mounts` + `BAXYZ_REPOS`), and `.distrobox/distrobox.ini` together — these three must stay in
sync or `setup-container.sh`'s clone-if-empty loop and the devcontainer/distrobox mounts will
disagree.

## AI persistence

`~/.claude` is bind-mounted from a **per-devcontainer** volume and symlinked at
every container start by `claude-dev` — isolated to this project, not shared
with any other org's devcontainer. Memory, credentials, and settings survive
rebuilds of this same devcontainer.
