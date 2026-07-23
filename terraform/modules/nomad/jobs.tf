variable "connect_sidecar_cpu" {
  description = "CPU reservation in MHz for every Consul Connect Envoy sidecar."
  type        = number
  default     = 50
}

variable "connect_sidecar_memory" {
  description = "Soft memory reservation in MiB for every Consul Connect Envoy sidecar."
  type        = number
  default     = 64
}

variable "connect_sidecar_memory_max" {
  description = "Hard memory limit in MiB for every Consul Connect Envoy sidecar."
  type        = number
  default     = 128
}

# minio job

variable "minio_job_cpu" {
  type    = number
  default = 256
}

variable "minio_job_memory" {
  type    = number
  default = 1024
}

variable "minio_job_api_port" {
  type    = number
  default = 9000
}

variable "minio_job_console_port" {
  type    = number
  default = 9001
}

variable "minio_job_dashboard_port" {
  type    = number
  default = 9002
}

variable "minio_job_count" {
  type    = number
  default = 1
}

module "minio" {
  source = "./jobs/minio"

  cpu                = var.minio_job_cpu
  memory             = var.minio_job_memory
  api_port           = var.minio_job_api_port
  console_port       = var.minio_job_console_port
  dashboard_port     = var.minio_job_dashboard_port
  group_count        = var.minio_job_count
  volume_source      = nomad_dynamic_host_volume.minio_data.name
  sidecar_cpu        = var.connect_sidecar_cpu
  sidecar_memory     = var.connect_sidecar_memory
  sidecar_memory_max = var.connect_sidecar_memory_max
}

# cloudflared job

variable "cloudflared_job_cpu" {
  type    = number
  default = 100
}

variable "cloudflared_job_memory" {
  type    = number
  default = 128
}

variable "cloudflared_job_account_id" {
  type = string
}

variable "cloudflared_job_count" {
  type    = number
  default = 1
}

module "cloudflared" {
  source = "./jobs/cloudflared"

  cpu                = var.cloudflared_job_cpu
  memory             = var.cloudflared_job_memory
  account_id         = var.cloudflared_job_account_id
  group_count        = var.cloudflared_job_count
  sidecar_cpu        = var.connect_sidecar_cpu
  sidecar_memory     = var.connect_sidecar_memory
  sidecar_memory_max = var.connect_sidecar_memory_max
}

# traefik job

variable "traefik_job_cpu" {
  type    = number
  default = 100
}

variable "traefik_job_memory" {
  type    = number
  default = 128
}

variable "traefik_job_http_port" {
  type    = number
  default = 8080
}

variable "traefik_job_https_port" {
  type    = number
  default = 8088
}

variable "traefik_job_dashboard_port" {
  type    = number
  default = 8989
}

variable "traefik_job_primary_domain" {
  type    = string
  default = "example.com"
}

variable "traefik_job_count" {
  type    = number
  default = 1
}

module "traefik" {
  source = "./jobs/traefik"

  cpu                = var.traefik_job_cpu
  memory             = var.traefik_job_memory
  http_port          = var.traefik_job_http_port
  https_port         = var.traefik_job_https_port
  dashboard_port     = var.traefik_job_dashboard_port
  primary_domain     = var.traefik_job_primary_domain
  group_count        = var.traefik_job_count
  sidecar_cpu        = var.connect_sidecar_cpu
  sidecar_memory     = var.connect_sidecar_memory
  sidecar_memory_max = var.connect_sidecar_memory_max
}

# postgres job

variable "postgres_job_cpu" {
  type    = number
  default = 1000
}

variable "postgres_job_memory" {
  type    = number
  default = 512
}

variable "postgres_job_port" {
  type    = number
  default = 5432
}

variable "postgres_job_count" {
  type    = number
  default = 1
}

variable "postgres_job_max_connections" {
  type    = number
  default = 20
}

variable "postgres_job_db_name" {
  type    = string
  default = "default_db"
}

module "postgres" {
  source = "./jobs/postgres"

