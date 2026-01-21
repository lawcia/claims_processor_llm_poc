variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "bedrock_model_name" {
  type    = string
  default = "eu.anthropic.claude-haiku-4-5-20251001-v1:0"
}
