# Security model

## Principles

- **No backend.** There is no server to breach. The browser talks directly to
  Google and GitHub.
- **No secrets in git.** `make check` fails on committed keys; OAuth values are
  injected at deploy time and absent from the repo.
- **No personal data in source.** The shipped defaults are generic; usernames,
  tokens, and tiles are entered per-user at runtime and live in that browser.

## Sensitive assets (all client-side, per-browser `localStorage`)

| Asset | Key | Scope/impact |
|---|---|---|
| Google refresh token | `cryptdash:auth:v1` | `openid email profile drive.appdata` only |
| Google access token | `cryptdash:auth:v1` | ~1 h |
| GitHub PAT (optional) | state object | whatever scopes you grant it |
| Gemini API key | `cryptdash:ai:v1` | billed to your Google account |
| Config | state object | non-secret; also in Drive `appDataFolder` |

## Threat notes

**XSS is the primary risk.** Any script running on the origin can read all of the
above. This is inherent to a backend-less app that keeps tokens client-side.
Mitigations in this repo:

- No third-party/CDN scripts are loaded; the only network calls are `fetch` to
  Google/GitHub/Open-Meteo (plus the optional news proxy).
- Untrusted values (repo names, feed titles, profile) are inserted with `esc()` /
  `textContent`, never raw into HTML.
- Recommended hardening: add a `<meta http-equiv="Content-Security-Policy">` to
  the page (e.g. `default-src 'self'; script-src 'self' 'unsafe-inline';
  connect-src 'self' https://accounts.google.com https://oauth2.googleapis.com
  https://www.googleapis.com https://generativelanguage.googleapis.com
  https://api.github.com https://api.open-meteo.com; frame-ancestors 'none'`).

**The OAuth client secret is public.** Google requires a secret even with PKCE, so
it ships in the client. It is not a server credential; PKCE + a pinned redirect
URI are the real controls. See [GOOGLE-OAUTH.md](GOOGLE-OAUTH.md).

**This page is public by design.** There is no server-side state and no Access
gate; anything a viewer configures is their own (per-browser). Do not put
sensitive links or secrets in `public/` — `make check` flags internal hostnames.

## Recommendations

- Use a **dedicated** Google account or AI Studio key with restrictions.
- Grant the GitHub PAT the **minimum** scopes; ideally fine-grained, read-only.
- Rotate the PAT/Gemini key if a device is lost; sign out revokes the Google token.
- Keep the consent screen **published** (also avoids 7-day refresh-token expiry).

## Reporting

See [SECURITY.md](../SECURITY.md).
