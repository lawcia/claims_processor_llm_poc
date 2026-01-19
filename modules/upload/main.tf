module "upload_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.2.0"

  function_name = var.lambda_name
  handler       = "index.handler"
  runtime       = "python3.14"

  source_path = {
    path           = "${path.root}/src/functions/upload"
    poetry_install = true
  }

  artifacts_dir = "builds"

  environment_variables = {
    BUCKET_NAME = "${var.s3_bucket_name}"
  }
}

resource "aws_iam_role_policy" "allow_s3_put" {
  name = "${var.env}-allow-s3-put-uploads"
  role = module.upload_function.lambda_role_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:PutObject", "s3:PutObjectAcl"]
      Resource = "arn:aws:s3:::${var.s3_bucket_name}/users/*"
    }]
  })
}
