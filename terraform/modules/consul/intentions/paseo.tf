resource "consul_config_entry" "paseo_defaults" {
  kind = "service-defaults"
  name = "paseo"

  config_json = jsonencode({
    Expose           = {}
    MeshGateway      = {}
    Protocol         = "http"
    TransparentProxy = {}
  })
}

resource "consul_config_entry_service_intentions" "paseo_intentions" {
  name = "paseo"

  sources {
    name   = "traefik"
    action = "allow"
  }

  lifecycle {
    # Consul computes precedence; the provider incorrectly treats it as optional.
    ignore_changes = [
      sources[0].precedence,
    ]
  }
}
