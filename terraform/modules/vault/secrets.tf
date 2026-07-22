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

# postgres secrets

resource "random_password" "postgres_password" {
  length = 32
}

resource "vault_kv_secret_v2" "postgres_secret" {
  mount = vault_mount.kvv2.path
  name  = "postgres/root-credentials"
  data_json = jsonencode({
    username = "root"
    password = random_password.postgres_password.result
  })
}

# NATS server bootstrap credentials. Application identities are owned by the
# dedicated NATS module, just like PostgreSQL and MinIO client identities are
# owned by their service modules.

resource "random_password" "nats_root_password" {
  length  = 32
  special = false
}

resource "vault_kv_secret_v2" "nats_root_credentials" {
  mount = vault_mount.kvv2.path
  name  = "nats/root-credentials"
  data_json = jsonencode({
    username      = "root"
    password      = random_password.nats_root_password.result
    password_hash = random_password.nats_root_password.bcrypt_hash
  })
}

# ente secrets

resource "random_id" "ente_encryption_key" {
  byte_length = 32
}

resource "random_id" "ente_hash_key" {
  byte_length = 64
}

resource "random_id" "ente_jwt_secret" {
  byte_length = 32
}

resource "vault_kv_secret_v2" "name" {
  mount = vault_mount.kvv2.path
  name  = "ente/server-secrets"
  data_json = jsonencode({
    encryption_key = random_id.ente_encryption_key.b64_std
    hash_key       = random_id.ente_hash_key.b64_std
    jwt_secret     = random_id.ente_jwt_secret.b64_std
  })
}
