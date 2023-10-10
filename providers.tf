provider "aws" {
  region                   = local.region
  #shared_credentials_files = ["~/.aws/config", "~/.aws/credentials"]
  #profile                  = local.profile
  default_tags {
    tags = {
      createdby = "terraform"
      team      = "devops"
    }
  }
}

