locals {
  jwks_url  = "${var.nomad_address}/.well-known/jwks.json"
  audiences = ["consul.io", "vault.io"]
  claim_mappings = {
    nomad_job_id    = "nomad_job_id"
    nomad_namespace = "nomad_namespace"
    nomad_service   = "nomad_service"
    nomad_task      = "nomad_task"
  }
}
