# Deployment

One static deploy runs from `main`:

```
push to main ─▶ .github/workflows/pages.yml   public/  -> GitHub Pages
```

## Secrets

Set these in GitHub → Settings → Secrets and variables → Actions:

| Name | Used by | Value |
|---|---|---|
| `GOOGLE_CLIENT_ID` | `pages.yml` | OAuth Web client id |
| `GOOGLE_CLIENT_SECRET` | `pages.yml` | OAuth client secret |

The OAuth values are baked into the deployed HTML by `scripts/inject-env.mjs`,
which replaces the `__GOOGLE_CLIENT_ID__` / `__GOOGLE_CLIENT_SECRET__`
placeholders. **They are intentionally absent from git.** If unset, the app still
loads and the OAuth client id/secret can be pasted into Admin instead (stored in
`localStorage`).

## Steps

1. Create the repo and push `main`.
2. Settings → Pages → **Source: GitHub Actions**.
3. (Optional) Settings → Pages → **Custom domain** to serve on your own domain.

URL: `https://<your-username>.github.io/crypt-dashboard/`

## Local preview of injected config

```sh
GOOGLE_CLIENT_ID=... GOOGLE_CLIENT_SECRET=... make inject-public
```

(Do this on a throwaway copy — it edits the tracked file in place. Without
injection, use the in-app Admin fields.)

## Verify

```sh
make check                                   # syntax + secrets + hygiene
curl -sI https://<your-username>.github.io/crypt-dashboard/ | head -3
```

## Rollback

GitHub Pages keeps prior deployments; re-run the workflow for a previous commit.
