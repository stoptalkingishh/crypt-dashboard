# Deployment

Two independent static deploys run from `main`:

```
push to main ─┬─▶ .github/workflows/pages.yml          public/  -> GitHub Pages
              └─▶ .github/workflows/deploy-secure.yml  secure/  -> Cloudflare Pages
```

## Secrets / variables

Set these in GitHub → Settings → Secrets and variables → Actions:

| Name | Type | Used by | Value |
|---|---|---|---|
| `GOOGLE_CLIENT_ID` | secret | both workflows | OAuth Web client id |
| `GOOGLE_CLIENT_SECRET` | secret | both workflows | OAuth client secret |
| `CLOUDFLARE_API_TOKEN` | secret | `deploy-secure.yml` | token with **Cloudflare Pages: Edit** |
| `CLOUDFLARE_ACCOUNT_ID` | secret | `deploy-secure.yml` | your Cloudflare account id |

The OAuth values are baked into the deployed HTML by `scripts/inject-env.mjs`,
which replaces the `__GOOGLE_CLIENT_ID__` / `__GOOGLE_CLIENT_SECRET__`
placeholders. **They are intentionally absent from git.** If unset, the app still
loads and the OAuth client id/secret can be pasted into Settings/Admin instead
(stored in `localStorage`).

## Domain map (`cryptanalyst.dev`)

| URL | Surface | Host |
|---|---|---|
| `https://cryptanalyst.dev` | public launcher | GitHub Pages (custom domain) |
| `https://home.cryptanalyst.dev` | secure dashboard | Cloudflare Pages + Access |

Attach `cryptanalyst.dev` as a **custom domain** to the Pages site (Settings →
Pages → Custom domain) so the public launcher lives on your domain instead of
`github.io`. The secure dashboard is a separate Cloudflare Pages project on the
`home.` subdomain, gated by Access.

## 1. Public surface — GitHub Pages

1. Create the repo: `github.com/stoptalkingishh/crypt-dashboard` and push `main`.
2. Settings → Pages → **Source: GitHub Actions**.
3. Settings → Pages → **Custom domain**: `cryptanalyst.dev` (adds a `CNAME`).
4. The workflow publishes **only `public/`** via `actions/upload-pages-artifact`,
   so `secure/` is never exposed on Pages.

URL: `https://cryptanalyst.dev` (GitHub Pages also serves
`https://stoptalkingishh.github.io/crypt-dashboard/`).

The secure-surface target is set in `public/index.html`:

```js
const SECURE_URL = "https://home.cryptanalyst.dev";   // your Access hostname
```

## 2. Secure surface — Cloudflare Pages + Access

Full walkthrough: [../cloudflare/README.md](../cloudflare/README.md). Summary:

- **Fast path (script):** `cloudflare/setup.sh` provisions the Pages project,
  custom domain, DNS, and Access app/policy via the API (idempotent, no
  Terraform). Then `npx wrangler pages deploy secure --project-name=crypt-dashboard-secure --branch=main`.
- **Git integration:** Workers & Pages → Create → Pages → connect the repo; build
  output directory `secure`, build command empty.
- **Or CI:** `deploy-secure.yml` uploads `secure/` with Wrangler
  (`pages deploy secure --project-name=crypt-dashboard-secure`); needs repo
  secrets `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID`.
- **Custom domain** + **Cloudflare Access application** on that hostname.
- Terraform alternative for the Pages domain + Access app/policy lives in `cloudflare/`:

  ```sh
  cd cloudflare
  cp terraform.tfvars.example terraform.tfvars   # edit
  export CLOUDFLARE_API_TOKEN=...
  terraform init && terraform apply
  ```

## Local preview of injected config

```sh
GOOGLE_CLIENT_ID=... GOOGLE_CLIENT_SECRET=... make inject-public
GOOGLE_CLIENT_ID=... GOOGLE_CLIENT_SECRET=... make inject-secure
```

(Do this on a throwaway copy — it edits the tracked files in place. Without
injection, use the in-app Settings/Admin fields.)

## Verify

```sh
make check                                   # syntax + secrets + hygiene
curl -sI https://home.cryptanalyst.dev | head -3  # expect Access redirect (302), not the app
```

## Rollback

Both targets are immutable-ish: re-run the workflow for a previous commit, or
`wrangler pages deployment list` / the Cloudflare dashboard to roll back the
secure deployment. Pages keeps prior deployments.
