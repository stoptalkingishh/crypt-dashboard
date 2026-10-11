# Architecture

## Principles

1. **Zero build.** No bundler, transpiler, or package manager is required to
   deploy. The shipped file is the source file.
2. **Client-side only.** There is no backend, database, or API of our own. The
   browser talks directly to Google (OAuth/Drive/Gemini) and GitHub.
3. **Self-contained.** `public/index.html` is a single HTML file with inline CSS
   and JS. It is a complete, offline-capable app you can open from `file://`.
4. **Per-user config.** State is a single JSON object in `localStorage` (and
   optionally Google Drive). Personal data is never baked into the file; users
   configure it after Google sign-in.

## Single surface

| | Value |
|---|---|
| File | `public/index.html` |
| Host | GitHub Pages |
| Indexing | `noindex, nofollow` |
| State key | `cryptdash:state:v1` |
| Personal data | none in source; entered per-user at runtime |

`make check` enforces that `public/index.html` contains no internal/LAN
hostnames and no committed credentials.

## Module map

```
index.html
├─ <style>            design tokens (:root / [data-theme]) + component CSS
├─ theme bootstrap     inline, runs before first paint (no flash)
├─ window.HS_ENV       OAuth config placeholders (injected at deploy)
└─ app <script>
   ├─ defaults & state  defaultState(), load/save, migrate
   ├─ helpers           $, esc, faviconFor, timeAgo, toast
   ├─ theme             applyTheme()
   ├─ clock             renderClock() (1 s interval)
   ├─ weather           initWeather()  -> Open-Meteo (keyless)
   ├─ search & bangs    parseBang(), searchDestination()
   ├─ tabs + launcher   renderTabs(), renderGrid(), tile drag-reorder
   ├─ GitHub repos      fetchRepos(), renderRepos(), openRepoModal()
   ├─ collection        startScan()/handleUpc(), matchLibrary(), upcLookup()
   ├─ auth (PKCE)       signInWithGoogle(), handleOAuthCallback(), refresh
   ├─ Drive backup      driveSave()/driveLoad() -> appDataFolder
   ├─ Gemini            loadAi(), runGemini(), openAi()
   ├─ admin             openAdmin(), collectAdmin()
   └─ boot              renderClock, initWeather, handleOAuthCallback, boot
```

`type: "github"` categories render `#view-repos`; `type: "scan"` categories
render `#view-scan`; `type: "links"` categories render the tile grid.

## Data flow

```
Launcher      tiles/categories ──────────────▶ localStorage ─┐
Weather       Open-Meteo ────────────▶ cache ┤               │
GitHub        api.github.com ───────▶ cache ─┤               ├─▶ Google Drive
Auth          accounts.google.com ──▶ tokens ┤  (optional)   │   (appDataFolder)
Drive backup  drive v3 (appDataFolder) ◀─────┘               │
Gemini        generativelanguage.googleapis.com ◀────────────┘ (direct, BYO key)
Scanner       proxy -> UPCitemdb (+ api.themoviedb.com) ──▶ match in memory ───┘
Library       homelab Jellyfin ──(scripts/jellyfin-inventory.mjs, outside the app)
              ──▶ library.json ──(Admin import)──▶ state.library
```

- GitHub responses are cached 10 min (`cryptdash:ghcache:v1`) to respect rate
  limits (60/hr unauthenticated, 5 000/hr with a token).
- Weather is cached 15 min.
- The library is a **snapshot**, not a live Jellyfin query: Jellyfin never
  receives cross-origin browser traffic, and the LAN URL needn't resolve on the
  phone. Scans are matched in memory; nothing about a scan is persisted unless
  the user adds it to `physical`.
- Drive backup is manual or debounced (2.5 s) when "auto back up" is on.

## Extending

- New tile category: add an entry to `settings.categories` (Admin UI or default).
- New dynamic view: give a category a new `type`, add a `<section id="view-X">`,
  and branch in `renderView()`. See [NEWS.md](NEWS.md) for the planned one.
