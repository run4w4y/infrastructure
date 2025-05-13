# read the minio root user credentials from the vault

data "vault_kv_secret_v2" "minio_secret" {
  mount = "secret"
  name  = "minio/root-credentials"
}

# save the bucket credentials into vault

resource "vault_kv_secret_v2" "ente_s3_secret" {
  mount = "secret"
  name  = "ente/s3-config"
  data_json = jsonencode({
    access_key = minio_iam_user.ente.id
    secret_key = minio_iam_user.ente.secret
    buckets = {
      for original, res in minio_s3_bucket.ente :
      original => res.bucket
    }
  })
}
