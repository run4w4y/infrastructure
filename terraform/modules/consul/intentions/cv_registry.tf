resource "consul_config_entry_service_intentions" "cv_registry_intentions" {
  name = "cv-registry"

  sources {
    name   = "cv-registry-web"
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
}
