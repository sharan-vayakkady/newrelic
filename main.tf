terraform {
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "3.24.2"
    }
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

# Create an alert policy
resource "newrelic_alert_policy" "amazon_alerts" {
  name = "amazon alert"
}

resource "newrelic_synthetics_alert_condition" "ping_monito_conditionr" {
  policy_id = newrelic_alert_policy.amazon_alerts.id

  name        = "ping monitor"
  monitor_id  = newrelic_synthetics_monitor.ping_monitor.id
  runbook_url = "https://www.example.com"
}

resource "newrelic_notification_channel" "email_channel" {
  account_id = 3954397
  name = "email_channel_notification"
  type = "EMAIL"
  destination_id = "sharan.vayakkady@gmail.com"
  product = "IINT"

  property {
    key = "Website down"
    value = "website is down"
  }

  property {
    key = "customDetailsEmail"
    value = "issue id - {{issueId}}"
  }
}

resource "newrelic_alert_policy_channel" "email_policy" {
  policy_id  = [ 
    newrelic_alert_policy.amazon_alerts.id
  ]
  channel_ids = [
    newrelic_notification_channel.email_channel.id
  ]
}
