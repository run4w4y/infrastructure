locals {
  ente_username               = "ente"
  share_username              = "share"
  share_bucket                = "share"
  cv_registry_username        = "cv-registry"
  cv_pdf_worker_username      = "cv-pdf-worker"
  cv_facts_publisher_username = "cv-facts-publisher"
  cv_objects_bucket           = "cv-objects"
  cv_facts_bucket             = "cv-facts"
  ente_buckets = [
    "b2-eu-cen",
    "wasabi-eu-central-2-v3",
    "scw-eu-fr-v3"
  ]
  ente_bucket_prefix = "ente-"
}
