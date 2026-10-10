# Research & upstream inventory

What this project is assembled from, and the alternatives surveyed.

## Fork / adaptation sources (permissive licenses)

| Source | License | Contribution to this repo |
|---|---|---|
| [8tp/startpage](https://github.com/8tp/startpage) | MIT | Zero-build launcher architecture: config-driven groups, `!bang` parser, Open-Meteo weather, theme toggle, staggered entrance |
| [leecorbin/start-page](https://github.com/leecorbin/start-page) | MIT | Single-file omnibox UX (type a URL, bang, or query) |
| [kdippan/github-repository-analyzer](https://github.com/kdippan/github-repository-analyzer) | MIT | Client-side GitHub REST usage, optional token in `localStorage` |
| [debba/gh-dashboard (gitdeck)](https://github.com/debba/gh-dashboard) | MIT | Repository data model — which per-repo fields/views matter |
| [stoptalkingishh/openquiz](https://github.com/stoptalkingishh/openquiz) | AGPL-3.0-or-later | Google PKCE sign-in, Drive persistence, Gemini model-fallback pattern |
| [stoptalkingishh/battle-rhythm](https://github.com/stoptalkingishh/battle-rhythm) | MIT | No-build Google auth + Drive approach, token-proxy ideas |
| [amruth112/CruxNews-OpenNews](https://github.com/amruth112/CruxNews-OpenNews) | MIT | *(news, planned)* browser-side clustering + bias + CORS-proxy architecture |
| [Greg-2600/memory-whole](https://github.com/Greg-2600/memory-whole) | MIT | *(news, planned)* TF-IDF clustering, blindspot/silence, framing divergence |

Because Crypt Dashboard is itself **AGPL-3.0-or-later**, adapting patterns from
openquiz (AGPL) and the MIT sources above is license-compatible. The projects
below were studied for ideas only (no code reused).

## Ground-News alternatives surveyed

| Project | License | Stack | Backend? |
|---|---|---|---|
| `amruth112/CruxNews-OpenNews` | MIT | Vite/React, Transformers.js WASM, MBFC bias | **No** (static + dumb proxy) |
| `grregis/MuckScraper` | (check) | Python/Flask, Postgres+pgvector, Ollama, AllSides | Yes (heavy) |
| `JamesClarke7283/FulcrumNews` | (check) | Quart, LangGraph, SQLite+LanceDB, OpenRouter | Yes |
| `Greg-2600/memory-whole` | MIT | Python, TF-IDF+DBSCAN, SQLite | Yes |
| `peisenh/newsprism`, `moguiyu/NewsPrism` | (check) | RSS pipeline, embeddings, dashboards | Yes |
| `Devanik21/AI-NewsVault` | MIT | sentence-transformers+HDBSCAN, Streamlit | Yes |
| `arm1nt/GNA` | (check) | Angular + Spring Boot + pgvector + RabbitMQ | Yes (enterprise) |
| `gethomepage/homepage` | GPL-3.0 | Next.js, YAML, 100+ widgets | Yes |
| `glanceapp/glance` | AGPL-3.0 | Go single binary, feed widgets | Yes |

`CruxNews-OpenNews` is the closest architectural match (same constraints:
static site + one dumb CORS proxy + local processing + `localStorage` keys).

## Bias data sources

- **AllSides** — 5-point lean (left … right). Public ratings; redistribution
  terms vary — a small derived map is bundled.
- **Media Bias/Fact Check (MBFC)** — lean + factual-reporting ratings.
- **Ad Fontes Media** — bias + reliability chart.
- Datasets/lookups seen: `favstats/AllSideR` (AllSides CSV), HuggingFace
  `mediabiasgroup/BAT`, and an `oanor.com` mediabias API (1 350+ sources) usable
  as an optional runtime lookup.

> Ratings are subjective assessments, not objective truth. The app presents them
> as reading aids.
