output "bucket_id" {
  value = aws_s3_bucket.claims.id
}

output "bucket_arn" {
  value = aws_s3_bucket.claims.arn
}

output "bucket_name" {
  value = var.bucket_name
}
