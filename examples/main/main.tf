# --- Providers ----

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# --- Variables ---

variable "project_name" { default = "aws-django-cdn-example-main" }
variable "create_iam_user" { type = bool }

# --- Module ---

module "django-cdn" {
  source = "../../"

  bucket_name = "${var.project_name}-django-cdn"
  origin_id   = "${var.project_name}-bucket"


  iam_user = {
    create = var.create_iam_user
    name   = "${var.project_name}-django-cdn-access"
  }

  tags = {
    Terraform   = "True"
    Environment = "Development"
    Project     = var.project_name
  }
}

# --- Outputs ---

output "django-cdn-bucket_name" {
  value = module.django-cdn.bucket.bucket
}

output "django-cdn-cdn_domain" {
  value = module.django-cdn.cdn.domain_name
}

output "django-cdn-iam_credentials" {
  value = "${module.django-cdn.iam_user_access.id}, (secret)"
}