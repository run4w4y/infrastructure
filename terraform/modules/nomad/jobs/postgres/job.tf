variable "cpu" {}

variable "memory" {}

variable "port" {}

variable "group_count" {}

variable "max_connections" {}

variable "volume_source" {}

variable "db_name" {}

variable "sidecar_cpu" {}

variable "sidecar_memory" {}

variable "sidecar_memory_max" {}

resource "nomad_job" "postgres_job" {
  jobspec = templatefile("${path.module}/template.hcl.tftpl", {
    cpu                = var.cpu
    memory             = var.memory
    port               = var.port
    count              = var.group_count
    max_connections    = var.max_connections
    volume_source      = var.volume_source
    db_name            = var.db_name
    sidecar_cpu        = var.sidecar_cpu
    sidecar_memory     = var.sidecar_memory
    sidecar_memory_max = var.sidecar_memory_max
  })
}
