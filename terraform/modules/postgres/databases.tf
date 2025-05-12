resource "postgresql_database" "ente" {
  name  = "ente_db"
  owner = postgresql_role.ente.name
}
