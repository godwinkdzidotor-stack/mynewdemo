############################################
# Security Groups
############################################

resource "aws_security_group" "alb" {
  name        = "${local.project_name}-${local.env}-alb-sg" # ✅ FIXED
  description = "ALB security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-${local.env}-alb-sg"
  })
}

resource "aws_security_group" "ecs_tasks" {
  name        = "${local.project_name}-${local.env}-ecs-sg"
  description = "ECS tasks security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-${local.env}-ecs-sg"
  })
}

############################################
# Application Load Balancer
############################################

resource "aws_lb" "app" {
  name               = "${local.project_name}-${local.env}-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-${local.env}-alb"
  })
}

resource "aws_lb_target_group" "app" {
  name        = "${local.project_name}-${local.env}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-${local.env}-tg"
  })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

############################################
# ECS Cluster
############################################

resource "aws_ecs_cluster" "main" {
  name = "${local.project_name}-${local.env}-cluster"

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-${local.env}-cluster"
  })
}

############################################
# IAM Roles for ECS Tasks
############################################

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Execution role – used by ECS to pull from ECR, write logs, etc.
resource "aws_iam_role" "ecs_task_execution" {
  name               = "${local.project_name}-${local.env}-ecs-exec-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-${local.env}-ecs-exec-role"
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Task role – for your app’s AWS permissions (can be expanded later)
resource "aws_iam_role" "ecs_task" {
  name               = "${local.project_name}-${local.env}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-${local.env}-ecs-task-role"
  })
}

############################################
# CloudWatch Logs
############################################

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${local.project_name}-${local.env}"
  retention_in_days = 7

  tags = local.common_tags
}

############################################
# ECS Task Definition
############################################

resource "aws_ecs_task_definition" "app" {
  family                   = "${local.project_name}-${local.env}-task"
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  # ✅ FIX: use the roles that actually exist
  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  task_role_arn      = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name = "app"
      # ✅ uses the ECR data source
      image     = "${data.aws_ecr_repository.app.repository_url}:${local.env}-latest"
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${local.project_name}-${local.env}"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = local.common_tags
}

############################################
# ECS Service
############################################

resource "aws_ecs_service" "app" {
  name            = "${local.project_name}-${local.env}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "app"
    container_port   = var.container_port
  }

  depends_on = [
    aws_lb_listener.http
  ]

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-${local.env}-service"
  })
}
