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
data "external" "create_notification_channel" {
  program = ["bash", "-c", <<EOT
    curl -X POST \
      -H "Api-Key: ${var.newrelic_api_key}" \
      -H "Content-Type: application/json" \
      -d '{
        "name": "Email Notification Channel",
        "type": "email",
        "configuration": {
          "recipients": "sharan.vayakkady@gmail.com"
        }
      }' \
      "https://synthetics.newrelic.com/synthetics/api/v4/monitors/${newrelic_synthetics_monitor.flipkart_com_monitor.id}/notification-channels"
  EOT
  ]
}

# Apply the configuration
output "notification_channel_response" {
  value = data.external.create_notification_channel.result
}
