# read the tunnel secret from vault

data "vault_kv_secret_v2" "cloudflared_tunnel_secret" {
  mount = "secret"
  name  = "cloudflared/tunnel-secret"
}
