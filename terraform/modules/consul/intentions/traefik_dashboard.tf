resource "consul_config_entry_service_intentions" "traefik_dashboard_intentions" {
  name = "traefik-dashboard"

  sources {
    name   = "operator-root"
    action = "allow"
  }

  lifecycle {
    # Consul computes precedence; the provider incorrectly treats it as optional.
    ignore_changes = [
      sources[0].precedence,
    ]
  }
}
