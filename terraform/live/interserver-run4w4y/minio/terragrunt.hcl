terraform {
  source = "../../../modules/minio"
}

inputs = {
  vault_address = get_env("VAULT_ADDR")
  minio_address = "s3.${get_env("DOMAIN_NAME")}"
}

remote_state {
  backend = "local"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    path = "${get_terragrunt_dir()}/terraform.tfstate"
  }
}
