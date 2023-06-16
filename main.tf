terraform {
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "2.15.0"
    }
    http = {
      source = "hashicorp/http"
      version = "2.1.0"
    }
  }
  backend "s3" {
    bucket = "ssv-github"
    key    = "newrelic/terraform.tfstate"
    region = "us-east-1"
  }
}

# Declare input variables
variable "newrelic_api_key" {
  description = "API key for New Relic"
}

provider "newrelic" {
  api_key = var.newrelic_api_key
  account_id = 3954397
}

provider "newrelic" {
  api_key = "<your_newrelic_api_key>"
}

resource "newrelic_synthetics_monitor" "flipkart_monitor" {
  name         = "Flipkart Monitor"
  type         = "SCRIPT_BROWSER"
  frequency    = 15
  locations    = ["AWS_US_WEST_1"]

  options {
    validationString = "Shopping Cart"
  }

  script {
    type    = "SCRIPT"
    text    = <<EOF
    var assert = require('assert');
    $browser.get('https://www.flipkart.com/');
    $browser.wait($browser.waitForElement($driver.By.css('.cart-icon')))
      .then(function(element) {
        assert(element, 'Shopping Cart is not found');
      });
    EOF
  }
}

resource "newrelic_alert_channel" "email_alert" {
  name   = "Email Alert"
  type   = "email"
  config = {
    recipients = "sharan.vayakkady@gmail.com"
  }
}

resource "newrelic_alert_policy" "flipkart_monitor_policy" {
  name       = "Flipkart Monitor Policy"
  incident_preference = "PER_POLICY"
}

resource "newrelic_alert_condition" "flipkart_monitor_condition" {
  name                 = "Flipkart Monitor Condition"
  policy_id            = newrelic_alert_policy.flipkart_monitor_policy.id
  type                 = "synthetic_monitor"
  enabled              = true
  runbook_url          = "https://runbook.example.com"
  violation_close_timer = 10

  entities {
    name            = newrelic_synthetics_monitor.flipkart_monitor.name
    type            = "synthetic_monitor"
    condition_scope = "apps"
  }

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
