resource "consul_config_entry_service_intentions" "cv_web_intentions" {
  name = "cv-web"

  sources {
    name   = "traefik"
    action = "allow"
  }

  sources {
    name   = "operator-root"
    action = "allow"
  }
}
