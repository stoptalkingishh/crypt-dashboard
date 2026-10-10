# Google sign-in (OAuth 2.0 + PKCE)

Sign-in is **client-side Authorization Code + PKCE** — no backend. It is adapted
from the author's `openquiz` project. The redirect returns to the page itself, so
the redirect URI is simply the page URL.

Scopes requested:

```
openid email profile
https://www.googleapis.com/auth/drive.appdata   # backup to a hidden app folder
```

## Google Cloud setup

1. Create/select a project at <https://console.cloud.google.com>.
2. **APIs & Services → OAuth consent screen** — pick External (or Internal for a
   Workspace). Add the app name, support email, and scopes above.
3. **APIs & Services → Credentials → Create credentials → OAuth client ID**, type
   **Web application**.
4. Under **Authorized JavaScript origins** and **Authorized redirect URIs**, add
   both surfaces (no trailing path variations — match exactly):

   ```
   https://cryptanalyst.dev/
   https://home.cryptanalyst.dev/
   https://stoptalkingishh.github.io/crypt-dashboard/   # if you use the github.io URL
   ```

   The redirect URI is `location.origin + location.pathname` at sign-in time.
5. Copy the **Client ID** and **Client secret**.

## Where the values go

- **Preferred:** repository secrets `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET`;
  the deploy workflows inject them (`scripts/inject-env.mjs`).
- **Local / fallback:** paste them into the app's Settings/Admin panel; they are
  saved in `localStorage` under `cryptdash:env:v1` and take precedence.

## The client-secret caveat (read this)

Google's discovery document advertises only `client_secret_post` /
`client_secret_basic`, so **Google rejects a secret-less token exchange even with
PKCE** (unlike Auth0/Okta). The client secret therefore ships in the client
bundle, exactly as in `openquiz`.

What this means:

- PKCE still protects the auth code from interception, and the redirect URI is
  pinned — the secret does not grant anything PKCE hasn't already protected.
- The secret is **not** proof that a request came from your app. Do not treat it
  as a server credential.
- Because `public/index.html` is public, its secret is public. The upside of the
  public surface is there are no secrets beyond the OAuth client anyway.

## Token lifetime

- Access token: ~1 hour; refreshed automatically via the stored refresh token.
- Refresh token: persists until revoked or unused for 6 months — **except** while
  the consent screen is in **Testing**, where Google caps it at **7 days**. Publish
  the consent screen (**In production**) to avoid weekly sign-outs.

Tokens are stored in `localStorage` (`cryptdash:auth:v1`). Sign-out clears the
credential first, then attempts revocation. See
[SECURITY-MODEL.md](SECURITY-MODEL.md).

## Flow

```
sign-in  ->  accounts.google.com/o/oauth2/v2/auth  (code_challenge = S256(verifier))
callback ->  oauth2.googleapis.com/token           (code + verifier + client_secret)
profile  ->  id_token claims, or /oauth2/v3/userinfo
```

`state` is verified against the value issued before the redirect; the verifier is
stored in `sessionStorage` (`hs:pkce`) and consumed on use.

## Troubleshooting

| Symptom | Cause |
|---|---|
| `redirect_uri_mismatch` | The exact page URL isn't listed as a redirect URI |
| `invalid_client` | Wrong client id/secret for this client |
| "Google hasn't verified this app" | Consent screen not published; fine for test users |
| Signed out ~weekly | Consent screen still in Testing (7-day refresh cap) |
| `invalid_grant` on refresh | Token revoked/expired; app falls back to interactive sign-in |
