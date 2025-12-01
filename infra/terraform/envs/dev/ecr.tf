############################################
# ECR Repository (single definition)
############################################

resource "aws_ecr_repository" "app" {
  name                 = "mynewdemo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  # Optional tags
  # tags = merge(local.common_tags, {
  #   Name = "${var.project_name}-dev-ecr"
  # })
}
