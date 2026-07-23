variable "image" {
  description = "Pinned chromedp/headless-shell image reference, including sha256 digest."
  type        = string
}

variable "cpu" {
  type = number
}

variable "memory" {
  type = number
}

variable "memory_max" {
  type = number
}

variable "port" {
  type = number
}

variable "group_count" {
  type = number
}

variable "shm_size" {
  description = "Chromium shared-memory allocation in bytes."
  type        = number
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

resource "nomad_job" "chromium_job" {
  jobspec = templatefile("${path.module}/template.hcl.tftpl", {
    image              = var.image
    cpu                = var.cpu
    memory             = var.memory
    memory_max         = var.memory_max
    port               = var.port
    count              = var.group_count
    shm_size           = var.shm_size
    sidecar_cpu        = var.sidecar_cpu
    sidecar_memory     = var.sidecar_memory
    sidecar_memory_max = var.sidecar_memory_max
  })
}
