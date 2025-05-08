terraform {
  required_providers {
    consul = {
      source  = "hashicorp/consul"
      version = "2.21.0"
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

# # enable a jwt auth method for nomad workload identities
# resource "consul_acl_auth_method" "nomad_workloads" {
#   name = "nomad-workloads"
#   type = "jwt"
#   config_json = jsonencode({
#     BoundAudiences = ["consul.io"]
#     ClaimMappings = {
#       nomad_job_id    = "nomad_job_id",
#       nomad_namespace = "nomad_namespace",
#       nomad_service   = "nomad_service",
#       nomad_task      = "nomad_task"
#     }
#     JWKSURL          = "http://127.0.0.1:4646/.well-known/jwks.json"
#     JWTSupportedAlgs = ["RS256"]
#   })
# }

# # create an acl binding rule for nomad services
# resource "consul_acl_binding_rule" "nomad_workloads_binding_rule" {
#   auth_method = consul_acl_auth_method.nomad_workloads.name
#   bind_type   = "service"
#   bind_name   = "$${value.nomad_service}"
#   selector    = "\"nomad_service\" in value"
# }
