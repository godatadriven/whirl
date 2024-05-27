# Setup buckets for hub-spoke model DBT and Athena
resource "aws_s3_bucket" "hub-raw-source-bucket" {
    bucket = "hub-raw-source-bucket"
}

resource "aws_s3_bucket" "hub-unified-source-bucket" {
    bucket = "hub-unified-source-bucket"
}

resource "aws_s3_bucket" "spoke-transformed-bucket" {
    bucket = "spoke-transformed-bucket"
}

resource "aws_s3_bucket" "hub-athena-queryresults-bucket" {
    bucket = "hub-athena-queryresults-bucket"
}

resource "aws_s3_bucket" "spoke-athena-queryresults-bucket" {
    bucket = "spoke-athena-queryresults-bucket"
}

# Setup Glue
module "hub_catalog" {
    source = "./modules/glue/catalog/"

    database_names = [
        "raw",
        "unified",
        "transformation-spoke",
    ]
}

module "raw_crawler" {
    source = "./modules/glue/crawler/"

    name          = "HubRawSourceCrawler"
    s3_targets    = [
        { path = "s3://${aws_s3_bucket.hub-raw-source-bucket.bucket}/yellow" },
        { path = "s3://${aws_s3_bucket.hub-raw-source-bucket.bucket}/data" }
    ]
    role          = "AWSGlueServiceRole"
    database_name = "raw"
    configuration = jsonencode(
    {
      Version = 1
      CreatePartitionIndex = false
      Grouping = {
        TableLevelConfiguration = 1
      }
    }

    )
}

# Setup Athena
