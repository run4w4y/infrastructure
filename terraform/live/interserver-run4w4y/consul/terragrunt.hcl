terraform {
  source = "../../../modules/consul"
}

inputs = {
  consul_address = get_env("CONSUL_HTTP_ADDR")
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
