terraform {
  backend "s3" {
    key    = "ssv-github/synthetic/terraform-secret.tfstate"
    region = "us-east-1"
  }
}
