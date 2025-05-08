# dns token

resource "consul_acl_token" "dns_token" {
  policies = [consul_acl_policy.dns_policy.name]
  local    = true
}

data "consul_acl_token_secret_id" "dns_token_read" {
  accessor_id = consul_acl_token.dns_token.accessor_id
}

output "consul_acl_token_dns" {
  sensitive = true
  value     = data.consul_acl_token_secret_id.dns_token_read
}

# vault token

resource "consul_acl_token" "vault_token" {
  policies = [consul_acl_policy.vault_policy.name]
  local    = true
}

data "consul_acl_token_secret_id" "vault_token_read" {
  accessor_id = consul_acl_token.vault_token.accessor_id
}

output "consul_acl_token_vault" {
  sensitive = true
  value     = data.consul_acl_token_secret_id.vault_token_read
}

# nomad token

resource "consul_acl_token" "nomad_token" {
  policies = [consul_acl_policy.nomad_policy.name]
  local    = true
}

data "consul_acl_token_secret_id" "nomad_token_read" {
  accessor_id = consul_acl_token.nomad_token.accessor_id
}

output "consul_acl_token_nomad" {
  sensitive = true
  value     = data.consul_acl_token_secret_id.nomad_token_read
}
