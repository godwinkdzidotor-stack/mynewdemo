locals {
  common_tags = {
    Project = var.project_name
    Env     = "dev"
    Owner   = "devops-class"
  }
}

# VPC & networking are defined in vpc.tf
