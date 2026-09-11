# Renaming `.dev` → `baxyz/baxyz`

Runbook for renaming this repo from `baxyz/.dev` to `baxyz/baxyz`, so the host
folder, the GitHub repo, and every Claude Code / editor session reference
"baxyz" instead of ".dev". Not executed yet — do this in a dedicated session
with every devcontainer/Codespace on this repo closed first, since the host
folder rename breaks any running bind mount.

## Order of operations

1. **Close every session** using this repo (VS Code windows, devcontainers,
   Codespaces, `bin/in-devbox` shells).
2. **Rename on GitHub**: `gh repo rename baxyz --repo baxyz/.dev`. GitHub
   keeps an automatic redirect from `baxyz/.dev` to `baxyz/baxyz` (breaks
   only if someone later creates a new repo at the old name).
3. **Rename the host folder**: from the parent of all sibling repos,
   `mv .dev baxyz`. Update `origin`'s remote URL for clarity even though the
   redirect makes it optional: `git -C baxyz remote set-url origin git@github.com:baxyz/baxyz.git`.
4. **Update in-repo references** (this repo, now at `baxyz/`):
   - `.devcontainer/devcontainer.json`: `workspaceFolder` and
     `workspaceMount` target `/workspaces/.dev` → `/workspaces/baxyz`.
   - `baxyz.code-workspace`: the `{"name": ".dev", "path": "."}` folder entry
     → `{"name": "baxyz", "path": "."}`.
   - `AGENTS.md`: workspace table row and the `github.com/baxyz/.dev` link.
   - `CLAUDE.md`: workspace layout table row (`/workspaces/.dev`).
   - `README.md`: quick-start clone command and `code .dev/baxyz.code-workspace`.
   - `.distrobox/distrobox.ini` and `.distrobox/README.md`: prose mentions of
     `.dev` (the `${PWD}`-relative mounts themselves need no change).
5. **Commit and push** from the renamed repo.
6. **Update cross-repo references** in separate PRs — a grep across the
   mounted siblings found `baxyz/.dev` mentioned in `.github/CONTRIBUTING.md`,
   `.github/AGENTS.md`, and `baxyz.github.io/projects.md`; re-check at rename
   time in case new references were added, and check `.github`'s reusable
   workflows too if any reference the repo by name.
7. **Re-open**: point VS Code / Codespaces at the new `baxyz` folder/repo.

## Not required but worth deciding

- Whether `baxyz.code-workspace` itself should be renamed (its name already
  matches "baxyz", only the folder entry inside it needs the edit above).
- Whether other `.dev`-named artifacts (e.g. distrobox container name
  `baxyz-devbox` — already fine, unaffected) need touching.
