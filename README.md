# baxyz `.dev`

Dev workspace orchestrator for the baxyz personal GitHub account.

## What's in here

| File / folder | Purpose |
| --- | --- |
| `.devcontainer/` | Unified DevContainer (mounts all sibling repos) |
| `.vscode/settings.json` | Shared editor settings |
| `scripts/` | Cross-repo helpers (`git-each`, `run-each`) |
| `baxyz.code-workspace` | Multi-root VS Code workspace |
| `repos.json` | Source of truth for sibling repo list |
| `AGENTS.md` | Canonical AI / agent rules for all baxyz repos |

## Quick start

```bash
mkdir baxyz && cd baxyz
gh repo clone baxyz/.dev
gh repo clone baxyz/.github
gh repo clone baxyz/baxyz.github.io
gh repo clone baxyz/.trivial
gh repo clone baxyz/firefox-profiles
gh repo clone baxyz/repo-proxy
gh repo clone baxyz/new-blog
gh repo clone baxyz/zen-mods
code .dev/baxyz.code-workspace
```

Or open `.dev` in VS Code and **Reopen in Container** — missing repos are cloned automatically.

## Cross-repo scripts

```bash
pnpm run status:all   # git status in every repo
pnpm run pull:all     # git pull --rebase in every repo
pnpm run branch:all   # current branch in every repo
pnpm run build:all    # pnpm build in every repo that has it
```

## Host setup

Export a GitHub token scoped to baxyz before opening the devcontainer:

```bash
export GH_TOKEN_FOR_BAXYZ=<your-token>
```
