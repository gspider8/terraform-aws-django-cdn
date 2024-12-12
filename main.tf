resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Enabled"
  }
}

# resource "aws_s3_bucket_public_access_block" "main" {
#   bucket = aws_s3_bucket.main.id
#
#   block_public_acls       = true
#   ignore_public_acls      = true
#   block_public_policy     = true
#   restrict_public_buckets = true
# }

# CORS Policy for CloudFront
data "aws_cloudfront_response_headers_policy" "simple_cors" {
  name = "Managed-SimpleCORS"
}

resource "aws_cloudfront_distribution" "main" {
  origin {
    domain_name              = aws_s3_bucket.main.bucket_regional_domain_name
    origin_id                = var.origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.main.id

    origin_shield {
      enabled              = true
      origin_shield_region = "us-east-1"
    }
  }
  enabled         = true
  is_ipv6_enabled = true
  default_cache_behavior {
    target_origin_id           = var.origin_id
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.simple_cors.id
    cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # CachingDisabled
    allowed_methods            = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods             = ["GET", "HEAD"]

    viewer_protocol_policy = "https-only"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

# Create an Origin Access Control to Eliminate access to bucket over public internet
resource "aws_cloudfront_origin_access_control" "main" {
  name                              = "${var.origin_id}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_iam_policy_document" "oac" {
  statement {
    sid    = "OAC"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${aws_s3_bucket.main.arn}/*"
    ]
    condition {
      variable = "AWS:SourceArn"
      test     = "StringEquals"
      values = [
        aws_cloudfront_distribution.main.arn
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "oac" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.oac.json
  #   depends_on = [aws_s3_bucket_public_access_block.main]
}

# -- iam --
data "aws_iam_policy_document" "django_user" {
  statement {
    sid    = "1"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucketVersions"
    ]
    resources = [
      aws_s3_bucket.main.arn
    ]
  }
  statement {
    sid    = "2"
    effect = "Allow"
    actions = [
      "s3:*Object*",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload"
    ]
    resources = [
      "${aws_s3_bucket.main.arn}/*"
    ]
  }
}

resource "aws_iam_user" "main" {
  count = var.iam_user.create ? 1 : 0
  name  = var.iam_user.name
  path  = "/users/"
  tags  = var.tags
}

resource "aws_iam_user_policy" "main" {
  count  = var.iam_user.create ? 1 : 0
  user   = aws_iam_user.main[count.index].name
  policy = data.aws_iam_policy_document.django_user.json
  name   = "${var.iam_user.name}-policy"
}

resource "aws_iam_access_key" "main" {
  count = var.iam_user.create ? 1 : 0
  user  = aws_iam_user.main[count.index].name
}
