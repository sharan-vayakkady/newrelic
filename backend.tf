terraform {
   backend "s3" {
     bucket = "ssv-github"
     key    = "synthetic/terraform_secret.tfstate"
     region = "us-east-1"
  }
}
