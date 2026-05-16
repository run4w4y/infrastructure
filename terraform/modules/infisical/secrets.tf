resource "infisical_secret" "this" {
  for_each = local.secrets

  name             = each.value.name
  value_wo         = each.value.value
  value_wo_version = 1
  env_slug         = var.environment_slug
  workspace_id     = var.infisical_project_id
  folder_path      = each.value.folder_path

  metadata = merge(local.common_metadata, {
    description = each.value.description
    kind        = each.value.kind
  })

  depends_on = [
    infisical_secret_folder.terraform,
    infisical_secret_folder.ansible,
  ]

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      value_wo,
      value_wo_version,
    ]
  }
}
