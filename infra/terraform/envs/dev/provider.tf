terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # For now use local backend; later we can switch to S3 + DynamoDB
  backend "s3" {
    bucket         = "mynewdemo-terraform-state-elyman"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }


}

provider "aws" {
  region = var.aws_region
}
