# Contributing

Thanks for helping. This is a small, dependency-free project — please keep it
that way.

## Ground rules

- **No build step.** No bundlers, transpilers, npm dependencies, or CDN scripts.
  The files you edit are the files that ship.
- **No backend.** Do not add a server, database, or server-side API. Persistence
  is `localStorage` and (optionally) the user's own Google Drive.
- **Two surfaces must stay in sync.** `public/index.html` and `secure/index.html`
  each contain a copy of the app engine. If you change shared behaviour, change
  it in **both** (the only intended differences: the state default, the
  admin-vs-settings UI, the `noindex` meta, and the secure-only homelab tiles).
- **Comments:** only where they explain *why*, not *what*.

## Before you push

```sh
make check     # inline-script syntax, committed-secret scan, public-surface hygiene
make serve     # click through both surfaces
```

`make check` must pass. It fails on syntax errors, committed credentials, and any
internal hostname leaking into `public/`.

## Working on the code

1. Edit `public/index.html` and `secure/index.html` (or the shell/docs).
2. Run `make check`; preview with `make serve`.
3. Keep the diff focused; update docs and `CHANGELOG.md`.

### Adding a launch category or tile

Edit `settings.categories` default (`defaultState()` / `publicDefault()`), or use
the in-app Admin/Settings panel. Tiles: `{ name, url }`.

### Adding a dynamic view

Give a category a new `type`, add `<section id="view-X" hidden>`, branch in
`renderView()`, and implement `renderX()`. See `type: "github"` as the model and
[docs/NEWS.md](docs/NEWS.md) for the planned news view.

### Touching auth / tokens

Read [docs/SECURITY-MODEL.md](docs/SECURITY-MODEL.md) and
[docs/GOOGLE-OAUTH.md](docs/GOOGLE-OAUTH.md) first. Never log tokens; never write
secrets to the repo; keep OAuth values as deploy-injected placeholders.

## Style

- 2-space indent, LF, UTF-8 (see `.editorconfig`).
- Vanilla ES2020; no frameworks.
- Escape untrusted data with `esc()` before inserting HTML.
- Small, single-purpose functions; keep the surface files readable.

## Secrets

Never commit `GOOGLE_CLIENT_SECRET`, GitHub PATs, or Gemini keys. `.env` is
git-ignored; deploy values come from repository secrets via
`scripts/inject-env.mjs`. If you paste a value locally for testing, it goes in
`localStorage` (Settings/Admin), not the file.
