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

# Create a notification channel for Slack
resource "newrelic_alert_channel" "slack_channel" {
  name   = "slack-channel"
  type   = "slack"
  slack {
    webhook_url = "https://hooks.slack.com/services/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"
  }
}

# Create an alert policy for the monitor
resource "newrelic_alert_policy" "monitor_failure_policy" {
  name                 = "Monitor Failure"
  violation_time_limit = 5
  evaluation_offset    = 0
}

resource "newrelic_alert_condition" "monitor_failure_condition" {
  policy_id = newrelic_alert_policy.monitor_failure_policy.id

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

resource "newrelic_alert_channel_policy" "monitor_failure_channel_policy" {
  policy_id    = newrelic_alert_policy.monitor_failure_policy.id
  channel_ids = [newrelic_alert_channel.slack_channel.id]
}
