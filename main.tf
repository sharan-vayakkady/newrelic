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
  locations_public  = ["AWS_US_WEST_1"]
  status            = "ENABLED"
}

resource "newrelic_alert_channel" "email" {
  name = "email"
  type = "email"

  config {
    recipients              = "sharan.vayakkady@gmail.com"
    include_json_attachment = "1"
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
  type             = "servers_metric"
  entities         = [newrelic_synthetics_monitor.ping_monitor.id]
  metric           = "failure_rate"
  term {
    threshold = 0
    duration  = 5
    operator  = "above"
    priority  = "critical"
    time_function = "all"
  }
}


# Link the channel to the policy
resource "newrelic_alert_policy_channel" "alert_email" {
  policy_id  = newrelic_alert_policy.amazon_alerts.id
  channel_ids = [
    newrelic_alert_channel.email.id
  ]
}
