resource "nomad_dynamic_host_volume" "minio_data" {
  name      = "minio-data"
  namespace = "default"

  plugin_id = "mkdir"

  capacity_min = "500 GiB"
  capacity_max = "3 TiB"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }

  constraint {
    attribute = "$${attr.kernel.name}"
    value     = "linux"
  }

  lifecycle {
    prevent_destroy = true
  }
}

output "minio_volume_id" {
  value       = nomad_dynamic_host_volume.minio_data.id
  description = "The unique ID Nomad assigned to the minio-data volume"
}

resource "nomad_dynamic_host_volume" "postgres_data" {
  name      = "postgres-data"
  namespace = "default"

  plugin_id = "mkdir"

  capacity_min = "2 GiB"
  capacity_max = "250 GiB"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }

  constraint {
    attribute = "$${attr.kernel.name}"
    value     = "linux"
  }

  lifecycle {
    prevent_destroy = true
  }
}

output "postgres_volume_id" {
  value       = nomad_dynamic_host_volume.postgres_data.id
  description = "The unique ID Nomad assigned to the postgres-data volume"
}

resource "nomad_dynamic_host_volume" "nats_data" {
  name      = "nats-data"
  namespace = "default"

  plugin_id = "mkdir"

  capacity_min = "1 GiB"
  capacity_max = "10 GiB"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }

  constraint {
    attribute = "$${attr.kernel.name}"
    value     = "linux"
  }

  lifecycle {
    prevent_destroy = true
  }
}

output "nats_volume_id" {
  value       = nomad_dynamic_host_volume.nats_data.id
  description = "The unique ID Nomad assigned to the nats-data volume"
}

resource "nomad_dynamic_host_volume" "openviking_data" {
  name         = "openviking-data"
  namespace    = "default"
  plugin_id    = "mkdir"
  parameters   = { mode = "0700", uid = "0", gid = "0" }
  capacity_min = "2.0 GiB"
  capacity_max = "100 GiB"
  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
  constraint {
    attribute = "$${attr.kernel.name}"
    value     = "linux"
  }
  lifecycle { prevent_destroy = true }
}

resource "nomad_dynamic_host_volume" "openviking_models" {
  name         = "openviking-models"
  namespace    = "default"
  plugin_id    = "mkdir"
  parameters   = { mode = "0700", uid = "0", gid = "0" }
  capacity_min = "2.0 GiB"
  capacity_max = "100 GiB"
  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
  constraint {
    attribute = "$${attr.kernel.name}"
    value     = "linux"
  }
  lifecycle { prevent_destroy = true }
}

resource "nomad_dynamic_host_volume" "paseo_state" {
  name      = "paseo-state"
  namespace = "default"
  plugin_id = "mkdir"
  node_id   = var.paseo_job_node_id

  parameters = {
    mode = "0700"
    uid  = "65534"
    gid  = "65534"
  }

  capacity_min = "1.0 GiB"
  capacity_max = "32 GiB"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }

  lifecycle {
    prevent_destroy = true
  }
}
