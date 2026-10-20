terraform {
  source = "../../../modules/vault"
}

inputs = {
  cloudflare_access_headers = get_env("CF_ACCESS_CLIENT_ID", "") == "" ? {} : {
    "CF-Access-Client-Id"     = get_env("CF_ACCESS_CLIENT_ID")
    "CF-Access-Client-Secret" = get_env("CF_ACCESS_CLIENT_SECRET")
  }

  vault_address = get_env("VAULT_ADDR")

  consul_vault_token = get_env("CONSUL_HTTP_TOKEN")
  cluster_ca_pem     = base64decode(get_env("CLUSTER_CA_BASE64"))
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
      name    = "interserver-run4w4y-vault"
    }
  }
}
EOF
}
