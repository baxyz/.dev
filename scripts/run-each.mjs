#!/usr/bin/env node
/**
 * Run a pnpm script in every sibling baxyz repo that exposes it.
 * Usage: node scripts/run-each.mjs <script-name>
 */
import { existsSync, readFileSync } from "node:fs";
import { spawnSync } from "node:child_process";
import { resolve } from "node:path";
import { readRepos, readRoot } from "./repos.mjs";

const root = readRoot();
const repos = readRepos();
const script = process.argv[2];

if (!script) {
  console.error("Usage: node scripts/run-each.mjs <script-name>");
  process.exit(2);
}

const results = [];

for (const repo of repos) {
  const cwd = resolve(root, "..", repo);
  const packagePath = resolve(cwd, "package.json");

  if (!existsSync(packagePath)) {
    console.warn(`⚠️  ${repo}: no package.json (skipped)`);
    continue;
  }

  if (script !== "install") {
    const pkg = JSON.parse(readFileSync(packagePath, "utf8"));
    if (!pkg.scripts || !pkg.scripts[script]) {
      console.warn(`⚠️  ${repo}: no "${script}" script (skipped)`);
      continue;
    }
  }

  const args = script === "install" ? ["install"] : ["run", script];
  console.log(`\n━━━ ${repo} — pnpm ${args.join(" ")} ━━━`);

  const result = spawnSync("pnpm", args, { cwd, stdio: "inherit" });
  results.push({ repo, code: result.status ?? -1 });
}

const failed = results.filter((r) => r.code !== 0);

if (results.length > 0) {
  console.log("\n━━━ Summary ━━━");
  for (const r of results) {
    console.log(`  ${r.code === 0 ? "✓" : "✗"} ${r.repo} (${r.code})`);
  }
}

process.exit(failed.length ? 1 : 0);
