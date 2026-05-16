resource "infisical_secret_folder" "terraform" {
  project_id       = var.infisical_project_id
  environment_slug = var.environment_slug
  folder_path      = local.folders[local.terraform_path].parent_path
  name             = local.folders[local.terraform_path].name
  description      = local.folders[local.terraform_path].description
  force_delete     = false

  lifecycle {
    prevent_destroy = true
  }
}

resource "infisical_secret_folder" "ansible" {
  project_id       = var.infisical_project_id
  environment_slug = var.environment_slug
  folder_path      = local.folders[local.ansible_path].parent_path
  name             = local.folders[local.ansible_path].name
  description      = local.folders[local.ansible_path].description
  force_delete     = false

  lifecycle {
    prevent_destroy = true
  }
}
