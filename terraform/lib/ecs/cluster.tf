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
}

resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = "retailstore.le.local"
  description = "Service discovery namespace"
  vpc         = var.vpc_id
}
