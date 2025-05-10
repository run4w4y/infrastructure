# policies for reading secrets

resource "vault_policy" "cloudflare_tunnel" {
  name   = "cloudflare_tunnel"
  policy = <<EOT
    path "${vault_kv_secret_v2.cloudflare_tunnel_secret.path}" {
      capabilities = ["read"]
    }
  EOT
}

resource "vault_policy" "minio" {
  name   = "minio"
  policy = <<EOT
    path "${vault_kv_secret_v2.minio_secret.path}" {
      capabilities = ["read"]
    }
  EOT
}

resource "vault_policy" "traefik" {
  name   = "traefik"
  policy = <<EOT
    path "${vault_kv_secret_v2.traefik_secret.path}" {
      capabilities = ["read"]
    }
  EOT
}
