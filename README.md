# baxyz `.dev`

Dev workspace orchestrator for the baxyz personal GitHub account.

## What's in here

| File / folder | Purpose |
| --- | --- |
| `.devcontainer/` | Unified DevContainer (named volumes for all sibling repos) |
| `.vscode/settings.json` | Shared editor settings |
| `baxyz.code-workspace` | Multi-root VS Code workspace |
| `AGENTS.md` | Canonical AI / agent rules for all baxyz repos |

## Quick start

```bash
mkdir baxyz && cd baxyz
gh repo clone baxyz/.dev
gh repo clone baxyz/.github
gh repo clone baxyz/baxyz.github.io
gh repo clone baxyz/gnome-extensions
gh repo clone baxyz/mozlz4
gh repo clone baxyz/sqlite-reader
code .dev/baxyz.code-workspace
```

Or open `.dev` in VS Code and **Reopen in Container** — every sibling repo is cloned into its own
named volume automatically on first run (works the same way on GitHub Codespaces, no host
pre-clone needed).

## Host setup

Export a GitHub token scoped to baxyz before opening the devcontainer:

```bash
export GH_TOKEN_FOR_BAXYZ=<your-token>
```
