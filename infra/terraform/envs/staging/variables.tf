variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix for resource names"
  type        = string
  default     = "mynewdemo"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
variable "container_port" {
  description = "Port your app container listens on"
  type        = number
  default     = 80
}

variable "desired_count" {
  description = "Number of tasks to run in ECS service"
  type        = number
  default     = 1
}
