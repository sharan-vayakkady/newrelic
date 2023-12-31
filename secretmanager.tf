resource "aws_secretsmanager_secret" "slack_webhook" {
  description = "Slack webhook for enabling notification"
  name        = "/ecomm/synthetic-monitor-qa/slack_webhook"
  tags = module.slack_webhook_url_label.tags
}

resource "aws_secretsmanager_secret" "newrelic_api_key" {
  description = "Newrelic api key to enable or disable QA synthetic monitor"
  name        = "/ecomm/synthetic-monitor-qa/newrelic-api"
  tags = {
    createdby = "terraform"
    team      = "devops"
  }
}

