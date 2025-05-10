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

# minio secrets

resource "random_password" "minio_password" {
  length = 32
}

resource "vault_kv_secret_v2" "minio_secret" {
  mount = vault_mount.kvv2.path
  name  = "minio/root-credentials"
  data_json = jsonencode({
    username = "root"
    password = random_password.minio_password.result
  })
}

# traefik secrets

resource "random_password" "traefik" {
  length           = 16
  override_special = "_%@"
}

resource "vault_kv_secret_v2" "traefik_secret" {
  mount = vault_mount.kvv2.path
  name  = "traefik/management-user"
  data_json = jsonencode({
    data = {
      user = "management"
      hash = bcrypt(random_password.traefik.result, 10)
    }
  })
}

output "traefik_dashboard_password" {
  value     = random_password.traefik.result
  sensitive = true
}
