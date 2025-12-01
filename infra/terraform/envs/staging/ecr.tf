############################################
# Reference shared ECR repository
############################################

data "aws_ecr_repository" "app" {
  name = "mynewdemo"
}
