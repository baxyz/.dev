#!/usr/bin/env bash
# This file is part of baxyz/.dev.
# SPDX-License-Identifier: MIT
#
# baxyz orchestrator — devcontainer setup
# -----------------------------------------------------------------------------
# pnpm install is handled by the package-auto-install feature (autoDiscover).
# -----------------------------------------------------------------------------
set -euo pipefail

echo "🎼 Setting up baxyz orchestrator…"

REPOS="${BAXYZ_REPOS:-.github baxyz.github.io gnome-extensions repo-proxy mozlz4 sqlite-reader}"
ORG_URL="https://github.com/baxyz"

for repo in $REPOS; do
  target="/workspaces/${repo}"
  if [ -n "$(ls -A "${target}" 2>/dev/null || true)" ]; then
    echo "✅ ${repo}: already present (bind-mounted)"
    continue
  fi

  url="${ORG_URL}/${repo}.git"
  echo "📥 ${repo}: missing — cloning from ${url}"
  git clone "${url}" "${target}" || echo "⚠️  ${repo}: clone failed (continuing)"
done

echo "🎉 baxyz orchestrator ready."
echo "   Open baxyz.code-workspace to load every repo at once."
echo "   Try: pnpm run status:all | pull:all | branch:all"
