# Architecture

## Principles

1. **Zero build.** No bundler, transpiler, or package manager is required to
   deploy. The shipped files are the source files.
2. **Client-side only.** There is no backend, database, or API of our own. The
   browser talks directly to Google (OAuth/Drive/Gemini) and GitHub.
3. **Self-contained surfaces.** `public/index.html` and `secure/index.html` are
   each a single HTML file with inline CSS and JS. They share no runtime files,
   so each can be deployed to a different host without a shared origin.
4. **Reproducible by config.** State is a single JSON object in `localStorage`
   (and optionally Google Drive); no server-side settings.

## Two surfaces, one repo

| | Public | Secure |
|---|---|---|
| File | `public/index.html` | `secure/index.html` |
| Host | GitHub Pages | Cloudflare Pages |
| Gate | none | Cloudflare Access (SSO) |
| Indexing | `index, follow` | `noindex, nofollow` |
| State key | `cryptdash:public:v1` | `cryptdash:state:v1` |
| GitHub | public repos only | token allowed → private repos |
| Homelab tiles | absent (never committed here) | present |
| Admin UI | compact settings sheet | full admin panel |

The public surface **must never** contain internal hostnames or secrets. This is
enforced by `make check` (`scripts/check.mjs`).

## Why single-file surfaces

A shared `assets/app.js` would break the "independent surfaces" rule: GitHub
Pages can only publish `public/`, and Cloudflare Pages publishes `secure/`, so a
repo-root `assets/` directory is outside both artifacts. Rather than introduce a
copy/build step, each surface inlines its own copy of the engine. The trade-off
is duplication (documented in [CONTRIBUTING.md](../CONTRIBUTING.md)); the payoff
is that each file is a complete, offline-capable app you can open from `file://`.

## Module map (identical in both surfaces)

```
index.html
├─ <style>            design tokens (:root / [data-theme]) + component CSS
├─ theme bootstrap     inline, runs before first paint (no flash)
├─ window.HS_ENV       OAuth config placeholders (injected at deploy)
└─ app <script>
   ├─ defaults & state  defaultState()/publicDefault(), load/save, migrate
   ├─ helpers           $, esc, faviconFor, timeAgo, toast
   ├─ theme             applyTheme()
   ├─ clock             renderClock() (1 s interval)
   ├─ weather           initWeather()  -> Open-Meteo (keyless)
   ├─ search & bangs    parseBang(), searchDestination()
   ├─ tabs + launcher   renderTabs(), renderGrid(), tile drag-reorder
   ├─ GitHub repos      fetchRepos(), renderRepos(), openRepoModal()
   ├─ auth (PKCE)       signInWithGoogle(), handleOAuthCallback(), refresh
   ├─ Drive backup      driveSave()/driveLoad() -> appDataFolder
   ├─ Gemini            loadAi(), runGemini(), openAi()
   ├─ admin / settings  openAdmin()/openSettings(), collectAdmin()
   └─ boot              renderClock, initWeather, handleOAuthCallback, boot
```

`type: "github"` and `type: "news"` categories are rendered by dedicated views
(`#view-repos`, `#view-news`); `type: "links"` categories render the tile grid.

## Data flow

```
Launcher      tiles/categories ──────────────▶ localStorage ─┐
Weather       Open-Meteo ────────────▶ cache ┤               │
GitHub        api.github.com ───────▶ cache ─┤               ├─▶ Google Drive
Auth          accounts.google.com ──▶ tokens ┤  (optional)   │   (appDataFolder)
Drive backup  drive v3 (appDataFolder) ◀─────┘               │
Gemini        generativelanguage.googleapis.com ◀────────────┘ (direct, BYO key)
```

- GitHub responses are cached 10 min (`cryptdash:*ghcache*`) to respect rate
  limits (60/hr unauthenticated, 5 000/hr with a token).
- Weather is cached 15 min.
- Drive backup is manual or debounced (2.5 s) when "auto back up" is on.

## Extending

- New tile category: add an entry to `settings.categories` (admin UI or default).
- New dynamic view: give a category a new `type`, add a `<section id="view-X">`,
  and branch in `renderView()`. See [NEWS.md](NEWS.md) for the planned one.
