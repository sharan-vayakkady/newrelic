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
  status           = "ENABLED"
  name             = "monitor"
  period           = "EVERY_MINUTE"
  uri              = "https://amazon.com"
  type             = "SIMPLE"
  locations_public = ["AP_SOUTH_1"]

  treat_redirect_as_failure = true
  validation_string         = "success"
  bypass_head_request       = true
  verify_ssl                = true
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
  policy_id = newrelic_alert_policy.amazon_alerts.id

  name        = "Ping Monitor Failure"
  type        = "apm_app_metric"
  entities    = [tonumber(newrelic_synthetics_monitor.ping_monitor.id)]
  metric      = "apdex"
  runbook_url = "https://www.example.com"
  condition_scope = "application"

  term {
    duration      = 5
    operator      = "below"
    priority      = "critical"
    threshold     = "0.75"
    time_function = "all"
  }
}

# Link the channel to the policy
resource "newrelic_alert_policy_channel" "alert_email" {
  policy_id    = newrelic_alert_policy.amazon_alerts.id
  channel_ids  = [newrelic_alert_channel.email.id]
}
