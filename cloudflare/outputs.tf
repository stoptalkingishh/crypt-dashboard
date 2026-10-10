output "pages_project" {
  value       = cloudflare_pages_project.secure.name
  description = "Cloudflare Pages project serving the secure surface."
}

output "secure_url" {
  value       = "https://${var.secure_hostname}"
  description = "Access-gated URL for the secure crypt-dashboard."
}

output "access_application_id" {
  value       = cloudflare_access_application.secure.id
  description = "Cloudflare Access application ID."
}
