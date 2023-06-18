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

provider "newrelic" {
  api_key    = "NRAK-P5ZRWJG8TH6LV2D9YQQT8AJ72PL"
  account_id = 3954397
}

resource "newrelic_synthetics_monitor" "ping_monitor" {
  name              = "Amazon Ping Monitor"
  type              = "SIMPLE"
  uri               = "https://www.sharan.com"
  locations_public  = ["AWS_US_WEST_1"]  # Updated attribute name
  status            = "ENABLED"
}

resource "newrelic_alert_channel" "email" {
  name = "email"
  type = "email"

  config {
    recipients              = "sharan.vayakkady@gmail.com"
    include_json_attachment = true  # Updated attribute value
  }
}

# Create an alert policy
resource "newrelic_alert_policy" "amazon_alerts" {
  name = "amazon alert"
}

resource "newrelic_alert_condition" "ping_monitor_condition" {
  name             = "Ping Monitor Failure"
  policy_id        = newrelic_alert_policy.amazon_alerts.id
  enabled          = true
  type             = "static"  # Updated attribute value
  entities         = [newrelic_synthetics_monitor.ping_monitor.id]
  metric           = "failure_rate"
  violation_time_limit_seconds = 600  # Added attribute
  terms {
    threshold            = 0
    time_function        = "all"
    duration             = 5
    operator             = "above"
    priority             = "critical"
    waiting_function     = "all"
    time_aggregation     = "all"
    evaluation_offset    = 0
    aggregation_window   = 0
    ignore_overlap       = true
    user_defined_metric  = ""
    metric_type          = "absolute"
    total_seconds        = 600
  }
}

# Link the channel to the policy
resource "newrelic_alert_policy_channel" "alert_email" {
  policy_id    = newrelic_alert_policy.amazon_alerts.id
  channel_ids  = [newrelic_alert_channel.email.id]
}
