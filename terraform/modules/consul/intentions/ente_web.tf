locals {
  ente_web_apps = ["photos", "accounts", "auth", "cast", "albums"]
}

resource "consul_config_entry_service_intentions" "ente_web_intentions" {
  for_each = { for b in local.ente_web_apps : b => "ente-web-${b}" }

  name = each.value

  sources {
    name   = "traefik"
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
    ]
  }
}

# Keep the previous destinations until the shared endpoint and rollback pass.
resource "consul_config_entry_service_intentions" "ente_web_shared_intentions" {
  name = "ente-web"

  sources {
    name   = "traefik"
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
    ]
  }
}
