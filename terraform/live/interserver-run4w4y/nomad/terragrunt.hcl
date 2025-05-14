terraform {
  source = "../../../modules/nomad"
}

inputs = {
  vault_address  = get_env("VAULT_ADDR")
  consul_address = get_env("CONSUL_HTTP_ADDR")
  nomad_address  = get_env("NOMAD_ADDR")

  # Minio job
  minio_job_cpu            = 256
  minio_job_memory         = 1024
  minio_job_api_port       = 9000
  minio_job_console_port   = 9001
  minio_job_dashboard_port = 9002
  minio_job_count          = 1

  # Cloudflared job
  cloudflared_job_cpu        = 100
  cloudflared_job_memory     = 128
  cloudflared_job_account_id = get_env("CF_ACCOUNT_ID")
  cloudflared_job_count      = 1

  # Traefik job
  traefik_job_cpu            = 100
  traefik_job_memory         = 128
  traefik_job_http_port      = 8080
  traefik_job_https_port     = 8088
  traefik_job_dashboard_port = 8989
  traefik_job_primary_domain = get_env("DOMAIN_NAME")
  traefik_job_count          = 1

  # Postgres job
  postgres_job_cpu             = 1000
  postgres_job_memory          = 1024
  postgres_job_port            = 5432
  postgres_job_count           = 1
  postgres_job_max_connections = 30
  postgres_job_db_name         = "default_db"

  # Ente server (museum) job
  ente_museum_job_cpu           = 400
  ente_museum_job_memory        = 512
  ente_museum_job_count         = 1
  ente_museum_primary_domain    = get_env("DOMAIN_NAME")
  ente_museum_job_admin_user_id = get_env("ENTE_ADMIN_USER_ID")
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
