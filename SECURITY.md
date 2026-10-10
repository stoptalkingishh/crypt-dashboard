# Security Policy

## Reporting a vulnerability

Please report suspected vulnerabilities privately via GitHub's
**Security → Report a vulnerability** (private advisory) on the repository, or by
email to the maintainer listed on the GitHub profile. Do not open a public issue
for anything exploitable.

Include: affected surface (`public/` or `secure/`), steps to reproduce, and impact.

## Scope

This project is a static, client-side app. There is no server, database, or API of
our own. The full model — assets, threats, and hardening — is in
[docs/SECURITY-MODEL.md](docs/SECURITY-MODEL.md).

In scope: XSS within the app, token handling, secret leakage into the public
surface or git, Cloudflare/Pages misconfiguration shipped in this repo.

Out of scope: the security of Google, GitHub, Cloudflare, Open-Meteo, or any
third-party CORS proxy; the operator's own OAuth/GitHub/AI credentials.