  cpu                = var.postgres_job_cpu
  memory             = var.postgres_job_memory
  port               = var.postgres_job_port
  group_count        = var.postgres_job_count
  max_connections    = var.postgres_job_max_connections
  volume_source      = nomad_dynamic_host_volume.postgres_data.name
  db_name            = var.postgres_job_db_name
  sidecar_cpu        = var.connect_sidecar_cpu
  sidecar_memory     = var.connect_sidecar_memory
  sidecar_memory_max = var.connect_sidecar_memory_max
}

# NATS JetStream job

variable "nats_job_cpu" {
  type    = number
  default = 50
}

variable "nats_job_memory" {
  type    = number
  default = 128
}

variable "nats_job_client_port" {
  type    = number
  default = 4222
}

variable "nats_job_monitoring_port" {
  type    = number
  default = 8222
}

variable "nats_job_count" {
  type    = number
  default = 1
}

variable "nats_jetstream_max_memory" {
  type    = string
  default = "64MB"
}

variable "nats_jetstream_max_file" {
  type    = string
  default = "1GB"
}

module "nats" {
  source = "./jobs/nats"

  cpu                  = var.nats_job_cpu
  memory               = var.nats_job_memory
  client_port          = var.nats_job_client_port
  monitoring_port      = var.nats_job_monitoring_port
  group_count          = var.nats_job_count
  jetstream_max_memory = var.nats_jetstream_max_memory
  jetstream_max_file   = var.nats_jetstream_max_file
  volume_source        = nomad_dynamic_host_volume.nats_data.name
  sidecar_cpu          = var.connect_sidecar_cpu
  sidecar_memory       = var.connect_sidecar_memory
  sidecar_memory_max   = var.connect_sidecar_memory_max
}

# Generic headless Chromium service

variable "chromium_job_image" {
  description = "Pinned chromedp/headless-shell image reference, including sha256 digest."
  type        = string
  default     = "chromedp/headless-shell:151.0.7922.34@sha256:88359186a9024c4de0b0245c7001e39d5609e0aa0dafab3a0914e9419f258e28"
}

variable "chromium_job_cpu" {
  type    = number
  default = 200
}

variable "chromium_job_memory" {
  type    = number
  default = 512
}

variable "chromium_job_memory_max" {
  type    = number
  default = 1024
}

variable "chromium_job_port" {
  type    = number
  default = 9222
}

variable "chromium_job_count" {
  type    = number
  default = 1
}

variable "chromium_job_shm_size" {
  description = "Chromium shared-memory allocation in bytes."
  type        = number
  default     = 536870912
}

module "chromium" {
  source = "./jobs/chromium"

  image              = var.chromium_job_image
  cpu                = var.chromium_job_cpu
  memory             = var.chromium_job_memory
  memory_max         = var.chromium_job_memory_max
  port               = var.chromium_job_port
  group_count        = var.chromium_job_count
  shm_size           = var.chromium_job_shm_size
  sidecar_cpu        = var.connect_sidecar_cpu
  sidecar_memory     = var.connect_sidecar_memory
  sidecar_memory_max = var.connect_sidecar_memory_max
}

# ente server (museum) job

variable "ente_museum_job_cpu" {
  type    = number
  default = 400
}

variable "ente_museum_job_memory" {
  type    = number
  default = 1024
}

variable "ente_museum_job_count" {
  type    = number
  default = 1
}

variable "ente_museum_primary_domain" {
  type = string
}

variable "ente_museum_job_admin_user_id" {
  type    = number
  default = 0
}

module "ente_museum" {
  source = "./jobs/ente-museum"

  cpu                = var.ente_museum_job_cpu
  memory             = var.ente_museum_job_memory
  group_count        = var.ente_museum_job_count
  primary_domain     = var.ente_museum_primary_domain
  admin_user_id      = var.ente_museum_job_admin_user_id
  sidecar_cpu        = var.connect_sidecar_cpu
  sidecar_memory     = var.connect_sidecar_memory
  sidecar_memory_max = var.connect_sidecar_memory_max
}
