variable "cpu" {}

variable "memory" {}

variable "account_id" {}

variable "group_count" {}

variable "metrics_port" {
  type    = number
  default = 2000
}

resource "nomad_job" "cloudflared_job" {
  jobspec = templatefile("${path.module}/template.hcl.tftpl", {
    cpu          = var.cpu
    memory       = var.memory
    account_id   = var.account_id
    count        = var.group_count
    metrics_port = var.metrics_port
  })
}
