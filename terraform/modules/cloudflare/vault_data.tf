# read the tunnel secret from vault

data "vault_kv_secret_v2" "cloudflared_tunnel_secret" {
  mount = "secret"
  name  = "cloudflared/tunnel-secret"
}

# create the tunnel-id secret

resource "vault_kv_secret_v2" "cloudflared_tunnel_id" {
  mount = "secret"
  name  = "cloudflared/tunnel-id"
  data_json = jsonencode({
    tunnel_id = cloudflare_zero_trust_tunnel_cloudflared.this_tunnel.id
  })
}
