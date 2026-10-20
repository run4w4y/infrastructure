variable "image" {
  type = string
}

variable "ollama_image" {
  type = string
}

variable "hostname" {
  type = string
}

variable "data_volume" {
  type = string
}

variable "model_volume" {
  type = string
}

resource "nomad_job" "openviking_job" {
  detach = true
  jobspec = templatefile("${path.module}/template.hcl.tftpl", {
    image        = var.image
    ollama_image = var.ollama_image
    hostname     = var.hostname
    data_volume  = var.data_volume
    model_volume = var.model_volume
  })
}
