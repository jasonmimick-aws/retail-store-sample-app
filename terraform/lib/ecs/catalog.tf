module "catalog_service" {
  source = "./service"

  environment_name                = var.environment_name
  service_name                    = "catalog"
  cluster_arn                     = aws_ecs_cluster.cluster.arn
  vpc_id                          = var.vpc_id
  subnet_ids                      = var.subnet_ids
  tags                            = var.tags
  container_image                 = module.container_images.result.catalog.url
  service_discovery_namespace_arn = aws_service_discovery_private_dns_namespace.this.arn
  cloudwatch_logs_group_id        = var.cloudwatch_logs_enabled ? aws_cloudwatch_log_group.retail_store[0].id : null

  environment_variables = merge(
    local.default_container_environment,
    {
      RETAIL_CATALOG_PERSISTENCE_PROVIDER = "mysql"
      RETAIL_CATALOG_PERSISTENCE_DB_NAME  = var.catalog_db_name
    }
  )

  secrets = {
    RETAIL_CATALOG_PERSISTENCE_ENDPOINT = "${aws_secretsmanager_secret_version.catalog_db.arn}:host::"
    RETAIL_CATALOG_PERSISTENCE_USER     = "${aws_secretsmanager_secret_version.catalog_db.arn}:username::"
    RETAIL_CATALOG_PERSISTENCE_PASSWORD = "${aws_secretsmanager_secret_version.catalog_db.arn}:password::"
  }

  additional_task_execution_role_iam_policy_arns = [
    aws_iam_policy.catalog_policy.arn
  ]

  # Add Datadog configuration
  enable_datadog        = var.enable_datadog
  datadog_container_def = local.datadog_container_definition
  datadog_api_key_arn   = var.datadog_api_key_arn
  datadog_agent_image   = var.datadog_agent_image
  datadog_tags = {
    service = "catalog"
    env     = var.datadog_env
  }

  # Add default container configuration
  default_container_def = local.default_container_definitions

  # Add CloudWatch Logs configuration
  cloudwatch_logs_enabled = var.cloudwatch_logs_enabled
  cloudwatch_logs_region  = var.cloudwatch_logs_region
  log_group_name         = var.log_group_name
}

data "aws_iam_policy_document" "catalog_db_secret" {
  statement {
    sid = ""
    actions = [
      "secretsmanager:GetSecretValue",
      "kms:Decrypt*"
    ]
    effect = "Allow"
    resources = [
      aws_secretsmanager_secret.catalog_db.arn,
      aws_kms_key.cmk.arn
    ]
  }
}

resource "aws_iam_policy" "catalog_policy" {
  name        = "${var.environment_name}-catalog"
  path        = "/"
  description = "Policy for catalog"

  policy = data.aws_iam_policy_document.catalog_db_secret.json
}

resource "random_string" "random_catalog_secret" {
  length  = 4
  special = false
}

resource "aws_secretsmanager_secret" "catalog_db" {
  name       = "${var.environment_name}-catalog-db-${random_string.random_catalog_secret.result}"
  kms_key_id = aws_kms_key.cmk.key_id
}

resource "aws_secretsmanager_secret_version" "catalog_db" {
  secret_id = aws_secretsmanager_secret.catalog_db.id

  secret_string = jsonencode(
    {
      username = var.catalog_db_username
      password = var.catalog_db_password
      host     = "${var.catalog_db_endpoint}:${var.catalog_db_port}"
    }
  )
}

