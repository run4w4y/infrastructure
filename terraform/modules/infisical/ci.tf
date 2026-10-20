variable "infisical_org_id" {
  type = string
}

variable "cluster_ca_pem" {
  type = string
}

resource "infisical_secret" "cluster_ca" {
  name         = "CLUSTER_CA_BASE64"
  value        = base64encode(var.cluster_ca_pem)
  env_slug     = var.environment_slug
  workspace_id = var.infisical_project_id
  folder_path  = local.terraform_path
}

locals {
  ci_repositories = {
    infrastructure = {
      repository = "run4w4y/infrastructure"
      subject    = "repo:run4w4y/infrastructure:ref:refs/heads/main"
    }
    cv = {
      repository = "run4w4y/cv"
      subject    = "repo:run4w4y/cv:environment:production"
    }
  }
}

resource "infisical_project" "ci" {
  for_each = local.ci_repositories

  name        = "${each.key} deployment"
  slug        = "${each.key}-deployment"
  description = "Deployment credentials for ${each.value.repository}"
}

resource "infisical_identity" "ci" {
  for_each = local.ci_repositories

  name   = "${each.key}-deployment"
  org_id = var.infisical_org_id
  role   = "no-access"
}

resource "infisical_identity_oidc_auth" "ci" {
  for_each = local.ci_repositories

  identity_id        = infisical_identity.ci[each.key].id
  oidc_discovery_url = "https://token.actions.githubusercontent.com"
  bound_issuer       = "https://token.actions.githubusercontent.com"
  bound_audiences    = ["https://github.com/run4w4y"]
  bound_subject      = each.value.subject
  bound_claims = {
    repository = each.value.repository
  }

  access_token_ttl     = 900
  access_token_max_ttl = 900
}

resource "infisical_project_identity" "ci" {
  for_each = local.ci_repositories

  identity_id = infisical_identity.ci[each.key].id
  project_id  = infisical_project.ci[each.key].id
  roles = [{
    role_slug = "viewer"
  }]
}

output "ci_identities" {
  value = { for name, identity in infisical_identity.ci : name => identity.id }
}

output "ci_secret_targets" {
  value = { for name, project in infisical_project.ci : name => {
    project_id       = project.id
    environment_slug = "prod"
    folder_path      = "/"
  } }
}
