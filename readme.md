# Django CDN Module
A Terraform module to provide a Django S3/CloudFront Configuration in AWS
Current Version: 0.0.1

## Module Input Variables
- `bucket_name` - Name of bucket acting as the origin for the CloudFront dist.
- `origin_id` - Origin ID of bucket acting as the origin for the CloudFront dist.
- `iam_user` - Map with information regarding the iam_user
  - `create` - true / false
  - `name` - Required if `create=true`, name of IAM User
- `tags` - Map of key/value pairs to tag certain created items

### Usage
```terraform
module "django-cdn" {
  source = "github.com/gspider8/terraform-aws-django-cdn?ref=v0.0.1"

  bucket_name = "${var.project_name}-django-cdn"
  origin_id   = "${var.project_name}-bucket"


  iam_user = {
    create = true
    name = "${var.project_name}-django-cdn-access"
  }

  tags= {
    Terraform = "True"
    Project = var.project_name
  }
}

output "django-cdn-bucket_name" {
  value = module.django-cdn.bucket.bucket
}

output "django-cdn-cdn_domain" {
  value = module.django-cdn.cdn.domain_name
}

output "django-cdn-iam_credentials" {
  value = "${module.django-cdn.iam_user_access.id}, (secret)"
}
```

### Outputs
- `bucket` - Bucket Map
- `cdn` - CloudFront Distribution Map
- `oac` - Origin Access Control Map
- `iam_user` - IAM User Map
- `iam_user_policy` - IAM User Policy Map
- `iam_user_access` - IAM User Access Key Map

### Authors
- gspider8

### Limitations
- One Origin that is created by this module
- Caching is disabled (is only really acting as a proxy)
