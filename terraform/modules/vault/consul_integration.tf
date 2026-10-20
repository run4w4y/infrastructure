# consul + vault integration

variable "cluster_ca_pem" {
  type        = string
  description = "Public cluster CA used by Vault to verify the native Consul API."
}

variable "consul_vault_token" {
  type        = string
  description = "Token to be used for Vault+Consul integration"
  sensitive   = true
}

# TODO: maybe a bootstrap right here is desired?
resource "vault_consul_secret_backend" "config" {
  path    = "consul"
  address = "consul.service.consul:8501"
  scheme  = "https"
  ca_cert = var.cluster_ca_pem
  token   = var.consul_vault_token
}
