# AGENTS.md

Guidance for AI coding agents (and humans) working in this repository.

## What this is

A **zero-build, client-side** personal launcher + dashboard. Two independent
static surfaces deployed from one repo:

- `public/index.html` → GitHub Pages (public; no secrets, no internal hosts)
- `secure/index.html` → Cloudflare Pages behind Cloudflare Access (homelab tiles,
  GitHub token, full admin)

Both files are self-contained single-page apps (inline CSS + JS). There is **no
backend** and no build system. See `docs/ARCHITECTURE.md`.

## Hard constraints — do not violate

1. **No build step / no dependencies.** Plain HTML/CSS/JS served as-is. No npm,
   bundlers, frameworks, or CDN/`<script src>` from third parties.
2. **No backend.** All data lives in `localStorage` or the user's Google Drive.
   Never add a server, database, or API of our own.
3. **Keep both surfaces in sync.** Shared behaviour must be changed in *both*
   `public/index.html` and `secure/index.html`. Intended differences only:
   state default/key, admin vs settings UI, `noindex` meta, homelab tiles,
   GitHub token support.
4. **No secrets in `public/`.** Run `make check`; it enforces this.
5. **No comments** unless explaining non-obvious *why*.

## Layout

```
public/index.html      secure/index.html      # the two apps (edit these)
scripts/inject-env.mjs scripts/check.mjs      # tooling
cloudflare/            # Terraform (Pages + Access)
docs/                  # documentation (update when behaviour changes)
.github/workflows/     # pages.yml, deploy-secure.yml
```

## Verify before finishing

```sh
make check      # must pass: syntax, secret scan, public-surface hygiene
node scripts/check.mjs
make serve      # http://localhost:8765/public/ and /secure/  (manual smoke test)
```

`make check` is the narrow validation that proves the changed behaviour didn't
break the contract (parse errors, leaked secrets, internal hosts in public).

## Common tasks

- **State/config shape** → `docs/CONFIGURATION.md`; defaults in
  `defaultState()`/`publicDefault()`.
- **Auth/tokens** → `docs/GOOGLE-OAUTH.md`, `docs/SECURITY-MODEL.md`.
- **Drive backup** → `docs/DRIVE-BACKUP.md`.
- **News module** (unfinished) → `docs/NEWS.md` is the spec; only scaffolding
  exists in `public/index.html`. Implement in both surfaces when building it.
- **Deployments** → `docs/DEPLOYMENT.md`.

## Gotchas

- The 👍 state key differs by surface (`cryptdash:public:v1` vs
  `cryptdash:state:v1`); the two origins have separate `localStorage`.
- `__GOOGLE_CLIENT_ID__` / `__GOOGLE_CLIENT_SECRET__` placeholders are required
  for deploy-time injection; `check.mjs` fails if they're missing.
- Homelab hostnames belong only in `secure/index.html`.
- Secure homelab tiles use the codename hostnames
  (`cipher`/`cinema`/`player`/`pulse`/`oracle`/`gate`).cryptanalyst.dev. See the
  workspace `AGENTS.md` → "Homelab service codenames"; keep in sync with
  `homelab/cloudflare/hostnames.tsv`.
