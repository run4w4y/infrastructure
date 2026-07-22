# create ente buckets

resource "minio_s3_bucket" "ente" {
  for_each = { for b in local.ente_buckets : b => "${local.ente_bucket_prefix}${b}" }

  bucket = each.value
  acl    = "private"
}

# create temporary sharing bucket

resource "minio_s3_bucket" "share" {
  bucket = local.share_bucket
  acl    = "private"
}

resource "minio_ilm_policy" "share" {
  bucket = minio_s3_bucket.share.bucket

  rule {
    id         = "expire-shared-files-after-7d"
    status     = "Enabled"
    expiration = "7d"
  }
}

resource "minio_s3_bucket" "cv_objects" {
  bucket = local.cv_objects_bucket
  acl    = "private"

  lifecycle {
    prevent_destroy = true
  }
}

resource "minio_s3_bucket" "cv_facts" {
  bucket = local.cv_facts_bucket
  acl    = "private"

  lifecycle {
    prevent_destroy = true
  }
}
