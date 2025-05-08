resource "vault_policy" "cloudflare_tunnel" {
  name   = "cloudflare_tunnel"
  policy = <<EOT
    path "${vault_kv_secret_v2.cloudflare_tunnel_secret.path}" {
      capabilities = ["read"]
    }
  EOT
}
