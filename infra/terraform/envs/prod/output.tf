##############################
# VPC OUTPUTS
##############################

output "vpc_id" {
  description = "The ID of the main VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs (used by ALB, NAT, etc.)"
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
}

output "private_subnet_ids" {
  description = "Private subnet IDs (used by ECS tasks, RDS, etc.)"
  value = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
}

##############################
# LOAD BALANCER OUTPUTS
##############################

output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = aws_lb.app.dns_name
}

##############################
# ECR OUTPUT
##############################

output "ecr_repository_url" {
  description = "URL of the shared ECR repository for this application"
  value       = data.aws_ecr_repository.app.repository_url
}
