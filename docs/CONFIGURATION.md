# Configuration

Everything is configured from the app itself (Admin panel) and stored in
`localStorage`. You can also export/import the whole state as JSON, or back it up
to Google Drive. The built-in defaults live in `defaultState()`.

## State object

```jsonc
{
  "settings": {
    "title": "crypt-dashboard",
    "theme": "auto",            // "auto" | "dark" | "light"
    "hour12": true,
    "search":  { "name": "Google", "url": "https://www.google.com/search?q={q}" },
    "weather": { "latitude": null, "longitude": null, "unit": "fahrenheit", "label": "" },
    "github":  { "users": [], "token": "", "sort": "updated", "hideForks": false, "liveRepos": true }
  },
  "categories": [
    { "id": "home", "name": "Home", "type": "links",  "tiles": [ { "name": "GitHub", "url": "https://github.com" } ] },
    { "id": "repos","name": "Repos","type": "github", "tiles": [] }
  ]
}
```

- `settings.github.users` is an **array** of accounts (multiple supported);
  `settings.github.token` holds an optional GitHub PAT for private repos
  (see [SECURITY-MODEL.md](SECURITY-MODEL.md)).
- The defaults are **generic** — no usernames, emails, or hostnames. Personal
  config is entered in Admin and stored per-browser.
- News settings are **planned** (see [NEWS.md](NEWS.md)); not yet in the schema.

`{q}` in search/bang URLs is replaced with the URL-encoded query.

## localStorage keys

| Key | Written by | Contents |
|---|---|---|
| `cryptdash:state:v1` | app | the state object |
| `cryptdash:theme` | theme toggle | last explicit theme choice |
| `cryptdash:ghcache:v1` | repo view | cached GitHub API responses (10 min) |
| `cryptdash:wx:v1` | weather | cached Open-Meteo reading (15 min) |
| `cryptdash:auth:v1` | Google sign-in | profile + access/refresh tokens |
| `cryptdash:ai:v1` | settings | Gemini model + API key |
| `cryptdash:env:v1` | settings | local override of OAuth client id/secret |
| `cryptdash:drive:auto` | account menu | auto-backup flag (`"1"`/`"0"`) |

## Ways to configure

1. **In-app** — gear icon opens the Admin panel.
2. **Import/export** — the export button writes `crypt-dashboard-*.json`; import
   reads one back. This is the supported way to move state across browsers.
3. **Drive backup** — see [DRIVE-BACKUP.md](DRIVE-BACKUP.md).
4. **Edit defaults** — change `defaultState()` in the HTML to ship different
   defaults (this is code, not user config).

## Search bangs

Default: `!g !gh !yt !w !ddg !repo !hn !so !mdn !npm !r !maps !gpt !cl !pp`.
A bang with a query routes to that site's search; a bare bang opens its home.
Type a bare domain to navigate; otherwise the query goes to `settings.search.url`.
