# Monitoring integration

How monitoring (Checkmk, Grafana) relates to the dashboard, and the decision
record for going deeper.

**Decision:** link-out tiles now (Option A); an integrated Monitor tab is
**PoC-gated** (Option B) — we build it only after a browser test proves the
static page can actually talk to Checkmk. If the proof fails, we stay on A:
the "no backend" constraint means there is no proxy to route around it.

## Option A — launcher tiles (works today, zero code)

1. Admin → your category → add a tile for the Checkmk web UI
   (`https://<checkmk-host>/<site>`) and/or Grafana.
2. Use the **Open tiles in** setting if you want them in new tabs.

Nothing in this repo changes; tiles are per-user state in the browser, so the
shipped defaults stay generic.

**Why not an iframe instead?** The dashboard is served over HTTPS from a
public host while Checkmk/Grafana usually live on plain-HTTP LAN addresses —
browsers block that as mixed content, and both products send frame-blocking
headers anyway. Dead end; don't pursue embeds.

## Option B — Monitor tab (planned, gated)

A `monitor` view following the same pattern as the GitHub dashboard: a new
category type whose view renders status cards (hosts up/down, problem
services, availability) fetched from the **Checkmk REST API**
(`/check_mk/api/1.0/`), configured per-user in Admin:

| Setting | Value |
|---|---|
| URL | `https://<checkmk-host>/<site>` |
| User | a dedicated automation user |
| Secret | that user's automation secret (stored in localStorage like the GitHub PAT) |

### Security model (matches SECURITY-MODEL.md)

- Create a **read-only automation user**: copy the `no_permissions` role and
  add only read permissions, or use the `guest` role ("sees everything,
  changes nothing"). A leaked token must not be able to alter monitoring.
- HTTPS only — Bearer secrets must never cross plain HTTP.
- Same BYO-token posture as the GitHub PAT: token lives in the user's own
  browser/Drive, never in the repo.

### The gate: prove the browser can reach Checkmk

Cross-origin calls to Checkmk are **not officially supported** — its Apache
does not answer CORS preflights by default, and Bearer auth always triggers a
preflight. Chrome adds **Private Network Access** requirements for a public
page calling a LAN host. All of this must pass *before* any view code is
written.

**1. Checkmk-side headers** (site-local Apache config, e.g.
`~/etc/apache/conf.d/cors.conf` of the OMD site — paths vary by version):

```apache
Header always set Access-Control-Allow-Origin "https://<your-pages-origin>"
Header always set Access-Control-Allow-Headers "Authorization, Accept, Content-Type"
Header always set Access-Control-Allow-Methods "GET, OPTIONS"
Header always set Access-Control-Allow-Private-Network "true"
```

**2. Preflight check with curl** (expect `2xx` + the CORS headers echoed):

```sh
curl -i -X OPTIONS \
  -H "Origin: https://<your-pages-origin>" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: authorization" \
  "https://<checkmk-host>/<site>/check_mk/api/1.0/domain-types/host/collections/all"
```

**3. Browser check** — paste into the DevTools console of the *deployed
dashboard* (the origin matters):

```js
fetch("https://<checkmk-host>/<site>/check_mk/api/1.0/domain-types/host/collections/all", {
  headers: { Authorization: "Bearer <automation-user> <secret>", Accept: "application/json" }
}).then(r => r.json()).then(console.log).catch(console.error);
```

**Pass** = JSON host list in the console. **Fail** = CORS/PNA error → stop;
Option A remains the answer (forum reports suggest failure is common, so treat
this as a genuine test, not a formality).

### Reachability beyond the LAN

Off-LAN the private hostname is unreachable. If needed, publish Checkmk via a
Cloudflare tunnel on the existing zone as a private, Access-gated hostname —
the browser then holds an Access service token alongside the Checkmk secret
(same trust boundary as existing tokens). This is a follow-up decision, not a
prerequisite: the PoC runs on the LAN first.

## Why no proxy

A relay (Cloudflare Worker, small service) would trivially solve CORS — and is
explicitly out of scope: this project has **no backend** (see AGENTS.md). CORS
is solved on the Checkmk side or not at all.
