resource "minio_iam_user" "ente" {
  name = local.ente_username
}

resource "minio_iam_user" "share" {
  name = local.share_username
}
