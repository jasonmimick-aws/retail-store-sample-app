module "ui" {
  source = "./service"

  environment_name                = var.environment_name
  service_name                    = "ui"
  cluster_arn                     = aws_ecs_cluster.cluster.arn
  vpc_id                          = var.vpc_id
  subnet_ids                      = var.subnet_ids
  tags                            = var.tags
  container_image                 = module.container_images.result.ui.url
  service_discovery_namespace_arn = aws_service_discovery_private_dns_namespace.this.arn
  cloudwatch_logs_group_id        = var.cloudwatch_logs_enabled ? aws_cloudwatch_log_group.ecs_tasks.id : null
  healthcheck_path                = "/actuator/health"
  alb_target_group_arn            = module.alb.target_group_arns[0]

  environment_variables = {
    RETAIL_UI_ENDPOINTS_CARTS = "http://carts.retailstore.local"
    RETAIL_UI_ENDPOINTS_CATALOG = "http://catalog.retailstore.local"
    RETAIL_UI_ENDPOINTS_ORDERS = "http://orders.retailstore.local"
    RETAIL_UI_ENDPOINTS_CHECKOUT = "http://checkout.retailstore.local"
  }

  # Add Datadog configuration
  enable_datadog        = var.enable_datadog
  datadog_container_def = local.datadog_container_definition
  datadog_api_key_arn   = var.datadog_api_key_arn
  datadog_agent_image   = var.datadog_agent_image
  datadog_tags = {
    service = "ui"
    env     = var.datadog_env
  }

  # Add default container configuration
  default_container_def = local.default_container_definitions

  # Add CloudWatch Logs configuration
  cloudwatch_logs_enabled = var.cloudwatch_logs_enabled
  cloudwatch_logs_region  = var.cloudwatch_logs_region
  log_group_name         = var.log_group_name
}

module "ui_service" {
  source = "./service"

  environment_name                = var.environment_name
  service_name                    = "ui"
  cluster_arn                     = aws_ecs_cluster.cluster.arn
  vpc_id                          = var.vpc_id
  subnet_ids                      = var.subnet_ids
  tags                            = var.tags
  container_image                 = module.container_images.result.ui.url
  service_discovery_namespace_arn = aws_service_discovery_private_dns_namespace.this.arn
  cloudwatch_logs_group_id        = var.cloudwatch_logs_enabled ? aws_cloudwatch_log_group.ecs_tasks.id : null
  healthcheck_path                = "/actuator/health"
  alb_target_group_arn            = module.alb.target_group_arns[0]

  environment_variables = merge(
    local.default_container_environment,
    {
      RETAIL_UI_ENDPOINTS_CATALOG  = "http://${module.catalog_service.ecs_service_name}"
      RETAIL_UI_ENDPOINTS_CARTS    = "http://${module.carts_service.ecs_service_name}"
      RETAIL_UI_ENDPOINTS_CHECKOUT = "http://${module.checkout_service.ecs_service_name}"
      RETAIL_UI_ENDPOINTS_ORDERS   = "http://${module.orders_service.ecs_service_name}"
    }
  )

  # Add Datadog configuration
  enable_datadog        = var.enable_datadog
  datadog_container_def = local.datadog_container_definition
  datadog_api_key_arn   = var.datadog_api_key_arn
  datadog_agent_image   = var.datadog_agent_image
  datadog_tags = {
    service = "ui"
    env     = var.datadog_env
  }

  # Add default container configuration
  default_container_def = local.default_container_definitions

  # Add CloudWatch Logs configuration
  cloudwatch_logs_enabled = var.cloudwatch_logs_enabled
  cloudwatch_logs_region  = var.cloudwatch_logs_region
  log_group_name         = var.log_group_name
}

    

    
