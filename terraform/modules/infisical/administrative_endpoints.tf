locals {
  administrative_endpoints = {
    CONSUL_HTTP_ADDR = "https://consul.${var.domain_name}"
    NOMAD_ADDR       = "https://nomad.${var.domain_name}"
    VAULT_ADDR       = "https://vault.${var.domain_name}"
  }
}

moved {
  from = infisical_secret.this["/terraform:CONSUL_HTTP_ADDR"]
  to   = infisical_secret.administrative_endpoint["CONSUL_HTTP_ADDR"]
}

moved {
  from = infisical_secret.this["/terraform:NOMAD_ADDR"]
  to   = infisical_secret.administrative_endpoint["NOMAD_ADDR"]
}

moved {
  from = infisical_secret.this["/terraform:VAULT_ADDR"]
  to   = infisical_secret.administrative_endpoint["VAULT_ADDR"]
}

resource "infisical_secret" "administrative_endpoint" {
  for_each = local.administrative_endpoints

  name         = each.key
  value        = each.value
  env_slug     = var.environment_slug
  workspace_id = var.infisical_project_id
  folder_path  = local.terraform_path

  metadata = merge(local.common_metadata, {
    description = "Public administrative HTTPS endpoint managed by Terraform."
    kind        = "managed-endpoint"
  })

  depends_on = [infisical_secret_folder.terraform]

  lifecycle {
    prevent_destroy = true
  }
}
