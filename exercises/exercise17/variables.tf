variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "us-east-1"
}

variable "saml_metadata_file" {
  description = "The path to the SAML metadata file"
  type        = string
  default     = "saml-metadata.xml"
}