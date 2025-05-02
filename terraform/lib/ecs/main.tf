module "container_images" {
  source = "../images"

  container_image_overrides = var.container_image_overrides
}

locals {
  datadog_container_definition = var.enable_datadog ? {
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
      { name = "DD_TAGS", value = "env:${var.environment_name}" }
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
  } : null
}

# Add variables for the ECS module
variable "enable_datadog" {
  description = "Enable Datadog integration"
  type        = bool
  default     = false
}

variable "datadog_api_key_arn" {
  description = "ARN of the Datadog API key secret in Secrets Manager"
  type        = string
  default     = ""
}

variable "datadog_agent_image" {
  description = "Datadog Agent container image"
  type        = string
  default     = "public.ecr.aws/datadog/agent:latest"
}

variable "environment_name" {
  description = "Environment name"
  type        = string
}

variable "cloudwatch_logs_region" {
  description = "AWS region for CloudWatch Logs"
  type        = string
}

variable "log_group_name" {
  description = "CloudWatch Log Group name"
  type        = string
}

# Add your existing container definitions and task definitions here
# Make sure to include the Datadog container when enabled
