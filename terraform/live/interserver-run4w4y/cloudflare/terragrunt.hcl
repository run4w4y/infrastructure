terraform {
  source = "../../../modules/cloudflare"
}

inputs = {
  vault_address         = get_env("VAULT_ADDR")
  domain_name           = get_env("DOMAIN_NAME")
  cloudflare_account_id = get_env("CF_ACCOUNT_ID")
  cloudflare_api_token  = get_env("CF_API_TOKEN")
  porkbun_api_key       = get_env("PB_API_KEY")
  porkbun_secret_key    = get_env("PB_SECRET_KEY")
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
