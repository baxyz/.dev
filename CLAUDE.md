# Claude Code — baxyz workspace

Full canonical rules (commit format, restrictions, license) live in
[AGENTS.md](AGENTS.md). This file adds Claude Code-specific context.

## Workspace layout

All repos are bind-mounted at `/workspaces/<name>` and open together in
`baxyz.code-workspace`:

| Path | Repo | Role |
| ---- | ---- | ---- |
| `/workspaces/.dev` | `.dev` | Orchestration — canonical AGENTS.md, devcontainer, scripts |
| `/workspaces/.github` | `.github` | Workspace-wide GitHub config |
| `/workspaces/baxyz.github.io` | `baxyz.github.io` | GitHub Pages site |
| `/workspaces/gnome-extensions` | `gnome-extensions` | Monorepo for GNOME Shell extensions |
| `/workspaces/repo-proxy` | `repo-proxy` | APT/DEB repository proxy (Cloudflare Workers) |
| `/workspaces/mozlz4` | `mozlz4` | mozLz40 encode/decode library |
| `/workspaces/sqlite-reader` | `sqlite-reader` | Read-only SQLite3 binary parser |

## Cross-repo commands (run from `/workspaces/.dev`)

```bash
pnpm run status:all   # git status -sb in every repo
pnpm run fetch:all    # git fetch --all --prune in every repo
pnpm run pull:all     # git pull --rebase --autostash in every repo
pnpm run branch:all   # show active branch in every repo
pnpm run build:all    # pnpm build in every repo
pnpm run test:all     # pnpm test in every repo
pnpm run lint:all     # pnpm lint in every repo
pnpm run install:all  # pnpm install in every repo
```

## Common gotchas

**Commit scopes**: always read `scopes.json` at the active repo root before choosing a scope.
Never invent a scope that isn't listed. Full type→emoji mapping: `/workspaces/.dev/commit-convention.json`.
Use `/commit` (Claude Code slash command) to auto-generate a message from staged changes.

**License header**: most repos are LGPL-3.0-or-later, but `.dev` itself and some siblings are
MIT — check the target repo's own `LICENSE`/`AGENTS.md` before assuming LGPL. See AGENTS.md's
Inheritance section for the mixed-license context.

**Adding a sibling repo**: update `repos.json`, `baxyz.code-workspace`, and
`.devcontainer/devcontainer.json` (mounts + `BAXYZ_REPOS`) together — these three must stay in
sync or `setup-container.sh`'s clone-fallback and the devcontainer mounts will disagree.

## AI persistence

`~/.claude` is bind-mounted from the host and symlinked at every container start by
`claude-dev`. Memory, credentials, and settings survive all rebuilds.
