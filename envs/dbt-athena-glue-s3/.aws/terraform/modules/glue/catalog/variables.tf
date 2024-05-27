variable "catalog_id" {
  description = "The catalog ID for the Glue Catalog Database"
  type        = string
  default     = null
}

variable "database_names" {
  description = "The names of the databases to create"
  type        = list(string)
  default     = []
}
