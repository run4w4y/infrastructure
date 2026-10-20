resource "consul_config_entry_service_intentions" "chromium_intentions" {
  name = "chromium"

  sources {
    name   = "cv-pdf-worker"
    action = "allow"
  }

  lifecycle {
    # Consul computes precedence; the provider incorrectly treats it as optional.
    ignore_changes = [
      sources[0].precedence,
    ]
  }
}
