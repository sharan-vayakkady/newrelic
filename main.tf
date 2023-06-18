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
  api_base   = "https://api.newrelic.com"
  auth_header = "Bearer"
}

# Create an alert policy
resource "newrelic_alert_policy" "alert" {
  name = "Your Concise Alert Name"
}

resource "newrelic_synthetics_monitor" "amazon_com_monitor" {
  name          = "amazon.com ping"
  type          = "SIMPLE"
  frequency     = 15
  uri           = "https://www.amazon.com"
  locations     = ["AWS_US_WEST_1"]
  status        = "ENABLED"
}

resource "newrelic_alert_condition" "monitor_failure_condition" {
  policy_id = newrelic_alert_policy.alert.id
  name      = "Monitor Failure"
  enabled   = true

  entities = [newrelic_synthetics_monitor.amazon_com_monitor.id]

  term {
    duration      = 1
    priority      = "critical"
    operator      = "above"
    threshold     = 0
    time_function = "all"
  }
}

resource "newrelic_notification_channel" "email" {
  name     = "email"
  type     = "email"

  config {
    email_recipients = "sharan.vayakkady@gmail.com"
  }
}

# Link the channel to the policy
resource "newrelic_alert_policy_channel" "alert_email" {
  policy_id   = newrelic_alert_policy.alert.id
  channel_ids = [newrelic_notification_channel.email.id]
}
