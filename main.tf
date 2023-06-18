terraform {
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "3.24.2"
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
  api_key    = "NRAK-P5ZRWJG8TH6LV2D9YQQT8AJ72PL"
  account_id = "3954397"
}

# Create a synthetic monitor
resource "newrelic_synthetics_monitor" "amazon_com_monitor" {
  name          = "amazon.com ping"
  type          = "SIMPLE"
  frequency     = 15
  uri           = "https://www.amazon.com"
  locations     = ["AWS_US_WEST_1"]
  status        = "ENABLED"
  sla_threshold = 7.0
}

# Create an alert policy
resource "newrelic_alert_policy" "alert" {
  name = "Your Concise Alert Name"
}

resource "newrelic_alert_condition" "monitor_failure_condition" {
  policy_id = newrelic_alert_policy.alert.id

  name    = "Monitor Failure"
  enabled = true

  terms {
    duration      = 1
    priority      = "critical"
    operator      = "above"
    threshold     = 0
    time_function = "all"
  }
}

resource "newrelic_alert_channel" "email" {
  name = "email"
  type = "email"

  config {
    recipients              = "sharan.vayakkady@gmail.com"
    include_json_attachment = true
  }
}

# Link the channel to the policy
resource "newrelic_alert_policy_channel" "alert_email" {
  policy_id  = newrelic_alert_policy.alert.id
  channel_ids = [
    newrelic_alert_channel.email.id
  ]
}
