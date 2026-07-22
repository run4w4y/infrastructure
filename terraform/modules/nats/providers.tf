terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.3"
    }
  }
}

variable "vault_address" {
  type    = string
  default = "http://127.0.0.1:8200"
}

provider "random" {}

provider "vault" {
  address = var.vault_address
}
