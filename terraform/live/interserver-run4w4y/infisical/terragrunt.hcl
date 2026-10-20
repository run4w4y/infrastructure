terraform {
  source = "../../../modules/infisical"
}

inputs = {
  infisical_host       = get_env("INFISICAL_HOST", "https://app.infisical.com")
  infisical_project_id = get_env("INFISICAL_PROJECT_ID", "")
  domain_name          = get_env("DOMAIN_NAME")
  infisical_org_id     = get_env("INFISICAL_ORG_ID", "3a9212ec-315b-43c0-a49b-f16c70978124")
  cluster_ca_pem       = base64decode(get_env("CLUSTER_CA_BASE64"))
  environment_slug     = get_env("INFISICAL_ENV", "prod")
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
      name    = "interserver-run4w4y-infisical"
    }
  }
}
EOF
}

