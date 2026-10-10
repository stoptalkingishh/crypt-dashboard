variable "cloudflare_account_id" {
  description = "Cloudflare account ID."
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Zone ID for the domain that hosts the secure hostname."
  type        = string
}

variable "pages_project_name" {
  description = "Cloudflare Pages project name for the secure surface."
  type        = string
  default     = "crypt-dashboard-secure"
}

variable "secure_hostname" {
  description = "Full hostname that serves the secure surface, e.g. home.cryptanalyst.dev."
  type        = string
}

variable "build_command" {
  description = "Pages build command (empty = none; static upload)."
  type        = string
  default     = ""
}

variable "build_output_dir" {
  description = "Directory Pages serves. For Git integration use 'secure'."
  type        = string
  default     = "secure"
}

variable "allowed_emails" {
  description = "Exact email addresses allowed through Access. e.g. [\"you@example.com\"]."
  type        = list(string)
  default     = []
}

variable "allowed_email_domains" {
  description = "Email domains allowed through Access, e.g. [\"example.com\"]."
  type        = list(string)
  default     = []
}

variable "require_login_methods" {
  description = "Access login methods required (e.g. OTP, google, github). Empty = none."
  type        = list(string)
  default     = ["otp"]
}

variable "session_duration" {
  description = "Access session duration, e.g. '24h'."
  type        = string
  default     = "24h"
}
