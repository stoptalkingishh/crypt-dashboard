# AGENTS.md

Guidance for AI coding agents (and humans) working in this repository.

## What this is

A **zero-build, client-side** personal launcher + GitHub dashboard. One static
surface (`public/index.html`) deployed to GitHub Pages. There is **no backend**
and no build system. See `docs/ARCHITECTURE.md`.

Personal data (GitHub repos, tiles, settings) is per-user: configured after
Google sign-in and stored in the browser's `localStorage` / the user's Google
Drive. **The shipped defaults must stay generic** — no usernames, emails,
hostnames, or personal links.

## Hard constraints — do not violate

1. **No build step / no dependencies.** Plain HTML/CSS/JS served as-is. No npm,
   bundlers, frameworks, or CDN/`<script src>` from third parties.
2. **No backend.** All data lives in `localStorage` or the user's Google Drive.
   Never add a server, database, or API of our own.
3. **No personal identifiers in the repo.** No GitHub usernames, emails,
   internal/LAN IPs, or personal hostnames in `public/` or anywhere tracked.
   Run `make check`; it enforces this.
4. **No comments** unless explaining non-obvious *why*.

## Layout

```
public/index.html                          # the app (edit this)
scripts/inject-env.mjs  scripts/check.mjs  # tooling
docs/                                      # documentation
.github/workflows/pages.yml                 # GitHub Pages deploy
```

## Verify before finishing

```sh
make check      # must pass: syntax, secret scan, no internal hosts, noindex
make serve      # http://localhost:8765/public/  (manual smoke test)
```

`make check` is the narrow validation that proves the changed behaviour didn't
break the contract (parse errors, leaked secrets, personal/private hosts).

## Common tasks

- **State/config shape** → `docs/CONFIGURATION.md`; defaults in `defaultState()`.
- **Auth/tokens** → `docs/GOOGLE-OAUTH.md`, `docs/SECURITY-MODEL.md`.
- **Drive backup** → `docs/DRIVE-BACKUP.md`.
- **News module** (unfinished) → `docs/NEWS.md` is the spec.
- **Deployment** → `docs/DEPLOYMENT.md`.

## Gotchas

- State key is `cryptdash:state:v1`; settings/rows live in `localStorage`.
- `__GOOGLE_CLIENT_ID__` / `__GOOGLE_CLIENT_SECRET__` placeholders are required
  for deploy-time injection; `check.mjs` fails if they're missing.
- GitHub repos default to an **empty** user list; users add themselves in Admin.
