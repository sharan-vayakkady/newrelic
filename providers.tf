provider "aws" {
  region                   = local.region
  shared_credentials_files = ["~/.aws/config", "~/.aws/credentials"]
  profile                  = local.profile
  default_tags {
    tags = {
      createdby = "terraform"
      team      = "devops"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.51.0"
    }
  }

  required_version = "= 1.3.7"
}

