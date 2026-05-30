terraform {
  backend "s3" {
    bucket = "tf-state-yuvaraj"
    region = "us-east-1"
    key    = "exercise15/terraform.tfstate"
  }
}
