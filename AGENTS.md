# AGENTS.md — baxyz `.dev`

This repository is the **shared workspace** for baxyz personal projects. Every baxyz repository
inherits these rules; per-repo `AGENTS.md` files only add project-specific details.

**baxyz** is the personal GitHub account of Bérenger Arnaud. Personal website: <https://berenger.arnaud.work/>

## Language

**Everything in English** — code, comments, commits, documentation, logs, PR descriptions.

## Code Comments

- Default to **no comment**. Add one only when the code alone can't carry the reason — a non-obvious constraint, a workaround for a specific real-world quirk, a precedence choice between two valid behaviors.
- Not every function needs a "why" comment. A codebase where most functions have one reads as uniform/AI-generated to a reviewer, even when each comment is individually justified — that pattern itself is a signal worth avoiding, not just the comments' content.
- Never narrate the fix's own history ("used to be broken", "now fixed", "this used to do X"). Comments describe current behavior/rationale only — the commit message and PR description are where history belongs.
- When several sibling functions share the same kind of tricky reasoning, prefer one comment at the shared call site or the least-obvious function over repeating a comment (even reworded) on each one.

## Scope

- VS Code multi-root workspace (`baxyz.code-workspace`)
- devcontainer setup (`.devcontainer/`), plus a distrobox alternative (`.distrobox/`)
- shared AI / agent guidance

This repository contains **no product runtime code** — it is configuration and documentation only.

### Project structure

```
.dev/
├── .devcontainer/
│   └── devcontainer.json       # Cross-repo dev environment (org-workspace clones siblings)
├── .vscode/
│   └── settings.json           # Repo-specific overrides (scopes)
├── .distrobox/                 # Alternative to the devcontainer (host bind-mounts)
├── baxyz.code-workspace        # Multi-root workspace + shared settings
├── AGENTS.md                   # This file (canonical workspace-wide rules)
├── README.md
└── LICENSE                     # MIT
```

## Workspace structure

All repositories are cloned as siblings under `/workspaces/` by the `org-workspace` devcontainer
feature (`.devcontainer/devcontainer.json`) — only `.dev` itself is bind-mounted from the host.
This is what makes the devcontainer work identically on a local checkout (Docker Desktop/WSL2)
and on GitHub Codespaces, which only ever checks out the one repo you launch the codespace from.
`baxyz.code-workspace` is kept up to date by the same feature.

| Path | Repo | Purpose |
| --- | --- | --- |
| `/workspaces/.dev` | `baxyz/.dev` | Orchestration workspace + unified DevContainer + canonical agent rules |
| `/workspaces/.github` | `baxyz/.github` | Workspace-wide GitHub config (community files, templates) |
| `/workspaces/baxyz.github.io` | `baxyz/baxyz.github.io` | GitHub Pages site |
| `/workspaces/gnome-extensions` | `baxyz/gnome-extensions` | Monorepo for GNOME Shell extensions |
| `/workspaces/mozlz4` | `baxyz/mozlz4` | Encode/decode Mozilla's mozLz40 (Firefox/Zen Browser) format |
| `/workspaces/sqlite-reader` | `baxyz/sqlite-reader` | Read-only SQLite3 binary parser |

## Devcontainer — available tools

The container is self-contained; no host toolchain installation is needed.

- Node.js 26
- `pnpm` (via `helpers4/devcontainer/pnpm-store` + `typescript-dev`), dependencies installed on container creation (`package-auto-install`)
- `nub` — an accelerator (`nub run`, `nubx`) that delegates to pnpm; it is **not** a package manager replacement
- `vp` (Vite+: Oxlint/Oxfmt, Vitest)
- Rust toolchain (`rustup`, `cargo`)
- Playwright (browsers + VS Code extension)
- `gh` CLI
- `git-absorb`
- Docker CLI (talks to the host Docker daemon)
- Claude Code (CLI + VS Code extension) with Remote Control enabled — `claude-rc status` inside the container
- AI assistants: Copilot, Cline, Mistral Vibe, Graphite
- `org-workspace`: clones the org repos into `/workspaces` and keeps the `.code-workspace` file up to date

## Rules

- Treat this repository as configuration/documentation only — no product runtime code, packages,
  or build outputs.
- Do not duplicate per-repo agent rules — they live in each repo's own `AGENTS.md`.
- Add future repositories as siblings of `.dev/`, not nested inside it. Nothing to update by hand
  for the devcontainer: `org-workspace` discovers the org repos and keeps `baxyz.code-workspace`
  up to date. Only `.distrobox/distrobox.ini` has a hardcoded repo list to update by hand.

## Commit conventions

