terraform {
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "2.15.0"
    }
    http = {
      source = "hashicorp/http"
      version = "2.1.0"
    }
  }
  backend "s3" {
    bucket = "ssv-github"
    key    = "newrelic/terraform.tfstate"
    region = "us-east-1"
  }
}

# Declare input variables
variable "newrelic_api_key" {
  description = "API key for New Relic"
}

# Configure the New Relic provider
provider "newrelic" {
  api_key    = var.newrelic_api_key
  account_id = "3954397"
}

# Create a synthetic monitor
resource "newrelic_synthetics_monitor" "flipkart_com_monitor" {
  name          = "flipkart1.com ping"
  type          = "SIMPLE"
  frequency     = 15
  uri           = "https://www.flipkart1.com"
  locations     = ["AWS_US_WEST_1"]
  status        = "ENABLED"
  sla_threshold = 7.0
}

# Configure email notification channel using New Relic REST API
provider "http" {
  follow_redirects = true
}

data "http" "create_notification_channel" {
  url = "https://synthetics.newrelic.com/synthetics/api/v3/monitors/${newrelic_synthetics_monitor.flipkart_com_monitor.id}/notification-channels"
  method  = "POST"
  headers = {
    "Api-Key"       = var.newrelic_api_key
    "Content-Type"  = "application/json"
  }
  body = jsonencode({
    name = "Email Notification Channel"
    type = "email"
    configuration = {
      recipients = "sharan.vayakkady@gmail.com"
    }
  })
}

# Apply the configuration
output "notification_channel_response" {
  value = data.http.create_notification_channel.body
}
