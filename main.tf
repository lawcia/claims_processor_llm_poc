provider "aws" {
  region = var.region
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = "${var.env}-claims-4238d320-5725-4410-98ba-afcbe02d5d80"
}

module "dynamodb" {
  source     = "./modules/dynamodb"
  table_name = "${var.env}-claims"
}

module "user_pool" {
  source                = "./modules/user-pool"
  user_pool_name        = "${var.env}-claims-user-pool"
  user_pool_client_name = "${var.env}-claims-user-pool-client"
}

module "process" {
  source              = "./modules/process"
  dynamodb_table_name = module.dynamodb.table_name
  dynamodb_table_arn  = module.dynamodb.table_arn
  s3_bucket_name      = module.s3.bucket_name
  s3_bucket_arn       = module.s3.bucket_arn
  lambda_name         = "${var.env}-process-claim"

  depends_on = [module.s3, module.dynamodb]
}

module "upload" {
  source         = "./modules/upload"
  env            = var.env
  s3_bucket_arn  = module.s3.bucket_arn
  s3_bucket_name = module.s3.bucket_name
  lambda_name    = "${var.env}-upload"
}

module "api" {
  source                     = "./modules/api"
  region                     = var.region
  env                        = var.env
  api_name                   = "${var.env}-claims"
  user_pool_client_id        = module.user_pool.user_pool_client_id
  user_pool_endpoint         = "https://cognito-idp.${var.region}.amazonaws.com/${module.user_pool.user_pool_id}"
  upload_function_invoke_arn = module.upload.function_invoke_arn
  upload_function_name       = module.upload.function_name
}
