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

resource "newrelic_alert_policy" "amazon_alerts" {
  name                = "amazon alert"
  incident_preference = "PER_CONDITION"
}
resource "newrelic_notification_destination" "email_destination" {
  account_id = 3954397
  name = "email-example"
  type = "EMAIL"

  property {
    key = "email"
    value = "sharan.vayakkady@gmail.com"
  }
}
resource "newrelic_notification_channel" "foo" {
  account_id = 3954397
  name = "email-example"
  type = "EMAIL"
  destination_id = newrelic_notification_destination.email_destination.id
  product = "IINT"

  property {
    key = "subject"
    value = "New Subject Title"
  }

  property {
    key = "customDetailsEmail"
    value = "issue id - {{issueId}}"
  }
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

resource "newrelic_synthetics_alert_condition" "ping_monitor_condition" {
  policy_id    = newrelic_alert_policy.amazon_alerts.id
  name         = "ping monitor"
  monitor_id   = newrelic_synthetics_monitor.ping_monitor.id
  runbook_url  = "https://www.example.com"
}

