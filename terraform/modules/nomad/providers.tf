terraform {
  required_version = ">= 1.6.0"

  required_providers {
    consul = { source = "hashicorp/consul", version = "~> 3.0" }
    nomad  = { source = "hashicorp/nomad", version = "~> 2.0" }
    vault  = { source = "hashicorp/vault", version = "~> 4.0" }
  }
}

variable "nomad_address" {
  type    = string
  default = "127.0.0.1:4646"
}

provider "nomad" {
  address = var.nomad_address
}

provider "consul" {}

provider "vault" {}
