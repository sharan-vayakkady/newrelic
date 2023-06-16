terraform {
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "2.15.0"
    }
  }
}

provider "newrelic" {
  api_key    = var.newrelic_api_key
  account_id = 3954397
}

resource "newrelic_synthetics_monitor" "flipkart_monitor" {
  name          = "Flipkart Monitor"
  type          = "SCRIPT_BROWSER"
  frequency     = 15
  locations     = ["AWS_US_WEST_1"]
  sla_threshold = 7

  script {
    script_type = "BROWSER"
    script_text = <<EOF
var assert = require('assert');
$browser.get('https://www.flipkart.com/');
$browser.waitForElement($driver.By.css('.cart-icon')).then(function(element) {
  assert(element, 'Shopping Cart is not found');
});
EOF
  }

  options {
    validation_string = "Shopping Cart"
  }
}

resource "newrelic_alert_channel" "email_alert" {
  name   = "Email Alert"
  type   = "email"

  config {
    recipients = "sharan.vayakkady@gmail.com"
  }
}

resource "newrelic_alert_policy" "flipkart_monitor_policy" {
  name                = "Flipkart Monitor Policy"
  incident_preference = "PER_POLICY"
}

resource "newrelic_alert_condition" "flipkart_monitor_condition" {
  name                 = "Flipkart Monitor Condition"
  policy_id            = newrelic_alert_policy.flipkart_monitor_policy.id
  type                 = "monitor"
  enabled              = true
  violation_time_limit = 10

  entities = [
    {
      name            = newrelic_synthetics_monitor.flipkart_monitor.name
      type            = "monitor"
      condition_scope = "apps"
    }
  ]

  terms {
    duration      = 5
    operator      = "above"
    priority      = "critical"
    threshold     = 0
    time_function = "all"

    notifications {
      channel_id = newrelic_alert_channel.email_alert.id
    }
  }
}
