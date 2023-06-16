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
  api_key    = "NRAK-P5ZRWJG8TH6LV2D9YQQT8AJ72PL"
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

# Create a notification channel for Slack
resource "newrelic_alert_channel" "slack_channel" {
  name   = "slack-channel"
  type   = "slack"
  config = {
    webhook_url = "https://hooks.slack.com/services/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"
  }
}

# Create an alert policy for the monitor
resource "newrelic_alert_policy" "monitor_failure_policy" {
  name  = "Monitor Failure"
  event = true
  conditions {
    name          = "Monitor Failure"
    enabled       = true
    terms {
      duration     = 1
      priority     = "critical"
      operator     = "above"
      threshold    = 0
      time_function = "all"
    }
    violation_time_limit = 5
    evaluation_offset   = 0
  }
  channels {
    channel_id = newrelic_alert_channel.slack_channel.id
  }
}

# Associate the alert policy with the monitor
resource "newrelic_synthetics_monitor_alert_policy" "flipkart_com_monitor_policy" {
  monitor_id   = newrelic_synthetics_monitor.flipkart_com_monitor.id
  policy_id    = newrelic_alert_policy.monitor_failure_policy.id
  priority     = "critical"
  enabled      = true
  violation_close_timer = 5
}
