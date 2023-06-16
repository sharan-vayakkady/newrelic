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
resource "newrelic_synthetics_monitor_channel" "slack_channel" {
  monitor_id = newrelic_synthetics_monitor.flipkart_com_monitor.id
  channel_id = newrelic_alert_channel.slack_channel.id
}

# Create an alert policy for the monitor
resource "newrelic_alert_policy" "monitor_failure_policy" {
  name        = "Monitor Failure"
  incident_preference = "PER_POLICY"
}

# Create an alert condition for the monitor
resource "newrelic_synthetics_alert_condition" "monitor_failure_condition" {
  policy_id   = newrelic_alert_policy.monitor_failure_policy.id
  monitor_id  = newrelic_synthetics_monitor.flipkart_com_monitor.id
  name        = "Monitor Failure"
  enabled     = true
  metric      = "duration"
  
  violation_time_limit = 5

  terms {
    duration          = 1
    priority          = "critical"
    operator          = "above"
    threshold         = 0
    waiting_duration  = 0
  }
}
