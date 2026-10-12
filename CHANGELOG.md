# Changelog

All notable changes are documented here. Format loosely follows
[Keep a Changelog](https://keepachangelog.com/); this project uses
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Changed
- **Collapsed to a single GitHub Pages surface.** Removed the Cloudflare Pages /
  Access deploy, the `secure/` surface, and the `cloudflare/` Terraform/scripts.
  The app is now one generic, client-side page; personal data is per-user.
- **Sanitised the repo.** Removed all personal identifiers (GitHub username,
  email, homelab hostnames, LAN IP) from code, defaults, and docs. Shipped
  defaults are generic; personal config is entered in Admin at runtime.

### Added
- **Launcher parity with the reference homescreen** (issues #1–#11): arrow-key
  tile navigation (#1), Netscape bookmarks HTML import (#2), weather city
  search + use-my-location (#3) and a 4-day forecast (#4), set-as-start-page
  helper (#5), favicon caching in Cache Storage (#6), per-tile Show-on-Home with
  Home as an aggregate tab (#7), default search-engine picker (#8), Open-tiles-in
  same/new tab (#9), and the quick "＋ Add site" tile + modal (#10).
- **Fixed the search bar being dead**: `initSearch()` was defined but never
  called, so form submit, bang hint, `/` focus, and type-to-search never ran.
- **Collection & barcode scanner** — a `scan` view that looks a scanned/typed
  UPC up (UPCitemdb through a configurable proxy, TMDB metadata optional) and
  reports `OWNED · server`, `OWNED · physical`, or `NOT OWNED` against a
  Jellyfin snapshot and the user's physical list. Camera scanning via
  `BarcodeDetector`, manual UPC fallback, physical-list add, JSON/CSV export,
  and `collection & scanner` settings in Admin.
- `scripts/jellyfin-inventory.mjs` (`make inventory`) — exports a Jellyfin
  library to a `library.json` snapshot for import.
- `scripts/check.mjs` and `make check` (syntax, secret, and private-host checks).
- Repo documentation set under `docs/`.

## [0.1.0]

### Added
- Zero-build launcher: clock, bang search, keyless weather, categorized tiles,
  drag-to-reorder, theme toggle.
- GitHub repository dashboard with detail modal, filter/sort, optional PAT.
- Google sign-in (Authorization Code + PKCE, client-side) with profile.
- Google Drive backup/restore to `appDataFolder` (manual + auto).
- Gemini "Ask Gemini" panel (bring-your-own key, model fallback).
- Admin panel; export/import JSON.
- GitHub Pages deploy workflow.
- Docs, AGPL-3.0-or-later license, attribution.
