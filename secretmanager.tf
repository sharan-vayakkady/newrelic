resource "aws_secretsmanager_secret" "slack_webhook" {
  description = "Slack webhook for enabling notification"
  name        = "/ecomm/synthetic-monitor-qa/slack_webhook"
  tags = {
    createdby = "terraform"
    team      = "devops"
  }
}

resource "aws_secretsmanager_secret" "newrelic_api" {
  description = "Newrelic api key to enable or disable QA synthetic monitor"
  name        = "/ecomm/synthetic-monitor-qa/newrelic-api-key"
  tags = {
    createdby = "terraform"
    team      = "devops"
  }
}

