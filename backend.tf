terraform {
  backend "s3" {
    key    = "alo-terraform/ecommerce/roles/synthetic-monitor-qa.tfstate"
    region = "us-east-1"
  }
}
