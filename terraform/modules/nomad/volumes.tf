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
