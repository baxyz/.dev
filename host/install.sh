#!/usr/bin/env bash
# Install the fajro host setup for the current user. Idempotent: re-run it to update.
#
#   - devcontainer CLI in ~/.local (used by `devc`)
#   - devc, claude-host in ~/.local/bin
#   - claude-host.service as a systemd *user* service, started at boot (lingering enabled)
#   - ~/projects/CLAUDE.md: instructions for the host Claude session (never overwritten)
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN="$HOME/.local/bin"
UNITS="$HOME/.config/systemd/user"
PROJECTS="${DEVC_PROJECTS:-$HOME/projects}"

mkdir -p "$BIN" "$UNITS" "$HOME/.config/fajro"

for dep in docker tmux node npm claude; do
  command -v "$dep" >/dev/null 2>&1 || { echo "missing dependency: $dep" >&2; exit 1; }
done

if ! command -v devcontainer >/dev/null 2>&1; then
  echo "→ installing @devcontainers/cli into ~/.local"
  npm install -g --prefix "$HOME/.local" @devcontainers/cli >/dev/null
fi

install -m 0755 "$HERE/devc" "$BIN/devc"
install -m 0755 "$HERE/claude-host" "$BIN/claude-host"
install -m 0644 "$HERE/claude-host.service" "$UNITS/claude-host.service"
echo "✓ installed devc, claude-host, claude-host.service"

if [ ! -e "$PROJECTS/CLAUDE.md" ]; then
  install -m 0644 "$HERE/ORCHESTRATOR.md" "$PROJECTS/CLAUDE.md"
  echo "✓ wrote $PROJECTS/CLAUDE.md"
else
  echo "· $PROJECTS/CLAUDE.md already exists (compare with host/ORCHESTRATOR.md)"
fi

# Keep user services (and the tmux session) alive without an open login, and start them at boot.
if [ "$(loginctl show-user "$USER" -p Linger --value 2>/dev/null)" != yes ]; then
  echo "→ enabling lingering for $USER (sudo)"
  sudo loginctl enable-linger "$USER"
fi

systemctl --user daemon-reload
systemctl --user enable --now claude-host.service
echo "✓ claude-host.service enabled and started"
echo
echo "Next: open https://claude.ai/code and pick the '$(hostname -s)' environment."
echo "      Start an org devcontainer with: devc up <org>   (see: devc help)"
