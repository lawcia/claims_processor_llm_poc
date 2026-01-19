terraform {

  required_version = ">= 1.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"
    }
  }



  backend "s3" {
    bucket         = "claims-processer-terraform-state-f56c7rc"
    key            = "envs/dev/varterraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "claims-processor-terraform-locks-67b787d"
    encrypt        = true
  }



}
