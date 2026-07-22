resource "consul_config_entry_service_intentions" "nats_intentions" {
  name = "nats"

  sources {
    name   = "cv-registry"
    action = "allow"
  }

  sources {
    name   = "cv-pdf-worker"
    action = "allow"
  }

  sources {
    name   = "cv-listing-checker"
    action = "allow"
  }

  sources {
    name   = "operator-root"
    action = "allow"
  }
}
