terraform {
  required_version = ">= 1.6.0"

  required_providers {
    infisical = { source = "Infisical/infisical", version = "0.16.24" }
    consul    = { source = "hashicorp/consul", version = "2.21.0" }
    nomad     = { source = "hashicorp/nomad", version = "~> 2.5" }
    vault     = { source = "hashicorp/vault", version = "~> 4.0" }
  }
}

variable "nomad_address" {
  type    = string
  default = "http://127.0.0.1:4646"
}

variable "cluster_ca_pem" {
  description = "Public CA certificate used to verify Nomad workload identity signing-key discovery."
  type        = string
}

variable "consul_address" {
  type    = string
  default = "127.0.0.1:8500"
}

variable "vault_address" {
  type    = string
  default = "http://127.0.0.1:8200"
}

provider "nomad" {
  address = var.nomad_address

  dynamic "headers" {
    for_each = var.cloudflare_access_headers

    content {
      name  = headers.key
      value = headers.value
    }
  }
}

provider "consul" {
  address = var.consul_address

  dynamic "header" {
    for_each = var.cloudflare_access_headers

    content {
      name  = header.key
      value = header.value
    }
  }
}

provider "vault" {
  address = var.vault_address

  dynamic "headers" {
    for_each = var.cloudflare_access_headers

    content {
      name  = headers.key
      value = headers.value
    }
  }
}
