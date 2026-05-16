variable "infisical_sync_enabled" {
  type        = bool
  description = "Whether to publish Terraform-managed service tokens into Infisical."
  default     = false
}

variable "infisical_host" {
  type        = string
  description = "Infisical API host. Defaults to Infisical Cloud US."
  default     = "https://app.infisical.com"
}

variable "infisical_project_id" {
  type        = string
  description = "Infisical project ID that receives Terraform-managed service tokens."
  default     = ""

  validation {
    condition     = !var.infisical_sync_enabled || length(trimspace(var.infisical_project_id)) > 0
    error_message = "infisical_project_id must be set when infisical_sync_enabled is true."
  }
}

variable "infisical_env_slug" {
  type        = string
  description = "Infisical environment slug that receives Terraform-managed service tokens."
  default     = "prod"
}

variable "infisical_ansible_folder_path" {
  type        = string
  description = "Infisical folder path used by Ansible for this deployment environment."
  default     = "/ansible"

  validation {
    condition     = startswith(var.infisical_ansible_folder_path, "/")
    error_message = "infisical_ansible_folder_path must start with '/'."
  }
}

provider "infisical" {
  host = var.infisical_host
}

resource "infisical_secret" "vault_consul_token" {
  count = var.infisical_sync_enabled ? 1 : 0

  name         = "VAULT_CONSUL_TOKEN"
  value        = data.consul_acl_token_secret_id.vault_token_read.secret_id
  env_slug     = var.infisical_env_slug
  workspace_id = var.infisical_project_id
  folder_path  = var.infisical_ansible_folder_path

  metadata = {
    managed_by = "terraform"
    source     = "terraform/modules/consul"
  }
}

resource "infisical_secret" "nomad_consul_token" {
  count = var.infisical_sync_enabled ? 1 : 0

  name         = "NOMAD_CONSUL_TOKEN"
  value        = data.consul_acl_token_secret_id.nomad_token_read.secret_id
  env_slug     = var.infisical_env_slug
  workspace_id = var.infisical_project_id
  folder_path  = var.infisical_ansible_folder_path

  metadata = {
    managed_by = "terraform"
    source     = "terraform/modules/consul"
  }
}
