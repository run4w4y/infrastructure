resource "consul_config_entry_service_intentions" "traefik_intentions" {
  name = "traefik"

  sources {
    name   = "cloudflared"
    action = "allow"
  }

  sources {
    name   = "operator-root"
    action = "allow"
  }
}
