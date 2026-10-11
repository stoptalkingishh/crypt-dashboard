# crypt-dashboard

A personal **launcher + GitHub dashboard**, built as zero-build static
HTML/CSS/JS. It runs entirely **client-side** — no backend, no database, no
accounts. Data lives in the browser's `localStorage` and, optionally, in the
signed-in user's **own Google Drive**.

Everything personal is **per-user**: GitHub repositories, tiles, and settings are
configured after signing in with Google (and stored in that browser / Drive).
The shipped defaults are generic.

## Features

- **Start page** — clock/date, keyless weather (Open-Meteo), `!bang` search,
  categorized tiles with auto-fetched favicons, drag-to-reorder, theme.
- **GitHub repo dashboard** — live REST data per repo: stars, forks, open issues,
  language breakdown, recent commits; filter/sort; repo detail modal.
- **Google sign-in** — Authorization Code + PKCE, client-side. Profile/avatar,
  personalised greeting, and per-user config.
- **Drive backup** — save/restore your configuration to a hidden app folder in
  *your own* Google Drive (`drive.appdata`).
- **Gemini** — an "Ask Gemini" panel using your own API key (bring-your-own).
- **Collection scanner** — scan a store barcode (or type a UPC), and get
  `OWNED · server` / `OWNED · physical` / `NOT OWNED` against a Jellyfin library
  snapshot plus your physical list. Import/export the inventory as JSON/CSV.
- **Admin panel** — edit categories & tiles, weather, GitHub, collection,
  backup, and export/import as JSON.

## Quick start (local)

```sh
make serve        # http://localhost:8765/public/
make check        # syntax + secret + hygiene checks
```

No build step. Open the HTML directly or serve the folder from any static host.

## Repository layout

```
crypt-dashboard/
├─ README.md  LICENSE  ATTRIBUTION.md  THIRD_PARTY_NOTICES.md  CHANGELOG.md
├─ CONTRIBUTING.md  SECURITY.md  AGENTS.md
├─ Makefile  serve.sh  package.json  .editorconfig  .gitignore  .env.example
├─ public/            # GitHub Pages artifact (single surface)
│  ├─ index.html
│  └─ .nojekyll
├─ scripts/
│  ├─ inject-env.mjs             # bakes OAuth client id/secret at deploy time
│  ├─ check.mjs                  # repo checks (make check)
│  └─ jellyfin-inventory.mjs     # Jellyfin library -> library.json snapshot
├─ docs/              # detailed documentation
└─ .github/workflows/
   └─ pages.yml         # public/  -> GitHub Pages
```

## Documentation

| Doc | What it covers |
|---|---|
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | How the app works; module map; data flow |
| [CONFIGURATION.md](docs/CONFIGURATION.md) | The state/settings object; localStorage keys |
| [DEPLOYMENT.md](docs/DEPLOYMENT.md) | GitHub Pages + secrets |
| [GOOGLE-OAUTH.md](docs/GOOGLE-OAUTH.md) | Google Cloud setup, scopes, PKCE, caveats |
| [DRIVE-BACKUP.md](docs/DRIVE-BACKUP.md) | How backup/restore works |
| [GEMINI.md](docs/GEMINI.md) | Bring-your-own-key Gemini integration |
| [COLLECTION.md](docs/COLLECTION.md) | Jellyfin snapshot + barcode scanner |
| [NEWS.md](docs/NEWS.md) | Planned news + media-bias module (spec) |
| [SECURITY-MODEL.md](docs/SECURITY-MODEL.md) | Threat model and guarantees |
| [ROADMAP.md](docs/ROADMAP.md) | What's done / next |
| [RESEARCH.md](docs/RESEARCH.md) | Upstream projects studied and adapted |

## License & attribution

Licensed **AGPL-3.0-or-later** — see [LICENSE](LICENSE). Built from open-source
patterns; credits in [ATTRIBUTION.md](ATTRIBUTION.md), full third-party license
texts in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
