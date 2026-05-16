terraform {
  source = "../../../modules/minio"
}

inputs = {
  vault_address = get_env("VAULT_ADDR")
  minio_address = "s3.${get_env("DOMAIN_NAME")}"
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
      name    = "interserver-run4w4y-minio"
    }
  }
}
EOF
}
