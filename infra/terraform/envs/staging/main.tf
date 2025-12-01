locals {
  project_name = var.project_name
  env          = "staging"

  common_tags = {
    Project = local.project_name
    Env     = local.env
    Owner   = "devops-class"
  }
}

# VPC & networking are defined in vpc.tf
