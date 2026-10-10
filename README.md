# crypt-dashboard

A personal **launcher + dashboard** built as zero-build static HTML/CSS/JS.
Everything runs **client-side**: no backend, no database, no accounts. Data lives
in the browser's `localStorage` and, optionally, in the signed-in user's **own
Google Drive**.

It ships as **two independent static surfaces** deployed from one repo:

| Surface | File | Host | Reachability |
|---|---|---|---|
| **Public** | `public/index.html` | GitHub Pages | Anyone (public data only) |
| **Secure** | `secure/index.html` | Cloudflare Pages | **Cloudflare Access** (Zero Trust SSO) |

```
 ┌────────────────────┐        push to main        ┌──────────────────────────┐
 │  GitHub repo       │ ────────────────────────▶ │ GitHub Pages  (public/)  │
 │  stoptalkingishh/  │                            └──────────────────────────┘
 │  crypt-dashboard   │        push to main        ┌──────────────────────────┐
 │                    │ ────────────────────────▶ │ Cloudflare Pages         │
 └────────────────────┘                            │  secure/  + Access (SSO) │
                                                    └──────────────────────────┘
```

Live at **`cryptanalyst.dev`**:

| URL | Surface |
|---|---|
| `https://cryptanalyst.dev` | public launcher |
| `https://home.cryptanalyst.dev` | secure dashboard (Cloudflare Access) |

## Features

- **Start page** — clock/date, keyless weather (Open-Meteo), `!bang` search,
  categorized tiles with auto-fetched favicons, drag-to-reorder, theme.
- **GitHub repo dashboard** — live REST data per repo: stars, forks, open issues,
  language breakdown, recent commits; filter/sort; repo detail modal.
- **Google sign-in** — Authorization Code + PKCE, client-side. Profile/avatar and
  a personalised greeting.
- **Drive backup** — save/restore your configuration to a hidden app folder in
  *your own* Google Drive (`drive.appdata`). No server ever sees it.
- **Gemini** — an "Ask Gemini" panel using your own API key (bring-your-own).
- **Admin panel** (secure) / settings (public) — edit categories & tiles, weather,
  GitHub, backup, and export/import as JSON.

> **Security note.** GitHub Pages always serves its artifact publicly, and that
> `*.github.io` origin bypasses Cloudflare. The secure dashboard is therefore
> deployed to **Cloudflare Pages** (a second target from the same repo) and gated
> with Cloudflare Access — there is no `github.io` copy of it. Never put secrets
> in `public/`. See [docs/SECURITY-MODEL.md](docs/SECURITY-MODEL.md).

## Quick start (local)

```sh
make serve        # http://localhost:8765/public/ and /secure/
make check        # syntax + secret + hygiene checks
```

No build step. Open the HTML directly or serve the folder from any static host.

## Repository layout

```
crypt-dashboard/
├─ README.md  LICENSE  ATTRIBUTION.md  THIRD_PARTY_NOTICES.md  CHANGELOG.md
├─ CONTRIBUTING.md  SECURITY.md  AGENTS.md
├─ Makefile  serve.sh  package.json  .editorconfig  .gitignore  .env.example
├─ public/            # GitHub Pages artifact  (PUBLIC only)
│  ├─ index.html
│  └─ .nojekyll
├─ secure/            # Cloudflare Pages artifact (gated by Access)
│  └─ index.html
├─ scripts/
│  ├─ inject-env.mjs  # bakes OAuth client id/secret at deploy time
│  └─ check.mjs       # repo checks (make check)
├─ cloudflare/        # Terraform: Pages project/domain + Access application
├─ docs/              # detailed documentation
└─ .github/workflows/
   ├─ pages.yml         # public/  -> GitHub Pages
   └─ deploy-secure.yml # secure/  -> Cloudflare Pages
```

## Documentation

| Doc | What it covers |
|---|---|
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | How the two surfaces work; module map; data flow |
| [CONFIGURATION.md](docs/CONFIGURATION.md) | The state/settings object; localStorage keys |
| [DEPLOYMENT.md](docs/DEPLOYMENT.md) | GitHub Pages + Cloudflare Pages + secrets |
| [GOOGLE-OAUTH.md](docs/GOOGLE-OAUTH.md) | Google Cloud setup, scopes, PKCE, caveats |
| [DRIVE-BACKUP.md](docs/DRIVE-BACKUP.md) | How backup/restore works |
| [GEMINI.md](docs/GEMINI.md) | Bring-your-own-key Gemini integration |
| [NEWS.md](docs/NEWS.md) | Planned news + media-bias module (spec) |
| [SECURITY-MODEL.md](docs/SECURITY-MODEL.md) | Threat model and guarantees |
| [ROADMAP.md](docs/ROADMAP.md) | What's done / next |
| [RESEARCH.md](docs/RESEARCH.md) | Upstream projects studied and forked from |

## License & attribution

Licensed **AGPL-3.0-or-later** — see [LICENSE](LICENSE). Built from open-source
patterns; credits in [ATTRIBUTION.md](ATTRIBUTION.md), full third-party license
texts in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
