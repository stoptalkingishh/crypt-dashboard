#!/usr/bin/env bash
#
# Provision the SECURE Crypt Dashboard surface on Cloudflare:
#   - Cloudflare Pages project (crypt-dashboard-secure)
#   - custom domain home.cryptanalyst.dev (+ proxied CNAME)
#   - Access application + policy allowing the configured email(s)
#
# Idempotent: safe to re-run. It does NOT delete anything.
#
# Token (in cloudflare/.env or the environment) needs:
#   Account -> Cloudflare Pages: Edit
#   Account -> Access: Apps and Policies: Edit
#   Zone    -> DNS: Edit
#   Zone    -> Zone: Read
#
# Usage:  ./cloudflare/setup.sh
#
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
# Load local, git-ignored config if present.
if [ -f "$HERE/.env" ]; then set -a; . "$HERE/.env"; set +a; fi

API="https://api.cloudflare.com/client/v4"
: "${CLOUDFLARE_API_TOKEN:?set CLOUDFLARE_API_TOKEN (or create cloudflare/.env)}"

ACCOUNT_ID="${CLOUDFLARE_ACCOUNT_ID:?set CLOUDFLARE_ACCOUNT_ID (Account ID)}"
ZONE_ID="${CLOUDFLARE_ZONE_ID:?set CLOUDFLARE_ZONE_ID (Zone ID)}"
PROJECT="${PAGES_PROJECT:-crypt-dashboard-secure}"
HOSTNAME="${SECURE_HOSTNAME:-home.cryptanalyst.dev}"
SESSION="${SESSION_DURATION:-24h}"
EMAILS="${ACCESS_ALLOWED_EMAILS:?set ACCESS_ALLOWED_EMAILS to the comma-separated allow-list}"

api() { # api METHOD PATH [JSON_BODY]  -> prints JSON response
  local method="$1" path="$2" body="${3:-}"
  if [ -n "$body" ]; then
    curl -sS -X "$method" "${API}${path}" \
      -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
      -H "Content-Type: application/json" --data "$body"
  else
    curl -sS -X "$method" "${API}${path}" \
      -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
      -H "Content-Type: application/json"
  fi
}
jget() { python3 -c "import sys,json;d=json.load(sys.stdin);print($1)"; }
ok_or_die() { # ok_or_die JSON STEP
  if [ "$(printf '%s' "$1" | jget "d.get('success')")" != "True" ]; then
    echo "✗ $2 failed:"; printf '%s' "$1" | python3 -m json.tool 2>/dev/null | head -20; exit 1
  fi
}

echo "account=$ACCOUNT_ID"
echo "zone=$ZONE_ID"
echo "project=$PROJECT"
echo "hostname=$HOSTNAME"
echo "emails=$EMAILS"
echo

# 1. Pages project ----------------------------------------------------------
if [ "$(api GET "/accounts/${ACCOUNT_ID}/pages/projects/${PROJECT}" | jget "bool(d.get('success') and d.get('result'))")" = "True" ]; then
  echo "✓ Pages project exists: $PROJECT"
else
  resp=$(api POST "/accounts/${ACCOUNT_ID}/pages/projects" "{\"name\":\"${PROJECT}\",\"production_branch\":\"main\"}")
  ok_or_die "$resp" "create Pages project"
  echo "✓ Created Pages project: $PROJECT"
fi

# 2. Pages custom domain ----------------------------------------------------
domains=$(api GET "/accounts/${ACCOUNT_ID}/pages/projects/${PROJECT}/domains")
if [ "$(printf '%s' "$domains" | jget "any(x.get('name')=='${HOSTNAME}' for x in (d.get('result') or []))")" = "True" ]; then
  echo "✓ Pages domain attached: $HOSTNAME"
else
  resp=$(api POST "/accounts/${ACCOUNT_ID}/pages/projects/${PROJECT}/domains" "{\"name\":\"${HOSTNAME}\"}")
  ok_or_die "$resp" "attach Pages domain"
  echo "✓ Attached Pages domain: $HOSTNAME"
fi

# 3. DNS CNAME (proxied) ----------------------------------------------------
recs=$(api GET "/zones/${ZONE_ID}/dns_records?name=${HOSTNAME}")
if [ "$(printf '%s' "$recs" | jget "len(d.get('result') or [])")" != "0" ]; then
  echo "✓ DNS record exists for $HOSTNAME"
else
  resp=$(api POST "/zones/${ZONE_ID}/dns_records" "{\"type\":\"CNAME\",\"name\":\"${HOSTNAME}\",\"content\":\"${PROJECT}.pages.dev\",\"proxied\":true}")
  ok_or_die "$resp" "create DNS record"
  echo "✓ Created DNS CNAME: $HOSTNAME -> ${PROJECT}.pages.dev"
fi

# 4. Access application -----------------------------------------------------
apps=$(api GET "/accounts/${ACCOUNT_ID}/access/apps")
app_id=$(printf '%s' "$apps" | python3 -c "import sys,json;d=json.load(sys.stdin);print(next((a['id'] for a in (d.get('result') or []) if a.get('domain')=='${HOSTNAME}'),''))")
if [ -n "$app_id" ]; then
  echo "✓ Access app exists: $app_id"
else
  resp=$(api POST "/accounts/${ACCOUNT_ID}/access/apps" "{\"name\":\"crypt-dashboard secure\",\"domain\":\"${HOSTNAME}\",\"type\":\"self_hosted\",\"session_duration\":\"${SESSION}\"}")
  ok_or_die "$resp" "create Access app"
  app_id=$(printf '%s' "$resp" | jget "d['result']['id']")
  echo "✓ Created Access app: $app_id"
fi

# 5. Access policy ----------------------------------------------------------
pols=$(api GET "/accounts/${ACCOUNT_ID}/access/apps/${app_id}/policies")
if [ "$(printf '%s' "$pols" | jget "len(d.get('result') or [])")" != "0" ]; then
  echo "✓ Access policy exists"
else
  email_json=$(python3 -c "import json;print(json.dumps([{'email':{'email':e.strip()}} for e in '${EMAILS}'.split(',') if e.strip()]))")
  resp=$(api POST "/accounts/${ACCOUNT_ID}/access/apps/${app_id}/policies" "{\"name\":\"allow owners\",\"decision\":\"allow\",\"include\":${email_json}}")
  ok_or_die "$resp" "create Access policy"
  echo "✓ Created Access policy (allow ${EMAILS})"
fi

echo
echo "Done. Secure surface will be live at https://${HOSTNAME} once secure/ is deployed:"
echo "  npx wrangler pages deploy secure --project-name=${PROJECT} --branch=main"
