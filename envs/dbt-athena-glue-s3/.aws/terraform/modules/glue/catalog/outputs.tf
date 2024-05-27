output "catalog_database_arns" {
  description = "The ARNs of the Glue Catalog Databases"
  value       = { for db in aws_glue_catalog_database.database : db.name => db.arn }
}

output "catalog_database_ids" {
  description = "The IDs of the Glue Catalog Databases"
  value       = { for db in aws_glue_catalog_database.database : db.name => db.id }
}

output "catalog_database_names" {
  description = "The names of the Glue Catalog Databases"
  value       = keys(aws_glue_catalog_database.database)
}
