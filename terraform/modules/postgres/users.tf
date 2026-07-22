# ente postgres role / user

resource "postgresql_role" "ente" {
  name            = "ente"
  login           = true
  password        = random_password.ente_postgres.result
  superuser       = false
  create_database = false
  create_role     = false
  inherit         = true
  replication     = false
}

# grant connect to the ente database

resource "postgresql_grant" "ente_connect" {
  database    = postgresql_database.ente.name
  role        = postgresql_role.ente.name
  object_type = "database"
  privileges  = ["CONNECT"]
}

# grant public schema usage

resource "postgresql_grant" "ente_schema_usage" {
  database    = postgresql_database.ente.name
  schema      = "public"
  role        = postgresql_role.ente.name
  object_type = "schema"
  privileges  = ["USAGE"]
}

# grant access to any existing tables in the public schema

resource "postgresql_grant" "ente_tables" {
  database    = postgresql_database.ente.name
  schema      = "public"
  role        = postgresql_role.ente.name
  object_type = "table"
  privileges  = ["ALL"]
}

# CV application registry role and grants. The application role owns its
# database and creates all tables through the checked-in migration history.

resource "postgresql_role" "cv_registry" {
  name            = "cv_registry"
  login           = true
  password        = random_password.cv_registry_postgres.result
  superuser       = false
  create_database = false
  create_role     = false
  inherit         = true
  replication     = false
}

resource "postgresql_grant" "cv_registry_connect" {
  database    = postgresql_database.cv_registry.name
  role        = postgresql_role.cv_registry.name
  object_type = "database"
  # Drizzle owns its migration journal schema in this dedicated database.
  # Managing the database ACL with CONNECT alone revokes the owner's implicit
  # CREATE privilege, so keep the schema-owning application role explicit.
  privileges = ["CONNECT", "CREATE"]
}

resource "postgresql_grant" "cv_registry_schema" {
  database    = postgresql_database.cv_registry.name
  schema      = "public"
  role        = postgresql_role.cv_registry.name
  object_type = "schema"
  privileges  = ["USAGE", "CREATE"]
}

# The periodic checker can read and mutate registry rows but cannot create
# schema objects, delete data, or administer another role.

resource "postgresql_role" "cv_listing_checker" {
  name            = "cv_listing_checker"
  login           = true
  password        = random_password.cv_listing_checker_postgres.result
  superuser       = false
  create_database = false
  create_role     = false
  inherit         = true
  replication     = false
}

resource "postgresql_grant" "cv_listing_checker_connect" {
  database    = postgresql_database.cv_registry.name
  role        = postgresql_role.cv_listing_checker.name
  object_type = "database"
  privileges  = ["CONNECT"]
}

resource "postgresql_grant" "cv_listing_checker_schema" {
  database    = postgresql_database.cv_registry.name
  schema      = "public"
  role        = postgresql_role.cv_listing_checker.name
  object_type = "schema"
  privileges  = ["USAGE"]
}

resource "postgresql_grant" "cv_listing_checker_tables" {
  database    = postgresql_database.cv_registry.name
  schema      = "public"
  role        = postgresql_role.cv_listing_checker.name
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE"]
}

resource "postgresql_default_privileges" "cv_listing_checker_tables" {
  database    = postgresql_database.cv_registry.name
  owner       = postgresql_role.cv_registry.name
  role        = postgresql_role.cv_listing_checker.name
  schema      = "public"
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE"]
}

# The PDF worker reads publication state and owns generated-artifact state. It
# can mutate registry rows but cannot create schema objects, delete data, or
# administer another role.

resource "postgresql_role" "cv_pdf_worker" {
  name            = "cv_pdf_worker"
  login           = true
  password        = random_password.cv_pdf_worker_postgres.result
  superuser       = false
  create_database = false
  create_role     = false
  inherit         = true
  replication     = false
}

resource "postgresql_grant" "cv_pdf_worker_connect" {
  database    = postgresql_database.cv_registry.name
  role        = postgresql_role.cv_pdf_worker.name
  object_type = "database"
  privileges  = ["CONNECT"]
}

resource "postgresql_grant" "cv_pdf_worker_schema" {
  database    = postgresql_database.cv_registry.name
  schema      = "public"
  role        = postgresql_role.cv_pdf_worker.name
  object_type = "schema"
  privileges  = ["USAGE"]
}

resource "postgresql_grant" "cv_pdf_worker_tables" {
  database    = postgresql_database.cv_registry.name
  schema      = "public"
  role        = postgresql_role.cv_pdf_worker.name
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE"]
}

resource "postgresql_default_privileges" "cv_pdf_worker_tables" {
  database    = postgresql_database.cv_registry.name
  owner       = postgresql_role.cv_registry.name
  role        = postgresql_role.cv_pdf_worker.name
  schema      = "public"
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE"]
}
