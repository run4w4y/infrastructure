terraform {
  source = "../../../modules/postgres"
}

inputs = {
  vault_address = get_env("VAULT_ADDR")
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
      name    = "interserver-run4w4y-postgres"
    }
  }
}
EOF
}
