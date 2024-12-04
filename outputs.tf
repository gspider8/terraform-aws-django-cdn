output "bucket" {
  value = aws_s3_bucket.main
}

output "cdn" {
  value = aws_cloudfront_distribution.main
}

output "oac" {
  value = aws_cloudfront_origin_access_control.main
}

output "iam_user" {
  value = length(aws_iam_user.main) > 0 ? aws_iam_user.main[0] : null
}

output "iam_user_policy" {
  value = length(aws_iam_user_policy.main) > 0 ? aws_iam_user_policy.main[0] : null
}

output "iam_user_access" {
  value = length(aws_iam_access_key.main) > 0 ? aws_iam_access_key.main[0] : null
}