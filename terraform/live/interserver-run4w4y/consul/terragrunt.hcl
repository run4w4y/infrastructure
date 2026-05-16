terraform {
  source = "../../../modules/consul"
}

inputs = {
  consul_address = get_env("CONSUL_HTTP_ADDR")

  infisical_sync_enabled = get_env("INFISICAL_PROJECT_ID", "") != ""
  infisical_host         = get_env("INFISICAL_HOST", "https://app.infisical.com")
  infisical_project_id   = get_env("INFISICAL_PROJECT_ID", "")
  infisical_env_slug     = get_env("INFISICAL_ENV", "prod")
  infisical_ansible_folder_path = get_env(
    "INFISICAL_ANSIBLE_FOLDER_PATH",
    "/ansible"
  )
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"

  contents = <<EOF
terraform {
  cloud {
    organization = "${get_env("TF_CLOUD_ORGANIZATION")}"

    workspaces {
      project = "${get_env("TF_CLOUD_PROJECT")}"
      name    = "interserver-run4w4y-consul"
    }
  }
}
EOF
}
