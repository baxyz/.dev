# AGENTS.md — baxyz workspace (canonical)

This is the **canonical, workspace-wide** agent guidance for baxyz personal projects.
Per-repo `AGENTS.md` files only add project-specific details on top of what is defined here.

## Language

**Everything in English** — code, comments, commits, documentation, logs, PR descriptions.

## Git Workflow

Default policy — nuanced, not a hard rule: ask if a specific task calls for
something different, but absent other instructions:

1. **Branch** — work on a branch, never directly on `main`. Group related
   changes on the same branch instead of opening a new one per small change.
2. **Commit** — one commit per subject, Conventional Commits format mandatory
   (see Commit Messages below).
3. **Push** — only once it looks safe to do so; a human review of the diff
   first is recommended for anything non-trivial. Ask if unsure.
4. **Pull Request** — open one once pushed.
5. **Merge** — never merge. Merging is always a human decision.

A narrow, temporary carve-out (e.g. "push straight to `main` for this one fix")
may be granted in conversation for a specific piece of work — treat it as
scoped to exactly what was said, never as a standing precedent to reuse
elsewhere or later without asking again.

## Workspace Context

**baxyz** is the personal GitHub account of Bérenger Arnaud. Personal website: <https://berenger.arnaud.work/>

Repositories in this workspace:

| Repo | Purpose |
| --- | --- |
| [`.dev`](https://github.com/baxyz/.dev) | Orchestration workspace + unified DevContainer + canonical agent rules |
| [`.github`](https://github.com/baxyz/.github) | Workspace-wide GitHub config (community files, templates) |
| [`baxyz.github.io`](https://github.com/baxyz/baxyz.github.io) | GitHub Pages site |
| [`gnome-extensions`](https://github.com/baxyz/gnome-extensions) | Monorepo for GNOME Shell extensions |
| [`mozlz4`](https://github.com/baxyz/mozlz4) | Encode/decode Mozilla's mozLz40 (Firefox/Zen Browser) format |
| [`sqlite-reader`](https://github.com/baxyz/sqlite-reader) | Read-only SQLite3 binary parser |

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
- Sibling-repo orchestration is the thin `devcontainer`-only pattern (named volumes +
  `setup-container.sh`'s clone-if-empty loop, sourced from `BAXYZ_REPOS`) — no
  `repos.json`/`scripts/`/`package.json` layer anymore, matching `brig-id/roots` and
  `tuxery/.dev`. No `scripts` scope as a result.
- Every repo keeps a root-level `scopes.json` — the machine-readable scope list `/commit` and
  `commit-convention.json` read. A repo's `.vscode/settings.json` may mirror the same list for
  the editor's own Conventional Commits extension UI, but `scopes.json` is the source of truth.

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
│   ├── devcontainer.json       # Cross-repo dev environment (named volumes)
│   └── setup-container.sh      # postCreateCommand: clone-into-volume-if-empty
├── .vscode/
│   └── settings.json           # Repo-specific overrides (scopes)
├── .distrobox/                 # Alternative to the devcontainer (host bind-mounts)
├── baxyz.code-workspace        # Multi-root workspace + shared settings
├── AGENTS.md                   # This file (canonical workspace-wide rules)
├── README.md
└── LICENSE                     # MIT
```

Sibling repos live **next to** this folder on the host, but the devcontainer no longer bind-mounts
them — each is cloned into its own named Docker volume by `setup-container.sh` on first run, so
the container works identically on GitHub Codespaces and locally. `BAXYZ_REPOS` in
`devcontainer.json`'s `containerEnv` is the source of truth for the sibling repo list.

### What NOT to do here

- Do **not** add runtime code, packages, or build outputs. This repo is configuration only.
- Do **not** duplicate per-repo agent rules — they live in their own `AGENTS.md`.
- When adding a new sibling repo, update `baxyz.code-workspace` and `.devcontainer/devcontainer.json` (`mounts` + `BAXYZ_REPOS`) together.
