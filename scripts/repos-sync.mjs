#!/usr/bin/env node
/**
 * Compares repos.json against the baxyz GitHub account and reports repos
 * that could be added (active, not a fork/archived) or that may be stale
 * (already in repos.json but archived/renamed/gone). Read-only: repos.json
 * stays the source of truth, edited by hand after reviewing the report.
 * Usage: node scripts/repos-sync.mjs
 */
import { spawnSync } from "node:child_process";
import { readRepos } from "./repos.mjs";

const result = spawnSync(
  "gh",
  ["repo", "list", "baxyz", "--limit", "200", "--json", "name,isFork,isArchived,visibility"],
  { encoding: "utf8" },
);

if (result.status !== 0) {
  console.error(result.stderr || "gh repo list failed");
  process.exit(1);
}

const remote = JSON.parse(result.stdout);
const tracked = new Set(readRepos());

const candidates = remote
  .filter((r) => !r.isFork && !r.isArchived && r.name !== ".dev" && !tracked.has(r.name))
  .map((r) => r.name)
  .sort();

const stale = [...tracked].filter((name) => {
  const repo = remote.find((r) => r.name === name);
  return !repo || repo.isArchived;
});

console.log("━━━ Not in repos.json (active, not a fork) ━━━");
console.log(candidates.length ? candidates.join("\n") : "(none)");

console.log("\n━━━ In repos.json but archived/missing on GitHub ━━━");
console.log(stale.length ? stale.join("\n") : "(none)");

console.log(
  "\nThis is a report only — add/remove entries in repos.json by hand, then keep " +
    "baxyz.code-workspace, .devcontainer/devcontainer.json and .distrobox/distrobox.ini in sync " +
    "(see CLAUDE.md's \"Adding a sibling repo\" gotcha).",
);
