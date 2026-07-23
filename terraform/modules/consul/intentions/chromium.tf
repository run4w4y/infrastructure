resource "consul_config_entry_service_intentions" "chromium_intentions" {
  name = "chromium"

  sources {
    name   = "cv-pdf-worker"
    action = "allow"
  }
}
