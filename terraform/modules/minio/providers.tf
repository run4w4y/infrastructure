terraform {
  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = "3.3.0"
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

provider "vault" {
  address = var.vault_address
}

variable "minio_address" {
  type = string
}

variable "minio_use_ssl" {
  type    = bool
  default = true
}

provider "minio" {
  minio_server   = var.minio_address
  minio_user     = jsondecode(data.vault_kv_secret_v2.minio_secret.data_json).username
  minio_password = jsondecode(data.vault_kv_secret_v2.minio_secret.data_json).password
  minio_region   = "ru-central"
  minio_ssl      = var.minio_use_ssl
}
