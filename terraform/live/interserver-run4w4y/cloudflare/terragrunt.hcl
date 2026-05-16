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

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"

  contents = <<EOF
terraform {
  cloud {
    organization = "${get_env("TF_CLOUD_ORGANIZATION")}"

    workspaces {
      project = "${get_env("TF_CLOUD_PROJECT")}"
      name    = "interserver-run4w4y-cloudflare"
    }
  }
}
EOF
}
