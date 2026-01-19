variable "api_name" {
  type = string
}

variable "region" {
  type = string
}

variable "env" {
  type = string
}

variable "stage_name" {
  type    = string
  default = "prod"
}

variable "user_pool_client_id" {
  type = string
}

variable "user_pool_endpoint" {
  type = string
}

variable "upload_function_name" {
  type = string
}

variable "upload_function_invoke_arn" {
  type = string
}

