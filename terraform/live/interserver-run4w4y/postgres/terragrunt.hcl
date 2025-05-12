terraform {
  source = "../../../modules/postgres"
}

inputs = {
  vault_address = get_env("VAULT_ADDR")
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
