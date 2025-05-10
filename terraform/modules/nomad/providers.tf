terraform {
  required_version = ">= 1.6.0"

  required_providers {
    consul = { source = "hashicorp/consul", version = "2.21.0" }
    nomad  = { source = "hashicorp/nomad", version = "~> 2.5" }
    vault  = { source = "hashicorp/vault", version = "~> 4.0" }
  }
}

variable "nomad_address" {
  type    = string
  default = "http://127.0.0.1:4646"
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
}

provider "consul" {
  address = var.consul_address
}

provider "vault" {
  address = var.vault_address
}
