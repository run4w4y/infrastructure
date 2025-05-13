variable "cpu" {}

variable "memory" {}

variable "group_count" {}

variable "http_port" {
  type    = number
  default = 8080
}

variable "metrics_port" {
  type    = number
  default = 2112
}

variable "primary_domain" {}

resource "nomad_job" "ente_museum_job" {
  jobspec = templatefile("${path.module}/template.hcl.tftpl", {
    cpu            = var.cpu
    memory         = var.memory
    count          = var.group_count
    http_port      = var.http_port
    metrics_port   = var.metrics_port
    primary_domain = var.primary_domain
  })
}
