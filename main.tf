terraform {
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "3.24.2"
    }
  }
  backend "s3" {
    bucket = "ssv-github"
    key    = "synthetic/terraform.tfstate"
    region = "us-east-1"
  }
}
provider "newrelic" {
  api_key    = "NRAK-P5ZRWJG8TH6LV2D9YQQT8AJ72PL"
  account_id = 3954397
}
resource "newrelic_alert_policy" "domain_alerts" {
  name                = "my_policy"
  incident_preference = "PER_CONDITION"
}
resource "newrelic_notification_destination" "email_destination" {
  account_id = 3954397
  name = "my_destination"
  type = "EMAIL"

  property {
    key = "email"
    value = "sharan.vayakkady@gmail.com"
  }
}
resource "newrelic_notification_channel" "email_notification" {
  account_id = 3954397
  name = "my_notification_channel"
  type = "EMAIL"
  destination_id = newrelic_notification_destination.email_destination.id
  product = "IINT"

  property {
    key = "subject"
    value = "Monitor down"
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
  uri              = "https://sharan12345.com"
  type             = "SIMPLE"
  locations_public = ["AP_SOUTH_1"]

  treat_redirect_as_failure = true
  validation_string         = "success"
  bypass_head_request       = true
  verify_ssl                = true
}

resource "newrelic_synthetics_alert_condition" "ping_monitor_condition" {
  policy_id    = newrelic_alert_policy.domain_alerts.id
  name         = "my_condition"
  monitor_id   = newrelic_synthetics_monitor.ping_monitor.id
  runbook_url  = "https://www.example.com"
}
resource "newrelic_workflow" "my_workflow" {
  name = "my_workflows"
  muting_rules_handling = "NOTIFY_ALL_ISSUES"
  issues_filter {
    name = "my_filter"
    type = "FILTER"

    predicate {
      attribute = "labels.policyIds"
      operator = "EXACTLY_MATCHES"
      values = [ newrelic_alert_policy.domain_alerts.id ]
    }
  }
  destination {
    channel_id = newrelic_notification_channel.email_notification.id
  }
}

