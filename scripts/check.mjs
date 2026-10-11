#!/usr/bin/env node
/*
 * Repo checks for crypt-dashboard.
 *
 *   - every inline <script> parses (node --check)
 *   - deploy placeholders are present
 *   - no real secrets are committed anywhere in the repo
 *   - the surface leaks no internal/private hostnames
 *   - the surface is marked noindex
 *
 * Run with `make check` or `node scripts/check.mjs`. Exits non-zero on failure.
 */
import { readFileSync, readdirSync, statSync, mkdtempSync, writeFileSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { tmpdir } from "node:os";
import { join, relative } from "node:path";

const ROOT = process.cwd();
const SURFACES = ["public/index.html"];
const SKIP_DIRS = new Set([".git", "node_modules", ".wrangler", ".terraform", "dist"]);
let failures = 0;
const fail = (m) => { console.error(`\x1b[31m✗ ${m}\x1b[0m`); failures += 1; };
const ok = (m) => console.log(`\x1b[32m✓\x1b[0m ${m}`);

// Patterns for real credentials (placeholders like "<your-...>" do not match).
const SECRETS = [
  [/ghp_[A-Za-z0-9]{20,}/, "GitHub PAT (ghp_)"],
  [/github_pat_[A-Za-z0-9_]{20,}/, "GitHub fine-grained PAT"],
  [/GOCSPX-[A-Za-z0-9_-]{10,}/, "Google OAuth client secret"],
  [/AIza[0-9A-Za-z_-]{35}/, "Google API key"],
  [/sk-[A-Za-z0-9]{20,}/, "OpenAI-style key"],
  [/-----BEGIN [A-Z ]*PRIVATE KEY-----/, "private key material"],
];

function walk(dir, out = []) {
  for (const name of readdirSync(dir)) {
    if (SKIP_DIRS.has(name)) continue;
    const p = join(dir, name);
    const st = statSync(p);
    if (st.isDirectory()) walk(p, out);
    else if (st.size < 1_000_000) out.push(p);
  }
  return out;
}

// --- 1. inline script syntax ---
const dir = mkdtempSync(join(tmpdir(), "cd-check-"));
for (const file of SURFACES) {
  let html;
  try { html = readFileSync(file, "utf8"); } catch { fail(`${file}: cannot read`); continue; }

  const scripts = [...html.matchAll(/<script>([\s\S]*?)<\/script>/g)].map((m) => m[1]);
  if (!scripts.length) fail(`${file}: no inline <script> blocks found`);
  scripts.forEach((js, i) => {
    const p = join(dir, `${file.replace(/\W/g, "_")}_${i}.js`);
    writeFileSync(p, js);
    try { execFileSync("node", ["--check", p], { stdio: "pipe" }); }
    catch (e) { fail(`${file}: inline script #${i} syntax error\n${String(e.stderr || e).slice(0, 600)}`); }
  });
  if (scripts.length) ok(`${file}: ${scripts.length} inline script(s) parse`);

  if (!html.includes("__GOOGLE_CLIENT_ID__")) fail(`${file}: missing __GOOGLE_CLIENT_ID__ placeholder`);
  else ok(`${file}: env placeholder present`);
}

// --- 2. repo-wide secret scan ---
let scanned = 0, hits = 0;
for (const p of walk(ROOT)) {
  let text;
  try { text = readFileSync(p, "utf8"); } catch { continue; }
  if (text.includes("\u0000")) continue;
  scanned += 1;
  for (const [re, name] of SECRETS) {
    if (re.test(text)) { fail(`${relative(ROOT, p)}: possible committed ${name}`); hits += 1; }
  }
}
if (!hits) ok(`no secrets in ${scanned} text file(s)`);

// --- 3. public surface must not expose internal hostnames ---
const pub = readFileSync("public/index.html", "utf8");
const INTERNAL = [/192\.168\.\d+\.\d+/, /\b10\.\d+\.\d+\.\d+\b/, /172\.(1[6-9]|2\d|3[01])\.\d+\.\d+/];
let leaked = false;
for (const re of INTERNAL) if (re.test(pub)) { fail(`public/index.html: leaks internal host matching ${re}`); leaked = true; }
if (!leaked) ok("public surface: no internal hostnames");

// --- 4. surface hygiene ---
if (!/name="robots"[^>]*noindex/i.test(pub)) fail("public/index.html: missing robots noindex");
else ok("public surface: noindex present");

console.log(failures ? `\n\x1b[31m${failures} check(s) failed\x1b[0m` : "\n\x1b[32mall checks passed\x1b[0m");
process.exit(failures ? 1 : 0);
