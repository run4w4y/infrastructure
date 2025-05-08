terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "4.3.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
  }
}

variable "vault_address" {
  type    = string
  default = "127.0.0.1:8200"
}

provider "vault" {
  address = var.vault_address
}

provider "random" {}

provider "tls" {}
