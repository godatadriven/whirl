data "aws_caller_identity" "current" {}

resource "aws_glue_crawler" "crawler" {
  configuration = var.configuration
  database_name = var.database_name

  lineage_configuration {
    crawler_lineage_settings = var.crawler_lineage_settings
  }

  name = var.name

  recrawl_policy {
    recrawl_behavior = var.recrawl_behavior
  }

  role = var.role

  dynamic "s3_target" {
    for_each = var.s3_targets
    content {
      path = s3_target.value.path
    }
  }

  schema_change_policy {
    delete_behavior = var.delete_behavior
    update_behavior = var.update_behavior
  }

  tags = var.tags
}
