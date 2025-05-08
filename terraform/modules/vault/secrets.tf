# initialize kvv2 secrets engine/backend

resource "vault_mount" "kvv2" {
  path    = "secret"
  type    = "kv"
  options = { version = "2" }
}

# cloudflared tunnel secret

resource "random_id" "cloudflare_tunnel_secret_key" {
  byte_length = 32
}

resource "vault_kv_secret_v2" "cloudflare_tunnel_secret" {
  mount = vault_mount.kvv2.path
  name  = "cloudflared/tunnel-secret"
  data_json = jsonencode({
    secret = base64encode(random_id.cloudflare_tunnel_secret_key.b64_std)
  })
}
