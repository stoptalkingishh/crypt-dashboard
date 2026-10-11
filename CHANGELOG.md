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
