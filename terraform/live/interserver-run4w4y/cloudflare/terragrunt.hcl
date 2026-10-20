terraform {
  source = "../../../modules/cloudflare"
}

dependency "infisical" {
  config_path = "../infisical"
}

inputs = {
  cloudflare_access_headers = get_env("CF_ACCESS_CLIENT_ID", "") == "" ? {} : {
    "CF-Access-Client-Id"     = get_env("CF_ACCESS_CLIENT_ID")
    "CF-Access-Client-Secret" = get_env("CF_ACCESS_CLIENT_SECRET")
  }

  vault_address         = get_env("VAULT_ADDR")
  domain_name           = get_env("DOMAIN_NAME")
  cloudflare_account_id = get_env("CF_ACCOUNT_ID")
  cloudflare_api_token  = get_env("CF_API_TOKEN")
  porkbun_api_key       = get_env("PB_API_KEY")
  porkbun_secret_key    = get_env("PB_SECRET_KEY")
  owner_emails          = ["add4che@gmail.com"]
  access_team_name      = "run4w4y"

  infisical_host       = get_env("INFISICAL_HOST", "https://app.infisical.com")
  infisical_project_id = get_env("INFISICAL_PROJECT_ID")
  infisical_env_slug   = get_env("INFISICAL_ENV", "prod")
  ci_secret_targets    = dependency.infisical.outputs.ci_secret_targets

  ingress_rules = [
    for name, settings in {
      nomad  = { port = 4646, server_name = "server.global.nomad" }
      vault  = { port = 8200, server_name = "vault.service.consul" }
      consul = { port = 8501, server_name = "server.dc1.consul" }
      } : {
      hostname = name
      service  = "https://172.26.64.1:${settings.port}"
      origin_request = {
        ca_pool            = "/local/cluster-ca.pem"
        origin_server_name = settings.server_name
      }
    }
  ]
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
