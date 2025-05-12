variable "cpu" {}

variable "memory" {}

variable "port" {}

variable "group_count" {}

variable "max_connections" {}

variable "volume_source" {}

variable "db_name" {}

resource "nomad_job" "postgres_job" {
  jobspec = templatefile("${path.module}/template.hcl.tftpl", {
    cpu             = var.cpu
    memory          = var.memory
    port            = var.port
    count           = var.group_count
    max_connections = var.max_connections
    volume_source   = var.volume_source
    db_name         = var.db_name
  })
}
