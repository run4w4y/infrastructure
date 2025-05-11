resource "consul_config_entry_service_intentions" "minio_console_intentions" {
  name = "minio-console"

  sources {
    name   = "operator-root"
    action = "allow"
  }
}
