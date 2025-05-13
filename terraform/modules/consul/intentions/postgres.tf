resource "consul_config_entry_service_intentions" "postgres_intentions" {
  name = "postgres"

  sources {
    name   = "ente-museum"
    action = "allow"
  }

  sources {
    name   = "operator-root"
    action = "allow"
  }
}
