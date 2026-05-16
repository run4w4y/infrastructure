variable "infisical_host" {
  type        = string
  description = "Infisical API host. Defaults to Infisical Cloud."
  default     = "https://app.infisical.com"
}

variable "infisical_project_id" {
  type        = string
  description = "Infisical project ID whose repository secret shape should be managed."

  validation {
    condition     = length(trimspace(var.infisical_project_id)) > 0
    error_message = "infisical_project_id must be set."
  }
}

variable "environment_slug" {
  type        = string
  description = "Infisical environment slug where the repository secret shape should exist."
  default     = "prod"

  validation {
    condition     = length(trimspace(var.environment_slug)) > 0
    error_message = "environment_slug must not be empty."
  }
}

variable "terraform_folder_name" {
  type        = string
  description = "Root-level Infisical folder name for Terraform runtime secrets."
  default     = "terraform"

  validation {
    condition     = length(trimspace(var.terraform_folder_name)) > 0 && !strcontains(var.terraform_folder_name, "/")
    error_message = "terraform_folder_name must not be empty or contain '/'."
  }
}

variable "ansible_folder_name" {
  type        = string
  description = "Root-level Infisical folder name for Ansible runtime secrets."
  default     = "ansible"

  validation {
    condition     = length(trimspace(var.ansible_folder_name)) > 0 && !strcontains(var.ansible_folder_name, "/")
    error_message = "ansible_folder_name must not be empty or contain '/'."
  }
}
