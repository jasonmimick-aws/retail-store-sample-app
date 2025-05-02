locals {
  common_datadog_tags = merge(
    var.datadog_tags,
    {
      environment = var.environment_name
      terraform  = "true"
    }
  )

  datadog_container_definition = {
    name      = "datadog-agent"
    image     = var.datadog_agent_image
    essential = true
    environment = [
      { name = "DD_APM_ENABLED", value = "true" },
      { name = "DD_LOGS_ENABLED", value = "true" },
      { name = "DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL", value = "true" },
      { name = "DD_CONTAINER_EXCLUDE", value = "name:datadog-agent" },
      { name = "ECS_FARGATE", value = "true" },
      { name = "DD_SITE", value = "datadoghq.com" },
      { name = "DD_APM_NON_LOCAL_TRAFFIC", value = "true" },
      { name = "DD_ECS_TASK_COLLECTION_ENABLED", value = "true" },
      { name = "DD_ECS_COLLECT_RESOURCE_TAGS_EC2", value = "true" },
      { name = "DD_TAGS", value = join(",", [for k, v in local.common_datadog_tags : "${k}:${v}"]) }
    ]
    secrets = [
      {
        name      = "DD_API_KEY"
        valueFrom = var.datadog_api_key_arn
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = var.log_group_name
        "awslogs-region"        = var.cloudwatch_logs_region
        "awslogs-stream-prefix" = "dd"
        "mode"                  = "non-blocking"
      }
    }
  }
}
