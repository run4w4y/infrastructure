# consul + vault integration

variable "consul_address" {
  type    = string
  default = "127.0.0.1:8500"
}

variable "consul_vault_token" {
  type        = string
  description = "Token to be used for Vault+Consul integration"
  sensitive   = true
}

# TODO: maybe a bootstrap right here is desired?
resource "vault_consul_secret_backend" "config" {
  path    = "consul"
  address = var.consul_address
  token   = var.consul_vault_token
}
