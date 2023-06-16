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


provider "newrelic" {
  api_key = "NRAK-P5ZRWJG8TH6LV2D9YQQT8AJ72PL"
}

# Resource: New Relic Synthetics Monitor

resource "newrelic_synthetics_monitor" "flipkart_com_monitor" {
  name           = "Flipkart.com"
  type           = "SIMPLE"
  frequency      = 15
  uri            = "https://www.flipkart.com/"
  locations      = ["AWS_US_WEST_2"]
  status         = "ENABLED"
  sla_threshold  = 7
  follow_redirects = false
}

# Resource: New Relic Alert Channel (Slack)

resource "newrelic_alert_channel" "slack_channel" {
  name     = "Slack Channel"
  type     = "slack"
  enabled  = true
  api_url  = "https://hooks.slack.com/services/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"
}

# Resource: New Relic Alert Policy

resource "newrelic_alert_policy" "monitor_failure_policy" {
  name     = "Monitor Failure Policy"
  incident_preference = "PER_POLICY"
}

# Resource: New Relic Alert Condition

resource "newrelic_alert_condition" "monitor_failure_condition" {
  policy_id = newrelic_alert_policy.monitor_failure_policy.id
  name      = "Monitor Failure"
  enabled   = true
  type      = "static"
  metric    = "apdex"

  term {
    duration      = "5"
    operator      = "above"
    priority      = "critical"
    threshold     = "0"
    time_function = "all"
  }

  entities = [
    {
      name = "${newrelic_synthetics_monitor.flipkart_com_monitor.name}"
      type = "Monitor"
    }
  ]
}

# Output: Monitor ID

output "monitor_id" {
  value = newrelic_synthetics_monitor.flipkart_com_monitor.id
}
