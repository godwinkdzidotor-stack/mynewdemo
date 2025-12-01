##############################
# VPC OUTPUTS
##############################

output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the main VPC"
}

output "public_subnet_ids" {
  value       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  description = "Public subnet IDs (used by ALB, NAT, etc.)"
}

output "private_subnet_ids" {
  value       = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  description = "Private subnet IDs (used by ECS tasks, RDS, etc.)"
}

##############################
# LOAD BALANCER OUTPUTS
##############################

output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = aws_lb.app.dns_name
}

##############################
# ECR OUTPUT (single source of truth)
##############################

output "ecr_repository_url" {
  description = "ECR repository URL for app images"
  value       = aws_ecr_repository.app.repository_url
}

##############################
# ECS OUTPUTS
##############################

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.app.name
}
