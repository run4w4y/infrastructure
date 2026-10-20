variable "image" {
  type = string
}

variable "state_volume" {
  type = string
}

variable "node_id" {
  type = string
}

variable "configuration" {
  type = string
}

variable "settings" {
  type = object({
    memory_reservation_mib = number
    memory_limit_mib       = number
    sidecar_memory_mib     = number
    node_options           = string
  })
}

variable "meta" {
  type = map(string)
}

resource "nomad_job" "paseo_job" {
  detach = true

  jobspec = templatefile("${path.module}/template.hcl.tftpl", {
    image              = var.image
    state_volume       = var.state_volume
    node_id            = var.node_id
    configuration      = var.configuration
    memory_reservation = var.settings.memory_reservation_mib
    memory_limit       = var.settings.memory_limit_mib
    sidecar_memory     = var.settings.sidecar_memory_mib
    node_options       = var.settings.node_options
    meta               = var.meta
  })
}
