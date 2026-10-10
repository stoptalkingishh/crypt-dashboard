# Security model

## Principles

- **No backend.** There is no server to breach. The browser talks directly to
  Google and GitHub.
- **No secrets in git.** `make check` fails on committed keys; OAuth values are
  injected at deploy time and absent from the repo.
- **The public origin carries nothing sensitive.** No homelab hostnames, no
  tokens (a PAT, if any, lives only on the secure origin), enforced by
  `scripts/check.mjs`.

## Sensitive assets (all client-side, per-origin `localStorage`)

| Asset | Key | Scope/impact |
|---|---|---|
| Google refresh token | `cryptdash:auth:v1` | `openid email profile drive.appdata` only |
| Google access token | `cryptdash:auth:v1` | ~1 h |
| GitHub PAT (secure only) | state object | whatever scopes you grant it |
| Gemini API key | `cryptdash:ai:v1` | billed to your Google account |
| Config | state object | non-secret; also in Drive `appDataFolder` |

## Threat notes

**XSS is the primary risk.** Any script running on the origin can read all of the
above. This is inherent to a backend-less app that keeps tokens client-side.
Mitigations in this repo:

- No third-party/CDN scripts are loaded; the only network calls are `fetch` to
  Google/GitHub/Open-Meteo, plus the optional news proxy.
- Untrusted values (repo names, feed titles, profile) are inserted with `esc()` /
  `textContent`, never raw into HTML.
- Recommended hardening: serve a restrictive `Content-Security-Policy` header on
  the Cloudflare domain (see below) and avoid adding any analytics/embeds.

**The OAuth client secret is public** on the public surface. Google requires a
secret even with PKCE, so it ships in the client — same posture as `openquiz`.
It is not a server credential; PKCE + pinned redirect URI are the real controls.
See [GOOGLE-OAUTH.md](GOOGLE-OAUTH.md).

**GitHub Pages can't be gated.** `*.github.io` bypasses Cloudflare, so the secure
dashboard is *only* on Cloudflare Pages. There is no `github.io` copy of `secure/`.

**News proxy** (planned) sees the feed URLs you request and stores nothing; use
your own proxy for privacy. See [NEWS.md](NEWS.md).

## Cloudflare hardening (recommended)

On the secure domain, add headers via a Cloudflare Transform Rule / `_headers`:

```
Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline';
  style-src 'self' 'unsafe-inline'; img-src 'self' data: https://*.googleusercontent.com
  https://www.google.com; connect-src 'self' https://accounts.google.com
  https://oauth2.googleapis.com https://www.googleapis.com
  https://generativelanguage.googleapis.com https://api.github.com
  https://api.open-meteo.com; frame-ancestors 'none'; base-uri 'none'
Referrer-Policy: no-referrer
X-Content-Type-Options: nosniff
```

`'unsafe-inline'` is required because the app inlines its script/style. Keep
Cloudflare Access requiring MFA on the secure application.

## Recommendations

- Use a **dedicated** Google account or AI Studio key with restrictions.
- Grant the GitHub PAT the **minimum** scopes; ideally fine-grained, read-only.
- Rotate the PAT/Gemini key if a device is lost; sign out revokes the Google token.
- Keep the consent screen **published** (also avoids 7-day refresh-token expiry).

## Reporting

See [SECURITY.md](../SECURITY.md).
