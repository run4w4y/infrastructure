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

  cpu            = var.minio_job_cpu
  memory         = var.minio_job_memory
  api_port       = var.minio_job_api_port
  console_port   = var.minio_job_console_port
  dashboard_port = var.minio_job_dashboard_port
  group_count    = var.minio_job_count
  volume_source  = nomad_dynamic_host_volume.minio_data.name
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

  cpu         = var.cloudflared_job_cpu
  memory      = var.cloudflared_job_memory
  account_id  = var.cloudflared_job_account_id
  group_count = var.cloudflared_job_count
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

  cpu            = var.traefik_job_cpu
  memory         = var.traefik_job_memory
  http_port      = var.traefik_job_http_port
  https_port     = var.traefik_job_https_port
  dashboard_port = var.traefik_job_dashboard_port
  primary_domain = var.traefik_job_primary_domain
  group_count    = var.traefik_job_count
}
