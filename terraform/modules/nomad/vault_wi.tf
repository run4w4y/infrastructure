resource "vault_jwt_auth_backend" "nomad" {
  path               = "jwt-nomad"
  type               = "jwt"
  jwks_url           = "https://nomad-servers.service.consul:4646/.well-known/jwks.json"
  jwks_ca_pem        = var.cluster_ca_pem
  jwt_supported_algs = ["RS256", "EdDSA"]
  default_role       = "nomad-workloads"
}

resource "vault_policy" "nomad_workloads" {
  name   = "nomad-workloads"
  policy = <<EOF
    path "secret/data/nomad/*" {
      capabilities = ["read"]
    }

    path "secret/data/{{identity.entity.aliases.${vault_jwt_auth_backend.nomad.accessor}.metadata.nomad_job_id}}/*" {
      capabilities = ["read"]
    }

    path "secret/metadata/*" {
      capabilities = ["list"]
    }
  EOF
}

resource "vault_jwt_auth_backend_role" "nomad_workloads" {
  backend                 = vault_jwt_auth_backend.nomad.path
  role_name               = "nomad-workloads"
  role_type               = vault_jwt_auth_backend.nomad.type
  user_claim              = "/nomad_job_id"
  user_claim_json_pointer = true
  bound_audiences         = ["vault.io"]
  claim_mappings = {
    nomad_job_id    = "nomad_job_id"
    nomad_namespace = "nomad_namespace"
    nomad_service   = "nomad_service"
    nomad_task      = "nomad_task"
  }
  token_type             = "service"
  token_policies         = [vault_policy.nomad_workloads.name]
  token_period           = 30 * 60 # in seconds
  token_explicit_max_ttl = 0
}

resource "vault_policy" "openviking_server" {
  name   = "openviking-server"
  policy = <<-EOT
    path "secret/data/openviking/server" {
      capabilities = ["read"]
    }
  EOT
}

resource "vault_jwt_auth_backend_role" "openviking_server" {
  backend                 = vault_jwt_auth_backend.nomad.path
  role_name               = "openviking-server"
  role_type               = "jwt"
  user_claim              = "/nomad_job_id"
  user_claim_json_pointer = true
  bound_audiences         = ["vault.io"]
  bound_claims            = { nomad_job_id = "openviking", nomad_namespace = "default" }
  token_type              = "service"
  token_policies          = [vault_policy.openviking_server.name]
  token_period            = 1800
  token_explicit_max_ttl  = 0
}

resource "vault_policy" "paseo_server" {
  name   = "paseo-bootstrap"
  policy = <<-EOT
    path "secret/data/paseo/runtime" {
      capabilities = ["read"]
    }

    path "auth/token/lookup-self" {
      capabilities = ["read"]
    }
    path "auth/token/renew-self" {
      capabilities = ["update"]
    }
    path "auth/token/revoke-self" {
      capabilities = ["update"]
    }
  EOT
}

resource "vault_jwt_auth_backend_role" "paseo_server" {
  backend                 = vault_jwt_auth_backend.nomad.path
  role_name               = "paseo-bootstrap"
  role_type               = "jwt"
  user_claim              = "/nomad_job_id"
  user_claim_json_pointer = true
  bound_audiences         = ["vault.io"]
  bound_claims = {
    nomad_job_id    = "paseo"
    nomad_namespace = "default"
    nomad_task      = "paseo"
  }
  token_policies          = [vault_policy.paseo_server.name]
  token_no_default_policy = true
  token_type              = "service"
  token_period            = 1800
  token_explicit_max_ttl  = 0
}
