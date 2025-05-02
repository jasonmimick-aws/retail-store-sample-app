resource "aws_kms_key" "cmk" {
  description             = "${var.environment_name} CMK"
  deletion_window_in_days = 7
}

resource "random_string" "random_mq_secret" {
  length  = 4
  special = false
}

resource "aws_secretsmanager_secret" "mq" {
  name = "${var.environment_name}-mq-${random_string.random_mq_secret.result}"
}

resource "aws_secretsmanager_secret_version" "mq" {
  secret_id = aws_secretsmanager_secret.mq.id

  secret_string = jsonencode(
    {
      username = var.mq_username
      password = var.mq_password
      host     = var.mq_endpoint
    }
  )
}

# Add CloudWatch Logs group
resource "aws_cloudwatch_log_group" "retail_store" {
  count             = var.cloudwatch_logs_enabled ? 1 : 0
  name              = var.log_group_name
  retention_in_days = 30
  tags              = var.tags
}

# Datadog container definition
locals {
  datadog_container_definition = var.enable_datadog ? {
    name      = "datadog-agent"
    image     = var.datadog_agent_image
    essential = true

    secrets = [
      {
        name      = "DD_API_KEY"
        valueFrom = var.datadog_api_key_arn
      }
    ]

    environment = [
      {
        name  = "DD_SITE"
        value = "datadoghq.com"
      },
      {
        name  = "ECS_FARGATE"
        value = "true"
      },
      {
        name  = "DD_APM_ENABLED"
        value = "true"
      },
      {
        name  = "DD_APM_NON_LOCAL_TRAFFIC"
        value = "true"
      },
      {
        name  = "DD_LOGS_ENABLED"
        value = "true"
      },
      {
        name  = "DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL"
        value = "true"
      },
      {
        name  = "DD_ENV"
        value = var.datadog_env
      },
      {
        name  = "DD_SERVICE"
        value = var.environment_name
      }
    ]

    logConfiguration = var.cloudwatch_logs_enabled ? {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = var.log_group_name
        "awslogs-region"        = var.cloudwatch_logs_region
        "awslogs-stream-prefix" = "dd"
      }
    } : null

    portMappings = [
      {
        containerPort = 8126
        hostPort      = 8126
        protocol      = "tcp"
      }
    ]

    cpu         = 256
    memory      = 512
    mountPoints = []
    volumesFrom = []
  } : null
}

# Container definitions helper
locals {
  default_container_definitions = {
    essential = true
    cpu       = 256
    memory    = 512

    logConfiguration = var.cloudwatch_logs_enabled ? {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = var.log_group_name
        "awslogs-region"        = var.cloudwatch_logs_region
        "awslogs-stream-prefix" = "app"
      }
    } : null

    mountPoints  = []
    volumesFrom  = []
    dependsOn    = var.enable_datadog ? [
      {
        containerName = "datadog-agent"
        condition     = "HEALTHY"
      }
    ] : []
  }
}

# Default container environment variables
locals {
  default_container_environment = {
    DD_AGENT_HOST = {
      name  = "DD_AGENT_HOST"
      value = var.enable_datadog ? "localhost" : ""
    }
    DD_TRACE_AGENT_PORT = {
      name  = "DD_TRACE_AGENT_PORT"
      value = "8126"
    }
    DD_ENV = {
      name  = "DD_ENV"
      value = var.datadog_env
    }
    DD_SERVICE = {
      name  = "DD_SERVICE"
      value = var.environment_name
    }
  }
}

    
