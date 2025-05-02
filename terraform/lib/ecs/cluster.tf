resource "aws_ecs_cluster" "cluster" {
  name = "retail-store-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "ecs_tasks" {
  name = "${var.environment_name}-tasks"

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      name,
      retention_in_days
    ]
  }
}

resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = "retailstore.le.local"
  description = "Service discovery namespace"
  vpc         = var.vpc_id

  lifecycle {
    prevent_destroy = true
  }
}
