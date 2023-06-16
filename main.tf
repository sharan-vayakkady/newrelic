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
  config {
    webhook_url = "https://hooks.slack.com/services/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"
  }
}

# Create an alert policy for the monitor
resource "newrelic_alert_policy" "monitor_failure_policy" {
  name                  = "Monitor Failure"
  incident_preference   = "PER_POLICY"
  notification_channel_ids = [newrelic_alert_channel.slack_channel.id]
}

# Create an alert condition for the monitor
resource "newrelic_alert_condition" "monitor_failure_condition" {
  policy_id = newrelic_alert_policy.monitor_failure_policy.id
  name      = "Monitor Failure"
  enabled   = true
  type      = "static"
  entities {
    name = newrelic_synthetics_monitor.flipkart_com_monitor.name
    type = "Monitor"
  }

  term {
    duration         = 1
    priority         = "critical"
    operator         = "above"
    threshold        = 0
    time_function    = "all"
    waiting_duration = 0
  }
}
