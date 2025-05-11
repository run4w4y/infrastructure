variable "cpu" {}

variable "memory" {}

variable "http_port" {}

variable "https_port" {}

variable "dashboard_port" {}

variable "primary_domain" {}

variable "group_count" {}

variable "dashboard_rule" {
  type        = string
  description = "Dashboard router rule"
  default     = "PathPrefix(`/`)"
}

resource "nomad_job" "traefik_job" {
  jobspec = templatefile("${path.module}/template.hcl.tftpl", {
    cpu            = var.cpu
    memory         = var.memory
    http_port      = var.http_port
    https_port     = var.https_port
    dashboard_port = var.dashboard_port
    primary_domain = var.primary_domain
    count          = var.group_count
    dashboard_rule = var.dashboard_rule
  })
}
