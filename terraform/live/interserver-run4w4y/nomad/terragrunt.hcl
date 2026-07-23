terraform {
  source = "../../../modules/nomad"
}

inputs = {
  vault_address  = get_env("VAULT_ADDR")
  consul_address = get_env("CONSUL_HTTP_ADDR")
  nomad_address  = get_env("NOMAD_ADDR")

  # Nomad otherwise reserves 250 MHz and 128 MiB for every Envoy sidecar.
  connect_sidecar_cpu        = 50
  connect_sidecar_memory     = 64
  connect_sidecar_memory_max = 128

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
  postgres_job_cpu             = 400
  postgres_job_memory          = 1024
  postgres_job_port            = 5432
  postgres_job_count           = 1
  postgres_job_max_connections = 30
  postgres_job_db_name         = "default_db"

  # NATS JetStream job
  nats_job_cpu              = 50
  nats_job_memory           = 128
  nats_job_client_port      = 4222
  nats_job_monitoring_port  = 8222
  nats_job_count            = 1
  nats_jetstream_max_memory = "64MB"
  nats_jetstream_max_file   = "1GB"

  # Generic headless Chromium service
  chromium_job_image      = "chromedp/headless-shell:151.0.7922.34@sha256:88359186a9024c4de0b0245c7001e39d5609e0aa0dafab3a0914e9419f258e28"
  chromium_job_cpu        = 200
  chromium_job_memory     = 512
  chromium_job_memory_max = 1024
  chromium_job_port       = 9222
  chromium_job_count      = 1
  chromium_job_shm_size   = 536870912

  # Ente server (museum) job
  ente_museum_job_cpu           = 400
  ente_museum_job_memory        = 512
  ente_museum_job_count         = 1
  ente_museum_primary_domain    = get_env("DOMAIN_NAME")
  ente_museum_job_admin_user_id = get_env("ENTE_ADMIN_USER_ID")
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
      name    = "interserver-run4w4y-nomad"
    }
  }
}
EOF
}
