module "process_claim_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.2.0"

  function_name = var.lambda_name
  handler       = "index.handler"
  runtime       = "python3.14"

  source_path = {
    path = "${path.root}/src/functions/process-claim"
    poetry_install = true
  }

  artifacts_dir = "builds"

  environment_variables = {

    DYNAMODB_TABLE = "${var.dynamodb_table_name}"
    S3_BUCKET      = "${var.s3_bucket_arn}"

  }
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = module.process_claim_function.lambda_function_arn
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_bucket_arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.s3_bucket_name

  lambda_function {
    lambda_function_arn = module.process_claim_function.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [module.process_claim_function,  aws_lambda_permission.allow_s3]
}