Format: `type(scope): <emoji> description`
([Conventional Commits](https://www.conventionalcommits.org/) + [gitmoji](https://gitmoji.dev))

- Description ≤72 chars, lowercase, imperative mood, no trailing period
- Exactly ONE emoji, between the colon and the description
- Several logical changes → one dominant type in the subject, a bullet list in the body

| Type | Emoji | Alternatives | When |
| ---- | ----- | ------------ | ---- |
| `feat` | ✨ | 🚸 UX · ♿️ a11y · 🌐 i18n · 💬 text | New feature |
| `fix` | 🐛 | 🚑️ hotfix · 🔒️ security · 🩹 trivial · 🥅 errors · 🚨 warnings · ✏️ typo | Bug fix |
| `docs` | 📝 | 💡 comments · 📄 license | Documentation |
| `refactor` | ♻️ | 🎨 structure · 🔥 remove · ⚰️ dead code · 🚚 move/rename | Refactor |
| `test` | ✅ | 🧪 failing · 💚 fix CI | Tests |
| `chore` | 🔧 | 🙈 gitignore · 🔖 release · 📌 pin deps · 🩺 healthcheck | Maintenance |
| `perf` | ⚡️ | | Performance |
| `style` | 💄 | 🎨 code style | Style |
| `ci` | 👷 | 💚 fix CI | CI/CD |
| `build` | 📦️ | ➕ add · ➖ remove · ⬆️ upgrade · ⬇️ downgrade dep | Build |
| `revert` | ⏪️ | | Revert |

Full type→emoji mapping with alternatives: `commit-convention.json` at this repo's root (also
read by the `/commit` slash command).

### Allowed scopes

Scopes live in `scopes.json` at this repo's root (machine-readable source of truth, also read by
the `/commit` slash command and mirrored in `.vscode/settings.json`):

| Scope | Maps to |
| --- | --- |
| `ai` | Agent guidance (`AGENTS.md`, `CLAUDE.md`, `.claude/`), prompt files |
| `ci` | `.github/workflows/` (if any) |
| `deps` | Dependency bumps |
| `devcontainer` | `.devcontainer/` |
| `docs` | `README.md` and other documentation |
| `workspace` | `baxyz.code-workspace`, root-level config |

**Do not use a scope outside this list.** If a new top-level concern is added, update
`scopes.json` (and this table) and `.vscode/settings.json` together.

```text
docs(docs): 📝 document the local devcontainer quick start
chore(devcontainer): 🔧 enable claude remote control
```

## Git Workflow

Default policy — nuanced, not a hard rule: ask if a specific task calls for
something different, but absent other instructions:

1. **Branch** — work on a branch, never directly on `main`. Create the branch
   (`git checkout -b <name>`) *before* the first commit — never commit while
   on `main` and rename the branch afterward, since that can leave the
   branch's upstream tracking pointed at `origin/main` and let a later push
   land directly on `main` unnoticed. Group related changes on the same
   branch instead of opening a new one per small change.
2. **Commit** — one commit per subject, Conventional Commits format mandatory
   (see Commit conventions above).
3. **Push** — only once it looks safe to do so; a human review of the diff
   first is recommended for anything non-trivial. Ask if unsure.
4. **Pull Request** — open one once pushed.
5. **Merge** — never merge. Merging is always a human decision.

A narrow, temporary carve-out (e.g. "push straight to `main` for this one fix")
may be granted in conversation for a specific piece of work — treat it as
scoped to exactly what was said, never as a standing precedent to reuse
elsewhere or later without asking again.

## Inheritance

This is baxyz's own canonical `AGENTS.md` — there is no parent org above it. The
file/tooling *shape* below (`CLAUDE.md`, `scopes.json`, `commit-convention.json`,
`.claude/commands/commit.md`) is ported from
[helpers4/.dev](https://github.com/helpers4/.dev)'s canonical setup. Deltas from that
shape:
- **Default license is AGPL-3.0-only** — `.dev`, `.github`, `gnome-extensions`, and
  `baxyz.github.io` all use it; `mozlz4` and `sqlite-reader` are the deliberate exceptions, kept
  LGPL-3.0-or-later since they're small libraries meant to be embedded/imported freely. Any new
  repo defaults to AGPL-3.0-only unless there's a specific reason to relax it, as for the two
  libraries above.
- Personal single-maintainer account. Scopes use the consolidated cross-org core set:
  `ai`, `ci`, `deps`, `devcontainer`, `docs`, `workspace` — `ai` replaces the
  earlier `agents` name (consolidated with `roots`/tuxery's `ai` and helpers4's `governance`,
  which all designated the same thing: AI/agent guidance changes).
- Sibling-repo orchestration is the thin `devcontainer`-only pattern (`org-workspace` feature
  cloning into named volumes) — no
  `repos.json`/`scripts/`/`package.json` layer anymore, matching `brig-id/roots` and
  `tuxery/.dev`. No `scripts` scope as a result.
- Every repo keeps a root-level `scopes.json` — the machine-readable scope list `/commit` and
  `commit-convention.json` read. A repo's `.vscode/settings.json` may mirror the same list for
  the editor's own Conventional Commits extension UI, but `scopes.json` is the source of truth.
