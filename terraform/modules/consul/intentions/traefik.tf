resource "consul_config_entry_service_intentions" "traefik_intentions" {
  name = "traefik"

  sources {
    name   = "cloudflared"
    action = "allow"
  }

  sources {
    name   = "minio-api"
    action = "allow"
  }

  sources {
    name   = "minio-dashboard"
    action = "allow"
  }

  sources {
    name   = "ente-web-photos"
    action = "allow"
  }

  sources {
    name   = "ente-web-accounts"
    action = "allow"
  }

  sources {
    name   = "ente-web-auth"
    action = "allow"
  }

  sources {
    name   = "ente-web-cast"
    action = "allow"
  }

  sources {
    name   = "ente-web-albums"
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
      sources[2].precedence,
      sources[3].precedence,
      sources[4].precedence,
      sources[5].precedence,
      sources[6].precedence,
      sources[7].precedence,
      sources[8].precedence,
    ]
  }
}
