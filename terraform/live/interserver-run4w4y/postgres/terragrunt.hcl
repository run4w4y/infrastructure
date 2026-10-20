terraform {
  source = "../../../modules/postgres"
}

inputs = {
  cloudflare_access_headers = get_env("CF_ACCESS_CLIENT_ID", "") == "" ? {} : {
    "CF-Access-Client-Id"     = get_env("CF_ACCESS_CLIENT_ID")
    "CF-Access-Client-Secret" = get_env("CF_ACCESS_CLIENT_SECRET")
  }

  vault_address    = get_env("VAULT_ADDR")
  postgres_address = get_env("POSTGRES_ADDRESS", "127.0.0.1")
  postgres_port    = get_env("POSTGRES_PORT", "5432")
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
