resource "aws_ecs_task_definition" "checkout" {
  family                   = "retail-store-ecs-checkout"
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                     = 1024
  memory                  = 2048
  execution_role_arn      = aws_iam_role.task_execution_role.arn
  task_role_arn           = aws_iam_role.task_role.arn
  
  container_definitions = jsonencode(concat(
    [
      {
        name      = "application"
        image     = module.container_images.checkout
        essential = true
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            "awslogs-group"         = var.log_group_name
            "awslogs-region"        = var.cloudwatch_logs_region
            "awslogs-stream-prefix" = "checkout-service"
            "mode"                  = "non-blocking"
          }
        }
        dockerLabels = {
          "com.datadoghq.tags.service" = "checkout"
          "com.datadoghq.ad.logs"      = "[{\"source\": \"checkout\", \"service\": \"checkout\"}]"
          "com.datadoghq.tags.env"     = var.environment_name
        }
      }
    ],
    var.enable_datadog ? [local.datadog_container_definition] : []
  ))
}
