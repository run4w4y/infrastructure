resource "consul_config_entry_service_intentions" "minio_api_intentions" {
  name = "minio-api"

  sources {
    name   = "traefik"
    action = "allow"
  }

  sources {
    name   = "operator-root"
    action = "allow"
  }
}
