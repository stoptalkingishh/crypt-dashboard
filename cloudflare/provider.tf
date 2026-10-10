terraform {
  required_version = ">= 1.5"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.40"
    }
  }
}

provider "cloudflare" {
  # Reads CLOUDFLARE_API_TOKEN from the environment. The token needs:
  #   Account: Cloudflare Pages:Edit, Access: Apps and Policies:Edit
  #   Zone:    DNS:Edit (for the record), Access: Apps and Policies:Edit
  # api_token = var.cloudflare_api_token
}
