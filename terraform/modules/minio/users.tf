resource "minio_iam_user" "ente" {
  name = local.ente_username
}

resource "minio_iam_user" "share" {
  name = local.share_username
}

resource "minio_iam_user" "cv_registry" {
  name = local.cv_registry_username
}

resource "minio_iam_user" "cv_pdf_worker" {
  name = local.cv_pdf_worker_username
}

resource "minio_iam_user" "cv_facts_publisher" {
  name = local.cv_facts_publisher_username
}
