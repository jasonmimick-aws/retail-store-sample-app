module "carts_service" {
  source = "./service"

  environment_name                = var.environment_name
  service_name                    = "carts"
  cluster_arn                     = aws_ecs_cluster.cluster.arn
  vpc_id                          = var.vpc_id
  subnet_ids                      = var.subnet_ids
  tags                            = var.tags
  container_image                 = module.container_images.result.cart.url
  service_discovery_namespace_arn = aws_service_discovery_private_dns_namespace.this.arn
  cloudwatch_logs_group_id        = var.cloudwatch_logs_enabled ? aws_cloudwatch_log_group.retail_store[0].id : null
  healthcheck_path                = "/actuator/health"

  # Merge default and service-specific environment variables
  environment_variables = merge(
    local.default_container_environment,
    {
      RETAIL_CART_PERSISTENCE_PROVIDER            = "dynamodb"
      RETAIL_CART_PERSISTENCE_DYNAMODB_TABLE_NAME = var.carts_dynamodb_table_name
    }
  )

  additional_task_role_iam_policy_arns = [
    var.carts_dynamodb_policy_arn
  ]

  # Add Datadog configuration
  enable_datadog        = var.enable_datadog
  datadog_container_def = local.datadog_container_definition
  datadog_api_key_arn   = var.datadog_api_key_arn  # Add this line
  datadog_agent_image   = var.datadog_agent_image

  # Add default container configuration
  default_container_def = local.default_container_definitions

  # Add CloudWatch Logs configuration
  cloudwatch_logs_enaenabled = var.cloudwatch_logs_enabled
  cloudwatch_logs_region  = var.cloudwatch_logs_region
  log_group_name          = var.log_group_name
}
