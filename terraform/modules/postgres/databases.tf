resource "postgresql_database" "ente" {
  name  = "ente_db"
  owner = postgresql_role.ente.name
}

resource "postgresql_database" "cv_registry" {
  name  = "cv_registry"
  owner = postgresql_role.cv_registry.name

  lifecycle {
    prevent_destroy = true
  }
}
