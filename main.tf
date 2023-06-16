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

provider "newrelic" {
  api_key = var.newrelic_api_key
  account_id = 3954397
}

resource "newrelic_synthetics_monitor" "example_monitor" {
  name        = "Example Monitor"
  frequency   = 15
  uri         = "https://www.example.com"
  locations   = ["AWS_US_WEST_2"]
  status      = "ENABLED"
  sla         = 5
  type        = "SIMPLE"
  security_policies = ["TRUSTED_CERTIFICATE"]
}

resource "newrelic_synthetics_notification_channel" "example_channel" {
  name      = "Example Channel"
  type      = "Email"
  config    = {
    recipients = "sharan.vayakkady@gmail.com"
  }
}

resource "newrelic_synthetics_monitor_channel" "example_monitor_channel" {
  monitor_id            = newrelic_synthetics_monitor.example_monitor.id
  channel_ids           = [newrelic_synthetics_notification_channel.example_channel.id]
  types                 = ["ALERT"]
  escalation_policy_ids = []
}
