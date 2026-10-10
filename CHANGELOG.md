# Changelog

All notable changes are documented here. Format loosely follows
[Keep a Changelog](https://keepachangelog.com/); this project uses
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- News & media-bias module **scaffolding** on the public surface only (tab, CSS,
  `settings.news` defaults). Engine not yet implemented — see docs/NEWS.md.
- `scripts/check.mjs` and `make check` (syntax, secret, hygiene checks).
- Repo documentation set under `docs/`.

## [0.1.0]

### Added
- Zero-build launcher: clock, bang search, keyless weather, categorized tiles,
  drag-to-reorder, theme toggle.
- GitHub repository dashboard with detail modal, filter/sort, optional PAT.
- Google sign-in (Authorization Code + PKCE, client-side) with profile.
- Google Drive backup/restore to `appDataFolder` (manual + auto).
- Gemini "Ask Gemini" panel (bring-your-own key, model fallback).
- Admin panel (secure) / settings sheet (public); export/import JSON.
- Two deploy targets from one repo: GitHub Pages (`public/`) and Cloudflare
  Pages (`secure/`) gated by Cloudflare Access.
- Cloudflare Terraform (Pages project/domain + Access application/policy).
- Docs, AGPL-3.0-or-later license, attribution.
