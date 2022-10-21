variable "aws_region" {
  type = string
}

variable "domain_name" {
  type = string
}


module "website" {
  source      = "./.deploy/terraform/static-site"
  domain_name = var.domain_name
}
