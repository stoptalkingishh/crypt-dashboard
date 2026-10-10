# News & media bias (planned)

A Ground-News-style reader that clusters the same story across outlets and shows
balance. **Status: specified, partially scaffolded.** `public/index.html` already
has the `News` tab, its CSS, the `#view-news` section, and `settings.news`
defaults; the engine and the entire secure-side port are **not yet implemented**.
This document is the build spec.

Design is adapted from `amruth112/CruxNews-OpenNews` and `Greg-2600/memory-whole`
(both MIT) — see [RESEARCH.md](RESEARCH.md).

## Decisions

| Question | Decision |
|---|---|
| Clustering | Lightweight: TF-IDF + title-token overlap. No model download. |
| Feed fetching | RSS via a **configurable CORS proxy** (`{url}` placeholder); public default, overridable. |
| v1 scope | Feed + clustering + bias, **blindspot**, **framing divergence**, Gemini summaries. |
| Bias data | **Bundled domain→lean map** by default; optional runtime API override. |

## Why a proxy

Browsers can't fetch arbitrary RSS cross-origin. Every client-side reader routes
feed XML through a stateless fetch helper. The proxy **stores nothing**; it only
relays bytes. Options:

- Public proxy (default): `https://api.allorigins.win/raw?url={url}`.
- Your own (private): a small Cloudflare Worker; paste its URL into `news.proxy`.
- CORS-friendly feeds work without a proxy but are too few for a balanced view.

**Privacy:** a public proxy sees the feed URLs you request. Use your own proxy
for privacy. This is the only non-client piece and it holds no data.

## Pipeline

```
feeds ─▶ fetch(proxy) ─▶ parse RSS/Atom (DOMParser)
      ─▶ resolve lean (bundled map → optional API)
      ─▶ cluster (TF-IDF cosine + shared-title-keywords, within windowHours)
      ─▶ per cluster: bias counts, blindspot, framing divergence
      ─▶ render (bias bar, chips, sample headlines)  ─▶ Gemini briefing on demand
```

### Clustering (lightweight)

1. Tokenise titles: lowercase, drop stopwords + short tokens.
2. Build TF-IDF vectors over the current article set.
3. For each article (newest first), compare to existing cluster members; merge
   when `cosine ≥ clusterThreshold` or (borderline AND ≥ 2 shared keywords) within
   `windowHours`. Mirrors `FulcrumNews`'s "strict OR borderline+keywords" rule.
4. Cluster stats: distinct sources per bucket, representative title (shortest).

### Bias buckets & blindspot

- Buckets: `left` (lean −2/−1), `center` (0), `right` (+1/+2), `other` (unknown/international).
- **Blindspot**: one side has ≥ `blindspotMinSources` distinct sources while the
  other has 0.

### Framing divergence

Lexicon sentiment over headlines (compact positive/negative word sets). Divergence
= `|avg(left) − avg(right)|` when both sides have ≥ 1 article; flagged ≥ 0.25.

## Bias data

- **Bundled** `BIAS_MAP` (domain → −2…+2), AllSides/MBFC-derived, in the JS.
  Unknown domains resolve to `other` and are excluded from blindspot maths.
- **Runtime API** (optional): set `news.biasApi` to a template containing
  `{domain}` (e.g. an `oanor.com`-compatible endpoint). Results are cached in
  `cryptdash:news:bias:v1`.

Bias labels are *starting points for critical reading*, not verdicts.

## Config

See `settings.news` in [CONFIGURATION.md](CONFIGURATION.md): `proxy`, `biasApi`,
`clusterThreshold`, `windowHours`, `blindspotMinSources`, `minSourcesFilter`,
`blindspotsOnly`, `feeds[]`. Feeds are edited as `Name | URL` lines in the panel.

## Summaries

Each story has a `✦ summarize` button that calls `openAiPrefill()` with the
cluster's headlines, reusing the [Gemini](GEMINI.md) panel (BYO key).

## Not doing (yet)

- Editions / scheduled digests.
- Full-text scraping (headlines + summary only, avoids paywalls/ToS issues).
- WASM embeddings (rejected for v1 to avoid a ~23 MB download; revisit later).
