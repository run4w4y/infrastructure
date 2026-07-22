variable "cpu" {}

variable "memory" {}

variable "api_port" {}

variable "console_port" {}

variable "dashboard_port" {}

variable "group_count" {}

variable "volume_source" {}

variable "sidecar_cpu" {}

variable "sidecar_memory" {}

variable "sidecar_memory_max" {}

resource "nomad_job" "minio_job" {
  jobspec = templatefile("${path.module}/template.hcl.tftpl", {
    cpu                = var.cpu
    memory             = var.memory
    api_port           = var.api_port
    console_port       = var.console_port
    dashboard_port     = var.dashboard_port
    count              = var.group_count
    volume_source      = var.volume_source
    sidecar_cpu        = var.sidecar_cpu
    sidecar_memory     = var.sidecar_memory
    sidecar_memory_max = var.sidecar_memory_max
  })
}
