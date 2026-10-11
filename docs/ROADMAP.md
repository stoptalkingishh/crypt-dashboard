# Roadmap

## Done

- [x] Single static surface (`public/`) deployed to GitHub Pages
- [x] Launcher: clock, bang search, keyless weather, categorized tiles, drag-reorder, theme
- [x] GitHub repo dashboard (public + token-authenticated) with detail modal
- [x] Admin panel + export/import JSON
- [x] Google sign-in (Authorization Code + PKCE, client-side)
- [x] Drive backup/restore to `appDataFolder`
- [x] Gemini panel (bring-your-own key)
- [x] Deploy workflow (GitHub Pages)
- [x] Docs, checks (`make check`), attribution

## Next

- [ ] **News & media-bias module** — implement per [NEWS.md](NEWS.md): RSS proxy,
      TF-IDF clustering, bias bar, blindspot, framing divergence, Gemini briefings.
- [ ] Google OAuth: create the client, set repo secrets
      `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET`, add the redirect URI.
- [ ] Publish the Google consent screen (avoids 7-day refresh-token expiry).

## Later / ideas

- [ ] Optional own proxy for private news fetching
- [ ] RSS/search for the launcher itself
- [ ] PWA (installable, offline launcher)
- [ ] Import browser bookmarks → tiles
- [ ] WASM embeddings for higher-quality clustering (heavy download; opt-in)

## Explicitly not doing

- A backend, database, or server-side rendering.
- Storing anyone's data on infrastructure we control (Drive is the user's).
