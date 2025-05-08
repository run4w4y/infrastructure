resource "consul_config_entry_service_intentions" "cloudflared_intentions" {
  name = "cloudflared"

  sources {
    name   = "traefik"
    action = "allow"
  }

  sources {
    name   = "operator-root"
    action = "allow"
  }
}
