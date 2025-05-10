resource "vault_jwt_auth_backend" "nomad" {
  path               = "jwt-nomad"
  type               = "jwt"
  jwks_url           = "http://nomad-servers.service.consul:4646/.well-known/jwks.json"
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
