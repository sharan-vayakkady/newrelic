module "slack_webhook_url_label" {
  source      = "registry.terraform.io/cloudposse/label/null"
  version     = "0.25.0"
  namespace   = "alo"
  environment = "dev"
  name        = "secrets-manager"
  attributes  = ["ecomm", "qa-synthetic-monitor"]
  tags = {
    project          = "ecomm"
    team_name        = "SRE"
    environment      = "dev"
    application_role = "secrets-manager"
    repository       = "https://github.com/colorimageapparel/alo-dev"
  }
}