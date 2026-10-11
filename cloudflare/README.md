# Secure surface on Cloudflare Pages + Access

This directory configures the **secure** crypt-dashboard surface so it is served from
Cloudflare Pages and reachable **only** after a Cloudflare Access (Zero Trust)
login. GitHub Pages never serves the secure files — see the security note in the
top-level [`README.md`](../README.md).

## Why not GitHub Pages + Access?

GitHub Pages always exposes its artifact at `<user>.github.io` and that origin
does not pass through Cloudflare, so an Access policy cannot protect it.
Cloudflare Pages gives the secure surface its own origin that **only** exists
behind Cloudflare, so Access can gate it with no bypass.

## Quick start (script — recommended)

`setup.sh` provisions everything via the Cloudflare API (no Terraform needed) and
is idempotent. It creates the Pages project, attaches `home.cryptanalyst.dev`,
creates the proxied DNS record, and creates the Access application + policy.

```sh
cp cloudflare/.env.example cloudflare/.env    # add CLOUDFLARE_API_TOKEN
./cloudflare/setup.sh
npx wrangler pages deploy secure --project-name=crypt-dashboard-secure --branch=main
```

Token permissions: Account → **Cloudflare Pages: Edit**, Account → **Access: Apps
and Policies: Edit**, Zone → **DNS: Edit**, Zone → **Zone: Read**.

## Option A — Terraform (reproducible)

```sh
cd cloudflare
cp terraform.tfvars.example terraform.tfvars   # edit it
export CLOUDFLARE_API_TOKEN=...                # Pages:Edit + Access:Edit + DNS:Edit
terraform init
terraform plan
terraform apply
```

`main.tf` creates:

- a `cloudflare_pages_project` (`crypt-dashboard-secure`, output dir `secure`),
- a proxied `CNAME` + `cloudflare_pages_domain` for `secure_hostname`,
- a `cloudflare_access_application` for the hostname,
- a `cloudflare_access_policy` allowing your email(s)/domain, requiring a login
  method (OTP by default — add Google/GitHub SSO in Zero Trust → Settings →
  Authentication).

If you prefer to manage Access in the dashboard, comment out the Access resources
and create the application there.

## Option B — Dashboard

1. **Zero Trust → Settings → Authentication** — enable an identity provider
   (email OTP is enough to start).
2. **Workers & Pages → Create → Pages → Connect to Git** → pick
   `stoptalkingishh/crypt-dashboard`. Set **Build output directory** to `secure`,
   build command empty.
3. **Custom domains → Set up a custom domain** → `home.cryptanalyst.dev`.
4. **Zero Trust → Access → Applications → Add an application → Self-hosted**.
   Application domain = `home.cryptanalyst.dev`, session duration `24h`.
   Policy → Allow → Include → Emails = your address. Require → Login method → OTP.

## CI deploy (no dashboard build needed)

`.github/workflows/deploy-secure.yml` uploads `secure/` directly with Wrangler.
Add repository secrets:

| Secret | Value |
|---|---|
| `CLOUDFLARE_API_TOKEN` | API token with **Cloudflare Pages:Edit** |
| `CLOUDFLARE_ACCOUNT_ID` | your account ID |

Then every push to `main` publishes the secure surface; Access still gates it.

## Verify

```sh
# Should return the Access login (302 to cloudflareaccess.com), NOT the app.
curl -sSI https://home.cryptanalyst.dev | head -n 5

# After authenticating in a browser, the secure launcher loads.
```

## Point the public page at the secure URL

Edit `const SECURE_URL` near the top of `public/index.html`:

```js
const SECURE_URL = "https://home.cryptanalyst.dev";
```

This is already set for `cryptanalyst.dev`. If you change the secure hostname,
update it here and in `docs/GOOGLE-OAUTH.md` (redirect URI).

## Alternative: Cloudflare Tunnel

If you would rather not move the secure surface to Pages, you can instead host it
from the homelab through your existing `cloudflared` tunnel (see
`homelab/docs/CLOUDFLARE.md`) and gate that hostname with Access. The trade-off is
that the secure files would then live on your server rather than in this repo.
