output "bucket_name"         { value = aws_s3_bucket.app.bucket }
output "bucket_arn"          { value = aws_s3_bucket.app.arn }
output "cloudfront_domain"   { value = aws_cloudfront_distribution.app.domain_name }
output "cloudfront_id"       { value = aws_cloudfront_distribution.app.id }
