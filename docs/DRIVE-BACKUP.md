# Google Drive backup

Sign in and the app can store your entire configuration as a single file,
`crypt-dashboard.json`, in the **hidden app-data folder** of *your own* Google Drive.
No server is involved; the browser talks to `www.googleapis.com/drive/v3`
directly.

- Scope: `https://www.googleapis.com/auth/drive.appdata`
- Location: `appDataFolder` — a hidden, per-app area. Only this app can see it;
  it does not appear in the normal My Drive view.
- File: `crypt-dashboard.json` (the full [state object](CONFIGURATION.md)).

## Operations

| Action | Where | API call |
|---|---|---|
| Back up | account menu / admin → "back up" | `files.list` (find) then `files.create` or `files.update` (multipart) |
| Restore | account menu / admin → "restore" | `files.get?alt=media` |
| Auto | account menu checkbox | on each `saveState()`, debounced 2.5 s → update |

Find:

```
GET /drive/v3/files?spaces=appDataFolder&q=name='crypt-dashboard.json' and trashed=false
```

Create (first time) uses metadata `parents: ["appDataFolder"]`; subsequent saves
`PATCH /upload/drive/v3/files/{id}?uploadType=multipart`.

Restore runs the file through `migrate()` (secure) / `loadStateFromText()`
(public) before replacing state, so older exports don't break the current shape.

## Caveats

- The refresh token in `localStorage` is a long-lived credential for the
  `drive.appdata` scope only. See [SECURITY-MODEL.md](SECURITY-MODEL.md).
- Backup is per-Google-account: a different sign-in sees a different app folder.
- The public and secure surfaces share the same Drive file *if* you sign into the
  same Google account on both — handy for moving config between hosts.
- Restoring overwrites local state for the current surface.
