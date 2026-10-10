#!/usr/bin/env node
/*
 * Inject Google OAuth config into a page at deploy time.
 *
 * The tracked HTML ships with __GOOGLE_CLIENT_ID__ / __GOOGLE_CLIENT_SECRET__
 * placeholders so no secret ever lands in git. This script replaces them with
 * values from the environment (wired to repository secrets in CI).
 *
 *   GOOGLE_CLIENT_ID=... GOOGLE_CLIENT_SECRET=... node scripts/inject-env.mjs public/index.html
 *
 * For local testing you can instead just fill the values in the Settings/Admin
 * panel — those are stored in localStorage and take precedence over the
 * injected ones.
 */
import { readFileSync, writeFileSync } from "node:fs";

const file = process.argv[2];
if (!file) {
  console.error("usage: inject-env.mjs <path/to/index.html>");
  process.exit(1);
}

const repl = {
  __GOOGLE_CLIENT_ID__: process.env.GOOGLE_CLIENT_ID || "",
  __GOOGLE_CLIENT_SECRET__: process.env.GOOGLE_CLIENT_SECRET || "",
};

let html = readFileSync(file, "utf8");
let replaced = 0;
for (const [token, value] of Object.entries(repl)) {
  // Escape for embedding inside a double-quoted JS string literal.
  const safe = JSON.stringify(value).slice(1, -1);
  const before = html;
  html = html.split(token).join(safe);
  if (html !== before) replaced += 1;
}
writeFileSync(file, html);
console.log(`inject-env: ${file} — injected ${replaced} value(s)`);
