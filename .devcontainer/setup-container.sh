#!/usr/bin/env bash
# This file is part of baxyz/.dev.
# SPDX-License-Identifier: MIT
#
# baxyz orchestrator — devcontainer setup
# -----------------------------------------------------------------------------
# For every sibling repo declared in $BAXYZ_REPOS, ensure it exists at
# /workspaces/<repo>. If the bind-mount target is empty (Codespaces or
# fresh machine), fall back to `git clone`.
# pnpm install is handled by the package-auto-install feature (autoDiscover).
# -----------------------------------------------------------------------------
set -euo pipefail

echo "🎼 Setting up baxyz orchestrator…"

REPOS="${BAXYZ_REPOS:-.github baxyz.github.io gnome-extensions repo-proxy mozlz4 sqlite-reader}"
ORG_URL="https://github.com/baxyz"

for repo in $REPOS; do
  target="/workspaces/${repo}"
  if [ -d "${target}/.git" ] || [ -f "${target}/package.json" ] || [ -n "$(ls -A "${target}" 2>/dev/null || true)" ]; then
    echo "✅ ${repo}: already present (bind-mounted)"
    continue
  fi

  url="${ORG_URL}/${repo}.git"
  echo "📥 ${repo}: missing — cloning from ${url}"
  rm -rf "${target}" 2>/dev/null || true
  git clone "${url}" "${target}" || echo "⚠️  ${repo}: clone failed (continuing)"
done

echo "🎉 baxyz orchestrator ready."
echo "   Open baxyz.code-workspace to load every repo at once."
echo "   Try: pnpm run status:all | pull:all | branch:all"
