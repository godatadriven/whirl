variable "name" {
  description = "The name of the AWS Glue Crawler"
  type        = string
}

variable "database_name" {
  description = "The name of the database for the AWS Glue Crawler"
  type        = string
}

variable "configuration" {
  description = "The configuration for the AWS Glue Crawler"
  type        = string
  default     = "{\"Version\":1.0,\"CreatePartitionIndex\":false}"
}

# using caller account id for now
# variable "account_id" {
#     description = "The account ID for the AWS Glue Crawler"
#     type        = string
# }

variable "crawler_lineage_settings" {
  description = "The lineage settings for the AWS Glue Crawler"
  type        = string
  default     = "DISABLE"
}

variable "recrawl_behavior" {
  description = "The recrawl behavior for the AWS Glue Crawler"
  type        = string
  default     = "CRAWL_EVERYTHING"
}

variable "role" {
  description = "The role for the AWS Glue Crawler"
  type        = string
}

variable "s3_targets" {
  description = "The S3 targets"
  type = list(object({
    path = string
  }))
}

variable "delete_behavior" {
  description = "The delete behavior for the AWS Glue Crawler"
  type        = string
  default     = "DEPRECATE_IN_DATABASE"
}

variable "update_behavior" {
  description = "The update behavior for the AWS Glue Crawler"
  type        = string
  default     = "UPDATE_IN_DATABASE"
}

variable "tags" {
  description = "Tags added to the bucket and the user"
  type        = map(string)
  default     = {}
}
