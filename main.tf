terraform {
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "2.15.0"
    }
  }
  backend "s3" {
    bucket = "ssv-github"
    key    = "newrelic/terraform.tfstate"
    region = "us-east-1"
  }
}
# Configure the New Relic provider
provider "newrelic" {
  api_key = "NRAK-P5ZRWJG8TH6LV2D9YQQT8AJ72PL"
  account_id  = "3954397"
}

# Create a synthetic monitor
resource "newrelic_synthetics_monitor" "flipkart_com_monitor" {
  name              = "flipkart1.com ping"
  type              = "SIMPLE"
  frequency         = 15
  uri               = "https://www.flipkart1.com"
  locations         = ["AWS_US_WEST_1"]
  status            = "ENABLED"
  sla_threshold     = 7.0
}
