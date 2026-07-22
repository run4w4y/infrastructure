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

resource "vault_kv_secret_v2" "share_s3_secret" {
  mount = "secret"
  name  = "share/s3-config"
  data_json = jsonencode({
    access_key = minio_iam_user.share.id
    secret_key = minio_iam_user.share.secret
    bucket     = minio_s3_bucket.share.bucket
    endpoint   = "https://${var.minio_address}"
  })
}

resource "vault_kv_secret_v2" "cv_registry_s3_secret" {
  mount = "secret"
  name  = "cv-registry/minio-credentials"
  data_json = jsonencode({
    access_key       = minio_iam_user.cv_registry.id
    secret_key       = minio_iam_user.cv_registry.secret
    endpoint         = "http://127.0.0.1:9000"
    external_url     = "https://${var.minio_address}"
    region           = "ru-central"
    force_path_style = true
    objects_bucket   = minio_s3_bucket.cv_objects.bucket
    facts_bucket     = minio_s3_bucket.cv_facts.bucket
  })
}

# Job-scoped credentials for the dedicated PDF worker identity.

resource "vault_kv_secret_v2" "cv_pdf_worker_s3_secret" {
  mount = "secret"
  name  = "cv-pdf-worker/minio-credentials"
  data_json = jsonencode({
    access_key       = minio_iam_user.cv_pdf_worker.id
    secret_key       = minio_iam_user.cv_pdf_worker.secret
    endpoint         = "http://127.0.0.1:9000"
    external_url     = "https://${var.minio_address}"
    region           = "ru-central"
    force_path_style = true
    objects_bucket   = minio_s3_bucket.cv_objects.bucket
  })
}

resource "vault_kv_secret_v2" "cv_facts_publisher_s3_secret" {
  mount = "secret"
  name  = "cv-facts-publisher/minio-credentials"
  data_json = jsonencode({
    access_key       = minio_iam_user.cv_facts_publisher.id
    secret_key       = minio_iam_user.cv_facts_publisher.secret
    endpoint         = "https://${var.minio_address}"
    region           = "ru-central"
    force_path_style = true
    bucket           = minio_s3_bucket.cv_facts.bucket
  })
}
