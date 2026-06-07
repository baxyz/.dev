#!/usr/bin/env bash
# baxyz orchestrator — devcontainer setup
#
# 1. For every sibling repo declared in $BAXYZ_REPOS, ensure it exists at
#    /workspaces/<repo>. Falls back to `gh repo clone` if the bind-mount is
#    empty (Codespaces or fresh machine).
# 2. Run `pnpm install` on each sibling that has a package.json (best effort).
set -euo pipefail

echo "✨ Setting up baxyz workspace…"

ORG="${BAXYZ_ORG:-baxyz}"
REPOS="${BAXYZ_REPOS:-.github baxyz.github.io .trivial firefox-profiles repo-proxy new-blog zen-mods}"

for repo in $REPOS; do
  target="/workspaces/${repo}"
  if [ -d "${target}/.git" ] || [ -f "${target}/package.json" ] || [ -n "$(ls -A "${target}" 2>/dev/null || true)" ]; then
    echo "✓ ${repo}: already present"
    continue
  fi

  echo "→ ${repo}: cloning missing sibling repository"
  rm -rf "${target}" 2>/dev/null || true
  if command -v gh >/dev/null 2>&1; then
    gh repo clone "${ORG}/${repo}" "${target}" || echo "⚠️  ${repo}: clone failed (continuing)"
  else
    git clone "https://github.com/${ORG}/${repo}.git" "${target}" || echo "⚠️  ${repo}: clone failed (continuing)"
  fi
done

if command -v pnpm >/dev/null 2>&1; then
  PNPM_STORE_VOL="/.pnpm-store"
  if [ -d "$PNPM_STORE_VOL" ]; then
    sudo chown -R node:node "$PNPM_STORE_VOL" 2>/dev/null || true
  fi
  PNPM_RC="${HOME}/.npmrc"
  if ! grep -q "^store-dir" "$PNPM_RC" 2>/dev/null; then
    printf 'store-dir=%s\n' "$PNPM_STORE_VOL" >> "$PNPM_RC"
  fi

  for repo in $REPOS; do
    target="/workspaces/${repo}"
    if [ -f "${target}/package.json" ]; then
      echo "📦 pnpm install — ${repo}"
      (cd "${target}" && pnpm install --prefer-offline) \
        || echo "⚠️  pnpm install failed in ${repo} (continuing)"
    fi
  done
fi

echo ""
echo "🎉 baxyz workspace ready."
echo "   Open baxyz.code-workspace to load every repo at once."
echo "   Try: pnpm run status:all | pull:all | branch:all"
