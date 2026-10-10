# Configuration

Everything is configured from the app itself (settings/admin panel) and stored in
`localStorage`. You can also export/import the whole state as JSON, or back it up
to Google Drive. The built-in defaults live in `defaultState()` (secure) /
`publicDefault()` (public).

## State object

```jsonc
{
  "settings": {
    "title": "crypt-dashboard",
    "theme": "auto",            // "auto" | "dark" | "light"
    "hour12": true,
    "search":  { "name": "Google", "url": "https://www.google.com/search?q={q}" },
    "weather": { "latitude": null, "longitude": null, "unit": "fahrenheit", "label": "" },
    "github":  { "user": "stoptalkingishh", "sort": "updated", "hideForks": false },
    "news": {
      "proxy": "https://api.allorigins.win/raw?url={url}",  // {url} = encoded feed URL
      "biasApi": "",                                        // optional runtime bias API
      "clusterThreshold": 0.42,
      "windowHours": 48,
      "blindspotMinSources": 2,
      "minSourcesFilter": 1,
      "blindspotsOnly": false,
      "feeds": [ { "name": "NPR", "url": "https://feeds.npr.org/1001/rss.xml" } ]
    }
  },
  "categories": [
    { "id": "home", "name": "Home", "type": "links",  "tiles": [ { "name": "GitHub", "url": "https://github.com" } ] },
    { "id": "news", "name": "News", "type": "news",   "tiles": [] },
    { "id": "repos","name": "Repos","type": "github", "tiles": [] }
  ]
}
```

`{q}` in search/bang URLs is replaced with the URL-encoded query. `{url}`/`{domain}`
in news settings are replaced similarly.

### Secure surface differences

- `settings.github.users` is an **array** (multiple accounts); `settings.github.token`
  holds an optional GitHub PAT (see [SECURITY-MODEL.md](SECURITY-MODEL.md)).
- The default `home` category contains homelab tiles that are **never** present in
  the public surface.

## localStorage keys

| Key | Written by | Contents |
|---|---|---|
| `cryptdash:public:v1` / `cryptdash:state:v1` | app | the state object (public/secure) |
| `cryptdash:theme` | theme toggle | last explicit theme choice |
| `cryptdash:public:ghcache:v1` / `cryptdash:ghcache:v1` | repo view | cached GitHub API responses (10 min) |
| `cryptdash:wx:v1` | weather | cached Open-Meteo reading (15 min) |
| `cryptdash:auth:v1` | Google sign-in | profile + access/refresh tokens |
| `cryptdash:ai:v1` | settings | Gemini model + API key |
| `cryptdash:env:v1` | settings | local override of OAuth client id/secret |
| `cryptdash:drive:auto` | account menu | auto-backup flag (`"1"`/`"0"`) |
| `cryptdash:news:v1` | news view *(planned)* | cached articles (15 min) |
| `cryptdash:news:bias:v1` | news view *(planned)* | cached bias-API lookups |

> The two surfaces have separate origins (`github.io` vs your domain), so their
> `localStorage` is independent. Move config between them with **export/import**
> or **Drive backup**.

## Ways to configure

1. **In-app** — gear icon (secure: full admin; public: settings sheet).
2. **Import/export** — the export button writes `crypt-dashboard-*.json`; import reads
   one back. This is the supported way to move state across surfaces or browsers.
3. **Drive backup** — see [DRIVE-BACKUP.md](DRIVE-BACKUP.md).
4. **Edit defaults** — change `defaultState()`/`publicDefault()` in the HTML to
   ship different defaults (this is code, not user config).

## Search bangs

Default: `!g !gh !yt !w !ddg !repo !hn !so !mdn !npm !r !maps !gpt !cl !pp`.
A bang with a query routes to that site's search; a bare bang opens its home.
Type a bare domain to navigate; otherwise the query goes to `settings.search.url`.
