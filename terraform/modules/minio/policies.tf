# ente policy for management of the ente-related buckets

data "minio_iam_policy_document" "ente" {
  statement {
    sid       = "EnteBucketsManagement"
    effect    = "Allow"
    actions   = ["s3:*"]
    principal = "*"
    resources = concat(
      [for b in local.ente_buckets : "arn:aws:s3:::${local.ente_bucket_prefix}${b}"],
      [for b in local.ente_buckets : "arn:aws:s3:::${local.ente_bucket_prefix}${b}/*"]
    )
  }
}

resource "minio_iam_policy" "ente" {
  name   = "${minio_iam_user.ente.name}-policy"
  policy = data.minio_iam_policy_document.ente.json
}

resource "minio_iam_user_policy_attachment" "ente" {
  user_name   = minio_iam_user.ente.id
  policy_name = minio_iam_policy.ente.id
}

# share policy for management of the temporary sharing bucket

data "minio_iam_policy_document" "share" {
  statement {
    sid       = "ShareBucketManagement"
    effect    = "Allow"
    actions   = ["s3:*"]
    principal = "*"
    resources = [
      "arn:aws:s3:::${local.share_bucket}",
      "arn:aws:s3:::${local.share_bucket}/*"
    ]
  }
}

resource "minio_iam_policy" "share" {
  name   = "${minio_iam_user.share.name}-policy"
  policy = data.minio_iam_policy_document.share.json
}

resource "minio_iam_user_policy_attachment" "share" {
  user_name   = minio_iam_user.share.id
  policy_name = minio_iam_policy.share.id
}
