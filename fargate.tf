terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  profile = "default"
  alias   = "us-east-1"
  region  = "us-east-1"
}

resource "aws_default_vpc" "my-personal-web" {
  provider = aws.us-east-1

  tags = {
    env = "dev"
  }
}

resource "aws_default_subnet" "my-personal-web" {
  provider          = aws.us-east-1
  availability_zone = "us-east-1a"

  tags = {
    env = "dev"
  }
}

resource "aws_default_subnet" "my-personal-web-1" {
  provider          = aws.us-east-1
  availability_zone = "us-east-1b"


  tags = {
    env = "dev"
  }
}

resource "aws_security_group" "my-personal-web" {
  provider = aws.us-east-1

  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_default_vpc.my-personal-web.id

  ingress {
    description = "Allow HTTP for all"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "my-personal-web" {
  provider = aws.us-east-1

  name               = "my-personal-web-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my-personal-web.id]
  subnets            = [aws_default_subnet.my-personal-web.id, aws_default_subnet.my-personal-web-1.id]
  tags = {
    env = "dev"
  }
}

resource "aws_lb_target_group" "my-personal-web" {
  provider = aws.us-east-1

  name        = "tf-my-personal-web-lb-tg"
  port        = 5000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.my-personal-web.id
}

resource "aws_lb_listener" "my-personal-web" {
  provider = aws.us-east-1

  load_balancer_arn = aws_lb.my-personal-web.arn
  port              = "5000"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my-personal-web.arn
  }
}


resource "aws_ecs_cluster" "my-personal-web" {
  provider = aws.us-east-1
  name     = "my-personal-web-api-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "my-personal-web" {
  provider = aws.us-east-1

  cluster_name = aws_ecs_cluster.my-personal-web.name

  capacity_providers = ["FARGATE"]
}

resource "aws_iam_role" "test_role" {
  name = "test_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "iam:GetRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}
data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

resource "aws_ecs_task_definition" "my-personal-web" {
  provider = aws.us-east-1

  family                   = "service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "my-personal-web-api"
      image     = "583715230104.dkr.ecr.us-east-1.amazonaws.com/practice-spanish-buy-flights-docker-image"
      cpu       = 1024
      memory    = 2048
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "my-personal-web" {
  provider = aws.us-east-1

  name            = "my-personal-web"
  cluster         = aws_ecs_cluster.my-personal-web.id
  task_definition = aws_ecs_task_definition.my-personal-web.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_default_subnet.my-personal-web.id, aws_default_subnet.my-personal-web-1.id]
    security_groups  = [aws_security_group.my-personal-web.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.my-personal-web.arn
    container_name   = "my-personal-web-api"
    container_port   = 5000
  }

  tags = {
    env = "dev"
  }
}
