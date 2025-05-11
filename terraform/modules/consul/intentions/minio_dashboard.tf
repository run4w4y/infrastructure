resource "consul_config_entry_service_intentions" "minio_dashboard_intentions" {
  name = "minio-dashboard"

  sources {
    name   = "traefik"
    action = "allow"
  }

  sources {
    name   = "operator-root"
    action = "allow"
  }
}
