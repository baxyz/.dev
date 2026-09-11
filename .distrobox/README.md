# distrobox for baxyz/.dev

This lives **alongside** the existing `.devcontainer/` (nothing removed or modified) as an
alternative to it: read-only-by-default identity + an isolated toolchain home, AI agent staying
on the host, node/pnpm/git-lfs running in a separate box.

## Design

- `home=` gives the box its **own isolated HOME** (`~/.distrobox-baxyz-home`), separate from the
  real host `$HOME`. That's deliberate: the whole point of running node/pnpm in a box is that
  `npm install -g <tool>` or pnpm's global store inside the box must not land in the host's real
  npm/pnpm state. Letting distrobox bind-mount the real `$HOME` (its default with no `home=`) would
  merge the two and defeat that.
- `.gitconfig` and `.ssh` are bind-mounted **read-only** from the real host home into the box's
  isolated home, so git author identity, commit signing and SSH-based clone/push work with zero
  setup inside the box.
- The project and every sibling repo (see [Workspace note](#workspace-note)) are bind-mounted
  **read-write** at their real host paths, since they're no longer auto-included now that `home=`
  points elsewhere.

## Workspace note

The `volume=` line mirrors the sibling-repo list from
[`baxyz.code-workspace`](../baxyz.code-workspace). Per `CLAUDE.md`'s "Adding a sibling repo"
gotcha: if you add/remove a repo, update `baxyz.code-workspace`, `.devcontainer/devcontainer.json`
**and** `.distrobox/distrobox.ini` together, or the mounts will drift out of sync.

## Create the box

```bash
distrobox assemble create --file .distrobox/distrobox.ini
```

## Verification checklist

Isolated home / read-only identity — from inside the box (`distrobox enter baxyz-devbox`):

```bash
echo "$HOME"                      # ~/.distrobox-baxyz-home, not the real host $HOME
echo x >> ~/.gitconfig            # must fail: Permission denied
touch ~/.ssh/should-fail          # must fail: Read-only file system
git config --get user.email       # must still resolve (baxyz git identity, read through the ro mount)
```

Toolchain:

```bash
node -v
pnpm -v
git lfs version
git config --get filter.lfs.clean # already registered if the host has git-lfs configured — no
                                   # `git lfs install` hook is needed inside the box for that
```

AI agent bridge (host) → box, from `.dev/` (or any mounted repo):

```bash
bin/in-devbox pwd                  # prints the real host path, not /run/host/<path>
bin/in-devbox git status -sb
```

## Known limitation: `/run/host` is not a security boundary

By default distrobox bind-mounts the **entire host filesystem, read-write**, at `/run/host` inside
every box (this is standard distrobox behavior — `--volume /:/run/host/:rslave`, no `ro`, not
something `.ini` options can change). That means the read-only `.gitconfig`/`.ssh` mounts above,
and the isolated `home=`, are convenience/default-path protections, not a hard sandbox: a process
inside the box can always reach out via `/run/host/home/<user>/...` and read or write anything the
host user can, bypassing every mount mode set in this file.

In practice this doesn't undermine the actual goal (keeping ordinary `npm install -g`/pnpm state
out of the host's real npm/pnpm state): normal tool invocations resolve paths through `$HOME` /
`XDG_*` env vars, not by crawling `/run/host`. But distrobox itself is explicit that it's built for
toolchain/environment integration, not for running untrusted or actively adversarial code — don't
rely on this box as an isolation boundary against code you don't trust.

`distrobox enter` (and `bin/in-devbox`, before its fix) also defaults to landing in
`/run/host/<host-path>` rather than this file's own dedicated mount of that same path — same
underlying read-write content, just a cosmetic path difference. `bin/in-devbox` works around it by
explicitly `cd`-ing into the real path before running the requested command.

## VS Code

The code lives on the host filesystem (no container-only mount), so `code baxyz.code-workspace`
opened normally already shows and edits it — no "Reopen in Container" step needed.

To actually see/verify the code **from inside** the box the way a devcontainer would — a VS Code
window with its terminal and extensions running inside `baxyz-devbox` — use the
[Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)'s
attach mode, no `devcontainer.json` required:

1. Make sure the box exists and is running: `distrobox assemble create --file .distrobox/distrobox.ini`
   (or just `distrobox enter baxyz-devbox` once — `start_now=false` means it isn't started
   automatically).
2. Command Palette → **Dev Containers: Attach to Running Container...** → `baxyz-devbox`
3. A new VS Code window opens with its integrated terminal and extension host running inside the
   container; the bind-mounted repos are browsable at the same paths as on the host.

To customize that attached window (extensions, settings) the way `devcontainer.json` does for a
build — current `.devcontainer/devcontainer.json` doesn't define any `customizations.vscode.*`
today, so there's nothing to port, but if that changes later:

- Command Palette → **Dev Containers: Open Attached Container Configuration File** → select
  `baxyz-devbox`
- This creates a small `devcontainer.json`-like file (`name`, `extensions`, `settings`,
  `remoteUser`, `workspaceFolder`) stored on the host and re-applied automatically on every future
  attach to that named container.

## What goes away compared to the current devcontainer.json

These `helpers4/devcontainer/*` features become unnecessary or take a different shape under this
model (isolated box home, agent on the host):

- `dotfiles-sync`: replaced by the explicit `.gitconfig`/`.ssh` read-only mounts above.
- `shell-history-per-project`: optional, recreate via `HISTFILE` if wanted.
- `claude-dev` / `copilot-dev` / `mistral-dev`: no need to install the AI CLIs *inside* the box,
  since the agent runs on the host and only enters the box for node/pnpm/git commands.
- `pnpm-store`: no dedicated volume needed, the pnpm store lives under the box's own isolated
  `home=`, which already persists natively across container restarts.
- `auto-header`, `peon-ping`: these are repo scripts/tools, not environment needs — keep them as
  normal `pnpm` scripts, independent of the box.
- `package-auto-install`: replace with an explicit `bin/in-devbox pnpm install` in each sibling
  repo after creation — there's no cross-repo install-everything script anymore.

What needs to be explicitly ported (see the "Optional" section of the `.ini`): `github-dev` (gh
cli), `playwright-dev` (browsers), `docker-outside-of-docker` (docker socket) — only if actually
used.

## History

The first draft of this file mounted the real host `$HOME` read-only and tried layering read-write
mounts on top of it. That failed outright: distrobox always bind-mounts the real `$HOME`
read-write by default, and podman rejects two `--volume` flags targeting the same destination —
there's no flag to change the mode of that automatic mount. It was also the wrong goal in the
first place, since pnpm writes to its global store on every install, not just at box setup — a
read-only real home would have broken routine `pnpm install`, not just the one-time init hooks.
The current design (isolated `home=` + targeted read-only identity mounts) avoids both problems.
