
module "container_images" {
  source = "../images"

  container_image_overrides = var.container_image_overrides
}

resource "aws_ecs_cluster" "main" {
  name = "retail-store-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = var.tags
}

resource "aws_ecs_service" "checkout" {
  name            = "checkout"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.checkout.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.checkout.id]
    subnets         = var.subnet_ids
  }

  tags = var.tags
}

resource "aws_ecs_service" "catalog" {
  name            = "catalog"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.catalog.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.catalog.id]
    subnets         = var.subnet_ids
  }

  tags = var.tags
}

resource "aws_ecs_service" "cart" {
  name            = "cart"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.cart.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.cart.id]
    subnets         = var.subnet_ids
  }

  tags = var.tags
}

resource "aws_ecs_service" "orders" {
  name            = "orders"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.orders.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.orders.id]
    subnets         = var.subnet_ids
  }

  tags = var.tags
}

resource "aws_ecs_service" "ui" {
  name            = "ui"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.ui.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.ui.id]
    subnets         = var.subnet_ids
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ui.arn
    container_name   = "application"
    container_port   = 8080
  }

  tags = var.tags
}
