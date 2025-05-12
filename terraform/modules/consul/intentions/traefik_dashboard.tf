resource "consul_config_entry_service_intentions" "traefik_dashboard_intentions" {
  name = "traefik-dashboard"

  sources {
    name   = "operator-root"
    action = "allow"
  }
}
