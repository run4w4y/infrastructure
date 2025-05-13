resource "consul_config_entry_service_intentions" "ente_museum_intentions" {
  name = "ente-museum"

  sources {
    name   = "traefik"
    action = "allow"
  }

  sources {
    name   = "operator-root"
    action = "allow"
  }
}
