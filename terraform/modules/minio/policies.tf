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

# The registry owns generated artifacts and reads published facts through its
# same-origin API. It deliberately cannot modify the facts bucket.

data "minio_iam_policy_document" "cv_registry" {
  statement {
    sid       = "CvBucketDiscovery"
    effect    = "Allow"
    actions   = ["s3:GetBucketLocation", "s3:ListBucket"]
    principal = "*"
    resources = [
      "arn:aws:s3:::${local.cv_objects_bucket}",
      "arn:aws:s3:::${local.cv_facts_bucket}",
    ]
  }

  statement {
    sid       = "CvObjectManagement"
    effect    = "Allow"
    actions   = ["s3:DeleteObject", "s3:GetObject", "s3:PutObject"]
    principal = "*"
    resources = ["arn:aws:s3:::${local.cv_objects_bucket}/*"]
  }

  statement {
    sid       = "CvFactsRead"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    principal = "*"
    resources = ["arn:aws:s3:::${local.cv_facts_bucket}/*"]
  }
}

resource "minio_iam_policy" "cv_registry" {
  name   = "${minio_iam_user.cv_registry.name}-policy"
  policy = data.minio_iam_policy_document.cv_registry.json
}

resource "minio_iam_user_policy_attachment" "cv_registry" {
  user_name   = minio_iam_user.cv_registry.id
  policy_name = minio_iam_policy.cv_registry.id
}

# The PDF worker can deduplicate, read, and write generated artifacts. It has no
# access to the facts bucket and cannot delete objects.

data "minio_iam_policy_document" "cv_pdf_worker" {
  statement {
    sid       = "CvPdfObjectBucketDiscovery"
    effect    = "Allow"
    actions   = ["s3:GetBucketLocation", "s3:ListBucket"]
    principal = "*"
    resources = ["arn:aws:s3:::${local.cv_objects_bucket}"]
  }

  statement {
    sid       = "CvPdfObjectReadWrite"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject"]
    principal = "*"
    resources = ["arn:aws:s3:::${local.cv_objects_bucket}/*"]
  }
}

resource "minio_iam_policy" "cv_pdf_worker" {
  name   = "${minio_iam_user.cv_pdf_worker.name}-policy"
  policy = data.minio_iam_policy_document.cv_pdf_worker.json
}

resource "minio_iam_user_policy_attachment" "cv_pdf_worker" {
  user_name   = minio_iam_user.cv_pdf_worker.id
  policy_name = minio_iam_policy.cv_pdf_worker.id
}

# Facts publishing is isolated from generated CV artifacts.

data "minio_iam_policy_document" "cv_facts_publisher" {
  statement {
    sid       = "CvFactsBucketDiscovery"
    effect    = "Allow"
    actions   = ["s3:GetBucketLocation", "s3:ListBucket"]
    principal = "*"
    resources = ["arn:aws:s3:::${local.cv_facts_bucket}"]
  }

  statement {
    sid       = "CvFactsManagement"
    effect    = "Allow"
    actions   = ["s3:DeleteObject", "s3:GetObject", "s3:PutObject"]
    principal = "*"
    resources = ["arn:aws:s3:::${local.cv_facts_bucket}/*"]
  }
}

resource "minio_iam_policy" "cv_facts_publisher" {
  name   = "${minio_iam_user.cv_facts_publisher.name}-policy"
  policy = data.minio_iam_policy_document.cv_facts_publisher.json
}

resource "minio_iam_user_policy_attachment" "cv_facts_publisher" {
  user_name   = minio_iam_user.cv_facts_publisher.id
  policy_name = minio_iam_policy.cv_facts_publisher.id
}
