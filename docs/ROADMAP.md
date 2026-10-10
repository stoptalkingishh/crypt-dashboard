# Roadmap

## Done

- [x] Two static surfaces (`public/`, `secure/`) deployed from one repo
- [x] Launcher: clock, bang search, keyless weather, categorized tiles, drag-reorder, theme
- [x] GitHub repo dashboard (public + token-authenticated) with detail modal
- [x] Admin panel (secure) / settings sheet (public), export/import JSON
- [x] Google sign-in (Authorization Code + PKCE, client-side)
- [x] Drive backup/restore to `appDataFolder`
- [x] Gemini panel (bring-your-own key)
- [x] Deploy workflows (GitHub Pages + Cloudflare Pages) + Terraform + Access
- [x] Docs, checks (`make check`), attribution

## Next

- [ ] **News & media-bias module** — implement the engine on both surfaces
      (spec in [NEWS.md](NEWS.md)): RSS proxy, TF-IDF clustering, bias bar,
      blindspot, framing divergence, Gemini briefings. *Scaffolding exists on the
      public surface only.*
- [ ] Fill placeholders: `SECURE_URL`, `cloudflare/terraform.tfvars`,
      Google OAuth secrets.
- [ ] Publish consent screen to avoid 7-day refresh-token expiry.

## Later / ideas

- [ ] Optional own Cloudflare Worker proxy for private news fetching
- [ ] RSS/search for the launcher itself
- [ ] PWA (installable, offline launcher)
- [ ] Import browser bookmarks → tiles
- [ ] WASM embeddings for higher-quality clustering (heavy download; opt-in)
- [ ] Service-status pings for homelab tiles

## Explicitly not doing

- A backend, database, or server-side rendering.
- Storing anyone's data on infrastructure we control (Drive is the user's).
