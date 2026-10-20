resource "consul_config_entry_service_intentions" "cv_registry_intentions" {
  name = "cv-registry"

  sources {
    name   = "traefik"
    action = "allow"
  }

  sources {
    name   = "cv-web"
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
    ]
  }
}
