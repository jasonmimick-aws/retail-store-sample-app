locals {
  # Environment and secrets transformation
  environment_list = [
    for name, value in var.environment_variables : {
      name  = name
      value = try(tostring(value), jsonencode(value), "")
    }
  ]

  secrets_list = [
    for name, value in var.secrets : {
      name      = name
      valueFrom = value
    }
  ]

  # Datadog container definition
  datadog_container = var.enable_datadog ? {
    name      = "datadog-agent"
    image     = var.datadog_agent_image
    essential = true

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
        name  = "DD_SERVICE"
        value = var.service_name
      },
      {
        name  = "DD_ENV"
        value = var.environment_name
      }
    ]

    secrets = [
      {
        name      = "DD_API_KEY"
        valueFrom = var.datadog_api_key_arn
      }
    ]

    portMappings = [
      {
        containerPort = 8126
        hostPort      = 8126
        protocol      = "tcp"
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = var.log_group_name
        "awslogs-region"        = data.aws_region.current.name
        "awslogs-stream-prefix" = "dd"
      }
    }
  } : null
}



data "aws_region" "current" {}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.environment_name}-${var.service_name}"
  container_definitions    = jsonencode(concat(
    [
      {
        name               = "application"
        image              = var.container_image
        portMappings = [
          {
            containerPort = 8080
            hostPort      = 8080
            name          = "application"
            protocol      = "tcp"
          }
        ]
        essential = true
        networkMode = "awsvpc"
        readonlyRootFilesystem = false
        environment = local.environment_list
        secrets    = local.secrets_list
        cpu       = 0
        mountPoints = []
        volumesFrom = []
        healthCheck = {
          command     = ["CMD-SHELL", "curl -f http://localhost:8080${var.healthcheck_path} || exit 1"]
          interval    = 10
          startPeriod = 60
          retries     = 3
          timeout     = 5
        }
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            "awslogs-group"         = var.log_group_name
            "awslogs-region"        = data.aws_region.current.name
            "awslogs-stream-prefix" = var.service_name
          }
        }
        dependsOn = var.enable_datadog ? [
          {
            containerName = "datadog-agent"
            condition     = "HEALTHY"
          }
        ] : []
      }
    ],
    var.enable_datadog ? [local.datadog_container] : []
  ))

  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                     = "1024"
  memory                  = "2048"
  execution_role_arn      = aws_iam_role.task_execution_role.arn
  task_role_arn           = aws_iam_role.task_role.arn

  tags = var.tags
}

resource "aws_ecs_service" "this" {
  name                   = var.service_name
  cluster               = var.cluster_arn
  task_definition       = aws_ecs_task_definition.this.arn
  desired_count         = 1
  launch_type           = "FARGATE"
  enable_execute_command = true
  wait_for_steady_state = true

  network_configuration {
    security_groups  = [aws_security_group.this.id]
    subnets         = var.subnet_ids
    assign_public_ip = false
  }

  service_connect_configuration {
    enabled   = true
    namespace = var.service_discovery_namespace_arn
    service {
      client_alias {
        dns_name = var.service_name
        port     = "80"
      }
      discovery_name = var.service_name
      port_name      = "application"
    }
  }

  dynamic "load_balancer" {
    for_each = var.alb_target_group_arn == "" ? [] : [1]
    content {
      target_group_arn = var.alb_target_group_arn
      container_name   = "application"
      container_port   = 8080
    }
  }

  tags = var.tags
}
