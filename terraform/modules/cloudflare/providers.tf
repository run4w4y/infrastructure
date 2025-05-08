terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.4"
    }

    porkbun = {
      source  = "marcfrederick/porkbun"
      version = "~> 1.2"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.3"
    }
  }
}

provider "vault" {
  address = var.vault_address
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "porkbun" {
  api_key        = var.porkbun_api_key
  secret_api_key = var.porkbun_secret_key
}

