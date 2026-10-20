variable "infisical_host" {
  description = "Infisical API host used to publish CI deployment credentials."
  type        = string
  default     = "https://app.infisical.com"
}

variable "ci_secret_targets" {
  description = "Dedicated Infisical project and secret location for each CI repository."
  type = map(object({
    project_id       = string
    environment_slug = string
    folder_path      = string
  }))
  default = {}

  validation {
    condition = (
      length(var.ci_secret_targets) == 0 ||
      toset(keys(var.ci_secret_targets)) == toset(["infrastructure", "cv"])
    )
    error_message = "CI secret targets must be empty or contain both infrastructure and cv."
  }

  validation {
    condition = alltrue([
      for target in values(var.ci_secret_targets) :
      length(trimspace(target.project_id)) > 0 &&
      length(trimspace(target.environment_slug)) > 0 &&
      startswith(target.folder_path, "/")
    ])
    error_message = "CI secret targets require a project ID, environment slug, and absolute folder path."
  }

  validation {
    condition = (
      length(distinct([for target in values(var.ci_secret_targets) : target.project_id])) ==
      length(var.ci_secret_targets)
    )
    error_message = "Each CI repository must use a distinct Infisical project."
  }
}

provider "infisical" {
  host = var.infisical_host
}

resource "infisical_secret" "ci_nomad_token" {
  for_each = var.ci_secret_targets

  name         = "NOMAD_TOKEN"
  value        = nomad_acl_token.ci_repository[each.key].secret_id
  env_slug     = each.value.environment_slug
  workspace_id = each.value.project_id
  folder_path  = each.value.folder_path

  metadata = {
    managed_by = "terraform"
    source     = "terraform/modules/nomad"
    repository = each.key
  }
}
