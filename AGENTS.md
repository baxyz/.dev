# AGENTS.md — baxyz workspace (canonical)

This is the **canonical, workspace-wide** agent guidance for baxyz personal projects.
Per-repo `AGENTS.md` files only add project-specific details on top of what is defined here.

## ⛔ CRITICAL RESTRICTIONS

- **NEVER execute `git push`** — The user pushes manually after review.
- **NEVER execute `git commit` or `git add`** — The user stages and commits manually. Fix files, then stop.
- **NEVER use GPT models** — Use Claude models only (claude-sonnet-4.x, Claude Opus 4.x+).
- **Everything in English** — Code, comments, commits, documentation, logs, PR descriptions.

## Workspace Context

**baxyz** is the personal GitHub account of Bérenger Arnaud. Personal website: <https://berenger.arnaud.work/>

Repositories in this workspace:

| Repo | Purpose |
| --- | --- |
| [`.dev`](https://github.com/baxyz/.dev) | Orchestration workspace + unified DevContainer + canonical agent rules |
| [`.github`](https://github.com/baxyz/.github) | Workspace-wide GitHub config (community files, templates) |
| [`baxyz.github.io`](https://github.com/baxyz/baxyz.github.io) | GitHub Pages site |
| [`gnome-extensions`](https://github.com/baxyz/gnome-extensions) | Monorepo for GNOME Shell extensions |
| [`repo-proxy`](https://github.com/baxyz/repo-proxy) | Multi-source APT/DEB repository proxy (Cloudflare Workers) |
| [`mozlz4`](https://github.com/baxyz/mozlz4) | Encode/decode Mozilla's mozLz40 (Firefox/Zen Browser) format |
| [`sqlite-reader`](https://github.com/baxyz/sqlite-reader) | Read-only SQLite3 binary parser |

## Inheritance

This is baxyz's own canonical `AGENTS.md` — there is no parent org above it. The
file/tooling *shape* below (`CLAUDE.md`, `scopes.json`, `commit-convention.json`,
`.claude/commands/commit.md`) is ported from
[helpers4/.dev](https://github.com/helpers4/.dev)'s canonical setup. Deltas from that
shape:
- **License: MIT** (not LGPL-3.0-or-later) for `.dev` itself and most siblings; `gnome-extensions`,
  `repo-proxy`, `mozlz4`, `sqlite-reader` carry their own per-repo license — the `auto-header`
  feature's single global `license` setting is only an approximation across this mixed set,
  not something this repo attempts to reconcile.
- Personal single-maintainer account, no `governance`/`CI-CD`-style scopes — scopes stay close
  to helpers4's naming (`devcontainer`, `workspace`, `scripts`, `agents`, `ci`, `docs`, `deps`).

## Commit Messages

All repos follow [Conventional Commits](https://www.conventionalcommits.org/) with a **gitmoji** between the scope and the description.

**Format:** `<type>(<scope>): <emoji> <description>`

**Rules:**
- Description ≤72 chars, lowercase, imperative mood, no trailing period
- Always include exactly ONE emoji
- Multiple logical changes → bullet list in body

**Type / emoji table:**

| Type | Primary | When to use |
| --- | --- | --- |
| feat | ✨ | New feature |
| fix | 🐛 | Bug fix |
| docs | 📝 | Documentation |
| refactor | ♻️ | Code refactoring |
| test | ✅ | Tests |
| chore | 🔧 | Maintenance |
| perf | ⚡️ | Performance |
| style | 💄 | Code style / UI |
| ci | 👷 | CI/CD |
| build | 📦️ | Build system / deps |
| revert | ⏪️ | Revert |

This is the primary-emoji quick reference; `commit-convention.json` is the canonical
machine-readable source and also lists alternative emoji per type (e.g. 🔒️ for a security fix).

## Code Comments

- Default to **no comment**. Add one only when the code alone can't carry the reason — a non-obvious constraint, a workaround for a specific real-world quirk, a precedence choice between two valid behaviors.
- Not every function needs a "why" comment. A codebase where most functions have one reads as uniform/AI-generated to a reviewer, even when each comment is individually justified — that pattern itself is a signal worth avoiding, not just the comments' content.
- Never narrate the fix's own history ("used to be broken", "now fixed", "this used to do X"). Comments describe current behavior/rationale only — the commit message and PR description are where history belongs.
- When several sibling functions share the same kind of tricky reasoning, prefer one comment at the shared call site or the least-obvious function over repeating a comment (even reworded) on each one.

## This Repository (.dev)

**Purpose:** Orchestrate the baxyz workspace — multi-root VS Code workspace, unified DevContainer, canonical agent rules, shared VS Code settings.

### Project Structure

```
.dev/
├── .devcontainer/
│   ├── devcontainer.json       # Cross-repo dev environment
│   └── setup-container.sh      # postCreateCommand: clone-fallback + install
├── .vscode/
│   └── settings.json           # Repo-specific overrides (scopes)
├── scripts/
│   ├── repos.mjs               # Source of truth (reads repos.json)
│   ├── run-each.mjs            # Run a pnpm script in every sibling repo
│   └── git-each.mjs            # Run a git command in every sibling repo
├── baxyz.code-workspace        # Multi-root workspace + shared settings
├── repos.json                  # List of sibling repos
├── package.json                # Cross-repo orchestration scripts
├── AGENTS.md                   # This file (canonical workspace-wide rules)
├── README.md
└── LICENSE                     # MIT
```

Sibling repos live **next to** this folder on the host. The devcontainer bind-mounts each of them at `/workspaces/<name>`.

### What NOT to do here

- Do **not** add runtime code, packages, or build outputs. This repo is configuration only.
- Do **not** duplicate per-repo agent rules — they live in their own `AGENTS.md`.
- When adding a new sibling repo, update `repos.json`, `baxyz.code-workspace`, and `.devcontainer/devcontainer.json` together.
