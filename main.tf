terraform {
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "2.15.0"
    }
  }
}
# Configure the New Relic provider
provider "newrelic" {
  api_key = "92580C3C0C3CA75918151D8CACCB6A301946C4935E9C6E9D5189A6A19F7FA5CD"
  account_id  = "3954397"
}

# Create a synthetic monitor
resource "newrelic_synthetics_monitor" "sharan_com_monitor" {
  name              = "sharan.com ping"
  type              = "SIMPLE"
  frequency         = 15
  uri               = "https://www.sharan.com"
  locations         = ["AWS_US_WEST_1"]
  status            = "ENABLED"
  sla_threshold     = 7.0
  sla_failures_only = true
}
