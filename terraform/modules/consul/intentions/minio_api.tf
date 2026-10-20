resource "consul_config_entry_service_intentions" "minio_api_intentions" {
  name = "minio-api"

  sources {
    name   = "traefik"
    action = "allow"
  }

  sources {
    name   = "ente-museum"
    action = "allow"
  }

  sources {
    name   = "cv-registry"
    action = "allow"
  }

  sources {
    name   = "cv-pdf-worker"
    action = "allow"
  }

  sources {
    name   = "operator-root"
    action = "allow"
  }

  lifecycle {
    # Consul computes precedence; the provider incorrectly treats it as optional.
    ignore_changes = [
      sources[0].precedence,
      sources[1].precedence,
      sources[2].precedence,
      sources[3].precedence,
      sources[4].precedence,
    ]
  }
}
