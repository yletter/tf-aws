terraform {
  backend "s3" {
    bucket = "tf-state-yuvaraj"
    region = "us-east-1"
    key    = "exercise13/terraform.tfstate"
    #profile = "saml"
  }
}
