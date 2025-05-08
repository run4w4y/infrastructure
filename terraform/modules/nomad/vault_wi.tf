resource "vault_jwt_auth_backend" "nomad" {
  path         = "jwt-nomad"
  type         = "jwt"
  jwks_url     = local.jwks_url
  default_role = "nomad-workloads"
  bound_issuer = "nomad.workload.identity"
}

resource "vault_policy" "nomad_workloads" {
  name   = "nomad-workloads"
  policy = <<EOF
    path "secret/data/nomad/*" {
      capabilities = ["read"]
    }
  EOF
}

resource "vault_jwt_auth_backend_role" "nomad_workloads" {
  backend         = vault_jwt_auth_backend.nomad[0].path
  role_name       = "nomad-workloads"
  user_claim      = "nomad_job_id"
  bound_audiences = local.audiences
  claim_mappings  = local.claim_mappings
  token_policies  = [vault_policy.nomad_workloads.name]
  ttl             = "15m"
}
