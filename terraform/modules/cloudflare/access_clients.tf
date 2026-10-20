locals {
  service_clients = {
    infrastructure = {
      name          = "Infrastructure CI ${var.domain_name}"
      applications  = toset(["nomad"])
      secret_target = var.ci_secret_targets["infrastructure"]
    }
    cv = {
      name          = "CV CI ${var.domain_name}"
      applications  = toset(["nomad"])
      secret_target = var.ci_secret_targets["cv"]
    }
    operator = {
      name         = "Terraform operator ${var.domain_name}"
      applications = local.admin_services
      secret_target = {
        project_id       = var.infisical_project_id
        environment_slug = var.infisical_env_slug
        folder_path      = "/terraform"
      }
    }
  }

  application_service_clients = {
    for application in local.admin_services : application => sort([
      for name, client in local.service_clients : name
      if contains(client.applications, application)
    ])
  }
}

resource "cloudflare_zero_trust_access_service_token" "client" {
  for_each = local.service_clients

  account_id = var.cloudflare_account_id
  name       = each.value.name
  duration   = "8760h"

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_zero_trust_access_policy" "service_client" {
  for_each = local.service_clients

  account_id = var.cloudflare_account_id
  name       = each.value.name
  decision   = "non_identity"

  include = [{
    service_token = {
      token_id = cloudflare_zero_trust_access_service_token.client[each.key].id
    }
  }]
}
