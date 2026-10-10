/*
 * Cloudflare configuration for the SECURE crypt-dashboard surface.
 *
 * Creates (or adopts) a Cloudflare Pages project, attaches a custom domain, and
 * puts a Cloudflare Access (Zero Trust) application + policy in front of it so
 * only allowed identities can reach the secure launcher.
 *
 * Provider: cloudflare/cloudflare ~> 4.40 (see provider.tf).
 * For provider v5, rename:
 *   cloudflare_access_application -> cloudflare_zero_trust_access_application
 *   cloudflare_access_policy      -> cloudflare_zero_trust_access_policy
 */

# --- Pages project (comment out if you created it in the dashboard) ----------
resource "cloudflare_pages_project" "secure" {
  account_id        = var.cloudflare_account_id
  name              = var.pages_project_name
  production_branch = "main"

  # The secure surface is a plain static directory (no build step).
  # When using Git integration, set the build output directory instead.
  build_config {
    build_command   = var.build_command
    destination_dir = var.build_output_dir
  }

  lifecycle {
    # The GitHub Action (deploy-secure.yml) or dashboard may manage builds.
    ignore_changes = [build_config, source]
  }
}

# --- DNS + custom domain -----------------------------------------------------
# CNAME the secure hostname at the Pages project, then register it with Pages.
resource "cloudflare_record" "secure" {
  zone_id = var.cloudflare_zone_id
  name    = var.secure_hostname
  type    = "CNAME"
  value   = "${var.pages_project_name}.pages.dev"
  proxied = true
}

resource "cloudflare_pages_domain" "secure" {
  account_id   = var.cloudflare_account_id
  project_name = cloudflare_pages_project.secure.name
  domain       = var.secure_hostname
  depends_on   = [cloudflare_record.secure]
}

# --- Cloudflare Access (Zero Trust) -----------------------------------------
resource "cloudflare_access_application" "secure" {
  account_id       = var.cloudflare_account_id
  name             = "crypt-dashboard secure"
  domain           = var.secure_hostname
  type             = "self_hosted"
  session_duration = var.session_duration
}

resource "cloudflare_access_policy" "allow" {
  application_id = cloudflare_access_application.secure.id
  zone_id        = var.cloudflare_zone_id
  name           = "allow owners"
  precedence     = 1
  decision       = "allow"

  # Allow by explicit email and/or an email domain (e.g. your own domain).
  include {
    email        = var.allowed_emails
    email_domain = var.allowed_email_domains
  }

  # Require MFA/2FA-capable login for stronger assurance.
  require {
    login_method = var.require_login_methods
  }
}
