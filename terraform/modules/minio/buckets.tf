# create ente buckets

resource "minio_s3_bucket" "ente" {
  for_each = { for b in local.ente_buckets : b => "${local.ente_bucket_prefix}${b}" }

  bucket = each.value
  acl    = "private"
}
