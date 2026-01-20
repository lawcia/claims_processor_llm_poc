module "process_claim_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.2.0"

  function_name = var.lambda_name
  handler       = "index.handler"
  runtime       = "python3.14"

  source_path = {
    path           = "${path.root}/src/functions/process-claim"
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

resource "aws_sqs_queue" "queue" {
  name = var.queue_name
}

data "aws_iam_policy_document" "queue" {

  statement {
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.queue.arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [var.s3_bucket_arn]
    }
  }
}

resource "aws_sqs_queue_policy" "queue_policy" {
  queue_url = aws_sqs_queue.queue.id
  policy    = data.aws_iam_policy_document.queue.json
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.s3_bucket_name

  queue {
    queue_arn = aws_sqs_queue.queue.arn
    events    = ["s3:ObjectCreated:*"]
  }
}

resource "aws_lambda_event_source_mapping" "claim_event" {
  event_source_arn        = aws_sqs_queue.queue.arn
  function_name           = module.process_claim_function.lambda_function_arn
  function_response_types = ["ReportBatchItemFailures"]
}
