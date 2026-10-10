# Attribution

Crypt Dashboard is an original codebase licensed under **AGPL-3.0-or-later**
(see [LICENSE](LICENSE)). Its design and structure drew on the open-source
projects below, used for **inspiration and patterns**, not copied verbatim.
Full license texts are in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

| Project | License | What informed this build |
|---|---|---|
| [8tp/startpage](https://github.com/8tp/startpage) | MIT | Zero-build launcher: config-driven link groups, `!bang` parser, Open-Meteo weather, theme toggle |
| [leecorbin/start-page](https://github.com/leecorbin/start-page) | MIT | Single-file omnibox search-and-navigate UX |
| [kdippan/github-repository-analyzer](https://github.com/kdippan/github-repository-analyzer) | MIT | Client-side GitHub REST usage, optional token in `localStorage`, analytics |
| [debba/gh-dashboard ("gitdeck")](https://github.com/debba/gh-dashboard) | MIT | Repository data model and useful per-repo fields |
| [stoptalkingishh/openquiz](https://github.com/stoptalkingishh/openquiz) | AGPL-3.0-or-later | Google PKCE sign-in, Drive persistence, Gemini model-fallback pattern |
| [stoptalkingishh/battle-rhythm](https://github.com/stoptalkingishh/battle-rhythm) | MIT | No-build Google auth + Drive approach; token-proxy ideas |
| [amruth112/CruxNews-OpenNews](https://github.com/amruth112/CruxNews-OpenNews) | MIT | *(news, planned)* browser-side clustering + CORS-proxy architecture |
| [Greg-2600/memory-whole](https://github.com/Greg-2600/memory-whole) | MIT | *(news, planned)* TF-IDF clustering, blindspot/framing detection |

Projects **studied for ideas only** (no code reused):

- [gethomepage/homepage](https://github.com/gethomepage/homepage) — GPL-3.0
- [glanceapp/glance](https://github.com/glanceapp/glance) — AGPL-3.0
- [grregis/MuckScraper](https://github.com/grregis/MuckScraper),
  [JamesClarke7283/FulcrumNews](https://github.com/JamesClarke7283/FulcrumNews),
  `peisenh/newsprism`, `Devanik21/AI-NewsVault`, `arm1nt/GNA`

## Third-party runtime services

Google (OAuth, Drive, Gemini), GitHub, Open-Meteo, and Google's favicon service
are called directly by the browser; the planned news module uses an
operator-configurable RSS proxy. None of their code is bundled.
