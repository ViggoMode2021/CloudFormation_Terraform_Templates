#export AWS_ACCESS_KEY_ID=""
#export AWS_SECRET_ACCESS_KEY=""

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

variable "vpc_id" {
  default = "vpc-0b8625ef3872c7a97"
}

data "aws_vpc" "vpc_info" {
  id = var.vpc_id
}

# Data in Terraform is used for 

variable "subnet_id" {
  default = "subnet-093bfce1d9ace3245"
}

data "aws_subnet" "subnet_1" {
  id = var.subnet_id
}

variable "subnet_id_2" {
  default = "subnet-09501a1bc33817665"
}

data "aws_subnet" "subnet_2" {
  id = var.subnet_id_2
}

resource "aws_security_group" "my-personal-web" {
  provider = aws.us-east-1

  name        = "HTTP security"
  description = "Allow HTTP inbound traffic"
  vpc_id      = data.aws_vpc.vpc_info.id

  ingress {
    description = "Allow HTTP for all"
    from_port   = 5000
    to_port     = 5000
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
  subnets            = [data.aws_subnet.subnet_1.id, data.aws_subnet.subnet_2.id]
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
  vpc_id      = data.aws_vpc.vpc_info.id
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

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
  arn  = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "my-personal-web" {
  provider = aws.us-east-1

  family                   = "service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 0.5
  execution_role_arn       = "data.aws_iam_role.ecs_task_execution_role.arn"
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
    subnets          = [data.aws_subnet.subnet_1.id, data.aws_subnet.subnet_2.id]
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
