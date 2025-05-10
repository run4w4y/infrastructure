variable "cpu" {}

variable "memory" {}

variable "tunnel_name" {}

variable "group_count" {}

resource "nomad_job" "cloudflared_job" {
  jobspec = templatefile("${path.module}/template.hcl.tftpl", {
    cpu         = var.cpu
    memory      = var.memory
    tunnel_name = var.tunnel_name
    count       = var.group_count
  })
}
