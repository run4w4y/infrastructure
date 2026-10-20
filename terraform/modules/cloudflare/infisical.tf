variable "infisical_host" {
  description = "Infisical API host."
  type        = string
  default     = "https://app.infisical.com"
}

variable "infisical_project_id" {
  description = "Existing Infisical project that receives the operator Access credentials."
  type        = string
}

variable "infisical_env_slug" {
  description = "Existing Infisical environment that receives the operator Access credentials."
  type        = string
  default     = "prod"
}

variable "ci_secret_targets" {
  description = "Dedicated Infisical project, environment, and folder for each repository's CI credentials."
  type = map(object({
    project_id       = string
    environment_slug = string
    folder_path      = string
  }))

  validation {
    condition     = toset(keys(var.ci_secret_targets)) == toset(["infrastructure", "cv"])
    error_message = "ci_secret_targets must contain exactly infrastructure and cv."
  }
}

provider "infisical" {
  host = var.infisical_host
}

resource "infisical_secret" "access_client_id" {
  for_each = local.service_clients

  name         = "CF_ACCESS_CLIENT_ID"
  value        = cloudflare_zero_trust_access_service_token.client[each.key].client_id
  workspace_id = each.value.secret_target.project_id
  env_slug     = each.value.secret_target.environment_slug
  folder_path  = each.value.secret_target.folder_path

  metadata = {
    managed_by = "terraform"
    source     = "terraform/modules/cloudflare"
    client     = each.key
  }
}

resource "infisical_secret" "access_client_secret" {
  for_each = local.service_clients

  name         = "CF_ACCESS_CLIENT_SECRET"
  value        = cloudflare_zero_trust_access_service_token.client[each.key].client_secret
  workspace_id = each.value.secret_target.project_id
  env_slug     = each.value.secret_target.environment_slug
  folder_path  = each.value.secret_target.folder_path

  metadata = {
    managed_by = "terraform"
    source     = "terraform/modules/cloudflare"
    client     = each.key
  }
}
