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
        image     = module.container_images.result.checkout.url
        essential = true
        portMappings = [
          {
            containerPort = 8080
            hostPort      = 8080
            protocol      = "tcp"
          }
        ]
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
        environment = [
          {
            name  = "REDIS_URL"
            value = "redis://${var.checkout_redis_endpoint}:${var.checkout_redis_port}"
          }
        ]
      }
    ],
    var.enable_datadog ? [local.datadog_container_definition] : []
  ))
}

resource "aws_ecs_task_definition" "catalog" {
  family                   = "retail-store-ecs-catalog"
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
        image     = module.container_images.result.catalog.url
        essential = true
        portMappings = [
          {
            containerPort = 8080
            hostPort      = 8080
            protocol      = "tcp"
          }
        ]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            "awslogs-group"         = var.log_group_name
            "awslogs-region"        = var.cloudwatch_logs_region
            "awslogs-stream-prefix" = "catalog-service"
            "mode"                  = "non-blocking"
          }
        }
        dockerLabels = {
          "com.datadoghq.tags.service" = "catalog"
          "com.datadoghq.ad.logs"      = "[{\"source\": \"catalog\", \"service\": \"catalog\"}]"
          "com.datadoghq.tags.env"     = var.environment_name
        }
        environment = [
          {
            name  = "CATALOG_DB_ENDPOINT"
            value = var.catalog_db_endpoint
          },
          {
            name  = "CATALOG_DB_PORT"
            value = var.catalog_db_port
          },
          {
            name  = "CATALOG_DB_NAME"
            value = var.catalog_db_name
          }
        ]
      }
    ],
    var.enable_datadog ? [local.datadog_container_definition] : []
  ))
}

resource "aws_ecs_task_definition" "cart" {
  family                   = "retail-store-ecs-cart"
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
        image     = module.container_images.result.cart.url
        essential = true
        portMappings = [
          {
            containerPort = 8080
            hostPort      = 8080
            protocol      = "tcp"
          }
        ]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            "awslogs-group"         = var.log_group_name
            "awslogs-region"        = var.cloudwatch_logs_region
            "awslogs-stream-prefix" = "cart-service"
            "mode"                  = "non-blocking"
          }
        }
        dockerLabels = {
          "com.datadoghq.tags.service" = "cart"
          "com.datadoghq.ad.logs"      = "[{\"source\": \"cart\", \"service\": \"cart\"}]"
          "com.datadoghq.tags.env"     = var.environment_name
        }
        environment = [
          {
            name  = "CARTS_DYNAMODB_TABLE_NAME"
            value = var.carts_dynamodb_table_name
          }
        ]
      }
    ],
    var.enable_datadog ? [local.datadog_container_definition] : []
  ))
}

resource "aws_ecs_task_definition" "orders" {
  family                   = "retail-store-ecs-orders"
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
        image     = module.container_images.result.orders.url
        essential = true
        portMappings = [
          {
            containerPort = 8080
            hostPort      = 8080
            protocol      = "tcp"
          }
        ]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            "awslogs-group"         = var.log_group_name
            "awslogs-region"        = var.cloudwatch_logs_region
            "awslogs-stream-prefix" = "orders-service"
            "mode"                  = "non-blocking"
          }
        }
        dockerLabels = {
          "com.datadoghq.tags.service" = "orders"
          "com.datadoghq.ad.logs"      = "[{\"source\": \"orders\", \"service\": \"orders\"}]"
          "com.datadoghq.tags.env"     = var.environment_name
        }
        environment = [
          {
            name  = "ORDERS_DB_ENDPOINT"
            value = var.orders_db_endpoint
          },
          {
            name  = "ORDERS_DB_PORT"
            value = var.orders_db_port
          },
          {
            name  = "ORDERS_DB_NAME"
            value = var.orders_db_name
          },
          {
            name  = "MQ_URL"
            value = "amqps://${var.mq_username}:${var.mq_password}@${var.mq_endpoint}:5671"
          }
        ]
      }
    ],
    var.enable_datadog ? [local.datadog_container_definition] : []
  ))
}

resource "aws_ecs_task_definition" "ui" {
  family                   = "retail-store-ecs-ui"
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
        image     = module.container_images.result.ui.url
        essential = true
        portMappings = [
          {
            containerPort = 8080
            hostPort      = 8080
            protocol      = "tcp"
          }
        ]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            "awslogs-group"         = var.log_group_name
            "awslogs-region"        = var.cloudwatch_logs_region
            "awslogs-stream-prefix" = "ui-service"
            "mode"                  = "non-blocking"
          }
        }
        dockerLabels = {
          "com.datadoghq.tags.service" = "ui"
          "com.datadoghq.ad.logs"      = "[{\"source\": \"ui\", \"service\": \"ui\"}]"
          "com.datadoghq.tags.env"     = var.environment_name
        }
      }
    ],
    var.enable_datadog ? [local.datadog_container_definition] : []
  ))
}
