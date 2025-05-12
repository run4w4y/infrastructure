terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "4.3.0"
    }

    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.25.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
  }
}

provider "random" {}

variable "vault_address" {
  type    = string
  default = "127.0.0.1:8200"
}

provider "vault" {
  address = var.vault_address
}

variable "postgres_address" {
  type    = string
  default = "127.0.0.1"
}

variable "postgres_port" {
  type    = string
  default = 5432
}

provider "postgresql" {
  host     = var.postgres_address
  port     = var.postgres_port
  username = jsondecode(data.vault_kv_secret_v2.postgres_secret.data_json).username
  password = jsondecode(data.vault_kv_secret_v2.postgres_secret.data_json).password
  sslmode  = "disable"
}
