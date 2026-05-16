terraform {
  required_providers {
    consul = {
      source  = "hashicorp/consul"
      version = "2.21.0"
    }

    infisical = {
      source  = "Infisical/infisical"
      version = "~> 0.16"
    }
  }
}

variable "consul_address" {
  type    = string
  default = "127.0.0.1:8500"
}

provider "consul" {
  address = var.consul_address
}

module "intetions" {
  source = "./intentions"
}

# enable built-in ca
resource "consul_certificate_authority" "connect" {
  connect_provider = "consul"

  config_json = jsonencode({
    LeafCertTTL         = "24h"
    RotationPeriod      = "2160h"
    IntermediateCertTTL = "8760h"
  })
}
