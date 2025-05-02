module "container_images" {
  source = "../images"

  container_image_overrides = var.container_image_overrides
}

# Service Discovery Services
resource "aws_service_discovery_service" "ui" {
  name = "ui"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id

    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "checkout" {
  name = "checkout"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id

    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_custom_config {
    failure_te_threshold = 1
  }
}

resource "aws_service_discovery_service" "catalog" {
  name = "catalog"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id

    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "cart" {
  name = "cart"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id

    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "orders" {
  name = "orders"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id

    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_ecs_service" "checkout" {
  name            = "checkout"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.checkout.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
       security_groups = [aws_security_group.checkout.id]
    subnets         = var.subnet_ids
  }

  service_registries {
    registry_arn = aws_service_discovery_service.checkout.arn
  }

  tags = var.tags
}

resource "aws_ecs_service" "catalog" {
  name            = "catalog"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.catalog.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.catalog.id]
    subnets         = var.subnet_ids
  }

  service_registries {
    registry_arn = aws_service_discovery_service.catalog.arn
  }

  tags = var.tags
}

resource "aws_ecs_service" "cart" {
  name            = "cart"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.cart.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.cart.id]
    subnets         = var.subnet_ids
  }

  service_registries {
    registry_arn = aws_service_discovery_service.cart.arn
  }

  tags = var.tags
}

resource "aws_ecs_service" "orders" {
  name            = "orders"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.orders.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.orders.id]
    subnets         = var.subnet_ids
  }

  service_registries {
    registry_arn = aws_service_discovery_service.orders.arn
  }

  tags = var.tags
}

resource "aws_ecs_service" "ui" {
  name            = "ui"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.ui.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.ui.id]
    subnets         = var.subnet_ids
  }

  service_registries {
    registry_arn = aws_service_discovery_service.ui.arn
  }

  load_balancer {
    target_group_arn = module.alb.target_group_arns[0]
    container_name   = "application"
    container_port   = 8080
  }

  tags = var.tags
}
