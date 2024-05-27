resource "aws_glue_catalog_database" "database" {
  for_each = toset(var.database_names)

  catalog_id = var.catalog_id
  name       = each.value
}
