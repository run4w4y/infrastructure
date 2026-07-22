variable "cpu" {
  type = number
}

variable "memory" {
  type = number
}

variable "client_port" {
  type = number
}

variable "monitoring_port" {
  type = number
}

variable "group_count" {
  type = number
}

variable "jetstream_max_memory" {
  type = string
}

variable "jetstream_max_file" {
  type = string
}

variable "volume_source" {
  type = string
}

variable "sidecar_cpu" {
  type = number
}

variable "sidecar_memory" {
  type = number
}

variable "sidecar_memory_max" {
  type = number
}

resource "nomad_job" "nats_job" {
  jobspec = templatefile("${path.module}/template.hcl.tftpl", {
    cpu                  = var.cpu
    memory               = var.memory
    client_port          = var.client_port
    monitoring_port      = var.monitoring_port
    count                = var.group_count
    jetstream_max_memory = var.jetstream_max_memory
    jetstream_max_file   = var.jetstream_max_file
    volume_source        = var.volume_source
    sidecar_cpu          = var.sidecar_cpu
    sidecar_memory       = var.sidecar_memory
    sidecar_memory_max   = var.sidecar_memory_max
  })
}
