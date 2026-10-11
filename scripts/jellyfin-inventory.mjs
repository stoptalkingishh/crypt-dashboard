#!/usr/bin/env node
/*
 * Build a Jellyfin library snapshot for crypt-dashboard's Scan feature.
 *
 *   JELLYFIN_URL=http://127.0.0.1:8096 JELLYFIN_API_KEY=xxxx \
 *     node scripts/jellyfin-inventory.mjs library.json
 *
 * Create an API key in Jellyfin: Dashboard -> API Keys -> +.
 * The output shape matches what the app imports (Admin -> collection -> import).
 *
 * Run it on the homelab (or anywhere that can reach Jellyfin). The resulting
 * file is a plain list of titles + ids — no media is copied.
 */
import { writeFileSync } from "node:fs";

const url = (process.env.JELLYFIN_URL || "").replace(/\/+$/, "");
const key = process.env.JELLYFIN_API_KEY || "";
if (!url || !key) {
  console.error("set JELLYFIN_URL and JELLYFIN_API_KEY");
  process.exit(1);
}
const out = process.argv[2] || "library.json";

const items = [];
let startIndex = 0;
const pageSize = 1000;
for (;;) {
  const q = new URLSearchParams({
    includeItemTypes: "Movie,Series",
    recursive: "true",
    fields: "ProviderIds,ProductionYear,Path",
    enableImages: "false",
    sortBy: "SortName",
    startIndex: String(startIndex),
    limit: String(pageSize),
    api_key: key,
  });
  const res = await fetch(`${url}/Items?${q}`, { headers: { Accept: "application/json" } });
  if (!res.ok) {
    console.error(`Jellyfin responded ${res.status} — check JELLYFIN_URL and JELLYFIN_API_KEY`);
    process.exit(1);
  }
  const data = await res.json();
  const page = data.Items || [];
  for (const it of page) {
    items.push({
      name: it.Name,
      type: it.Type,
      year: it.ProductionYear || null,
      tmdbId: (it.ProviderIds && it.ProviderIds.Tmdb) || null,
      imdbId: (it.ProviderIds && it.ProviderIds.Imdb) || null,
      path: it.Path || null,
    });
  }
  const total = data.TotalRecordCount || items.length;
  startIndex += page.length;
  if (!page.length || startIndex >= total) break;
}

const library = {
  generatedAt: new Date().toISOString(),
  server: url,
  count: items.length,
  items,
};
writeFileSync(out, JSON.stringify(library, null, 2));
console.error(`wrote ${out} (${items.length} items)`);
