variable "environment_name" {
  type        = string
  description = "Name of the environment"
}

variable "tags" {
  description = "List of tags to be associated with resources."
  default     = {}
  type        = any
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of private subnet IDs."
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs."
  type        = list(string)
}

variable "container_image_overrides" {
  type = object({
    default_repository = optional(string)
    default_tag        = optional(string)

    ui       = optional(string)
    catalog  = optional(string)
    cart     = optional(string)
    checkout = optional(string)
    orders   = optional(string)
  })
  default     = {}
  description = "Object that encapsulates any overrides to default values"
}

variable "catalog_db_endpoint" {
  type        = string
  description = "Endpoint of the catalog database"
}

variable "catalog_db_port" {
  type        = string
  description = "Port of the catalog database"
}

variable "catalog_db_name" {
  type        = string
  description = "Name of the catalog database"
}

variable "catalog_db_username" {
  type        = string
  description = "Username for the catalog database"
}

variable "catalog_db_password" {
  type        = string
  description = "Password for the catalog database"
}

variable "carts_dynamodb_table_name" {
  type        = string
  description = "DynamoDB table name for the carts service"
}

variable "carts_dynamodb_policy_arn" {
  type        = string
  description = "IAM policy for DynamoDB table for the carts service"
}

variable "orders_db_endpoint" {
  type        = string
  description = "Endpoint of the orders database"
}

variable "orders_db_port" {
  type        = string
  description = "Port of the orders database"
}

variable "orders_db_name" {
  type        = string
  description = "Name of the orders database"
}

variable "orders_db_username" {
  type        = string
  description = "Username for the orders database"
}

variable "orders_db_password" {
  type        = string
  description = "Username for the password database"
}

variable "checkout_redis_endpoint" {
  type        = string
  description = "Endpoint of the checkout redis"
}

variable "checkout_redis_port" {
  type        = string
  description = "Port of the checkout redis"
}

variable "mq_endpoint" {
  type        = string
  description = "Endpoint of the shared MQ"
}

variable "mq_username" {
  type        = string
  description = "Username for the shared MQ"
}

variable "mq_password" {
  type        = string
  description = "Password for the shared MQ"
}

# Datadog and Logging Variables
variable "datadog_api_key_arn" {
  description = "ARN of the Datadog API key stored in AWS Secrets Manager"
  type        = string
}

variable "enable_datadog" {
  description = "Enable Datadog integration"
  type        = bool
  default     = true
}

variable "datadog_agent_image" {
  description = "Datadog agent image to use"
  type        = string
  default     = "public.ecr.aws/datadog/agent:latest"
}

variable "log_group_name" {
  description = "CloudWatch Log group name"
  type        = string
  default     = "/ecs/retail-store-ecs-tasks"
}

variable "cloudwatch_logs_enabled" {
  description = "Enable CloudWatch logs"
  type        = bool
  default     = true
}

variable "cloudwatch_logs_region" {
  description = "AWS region for CloudWatch logs"
  type        = string
  default     = "us-east-1"
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights"
  type        = bool
  default     = true
}

variable "datadog_tags" {
  description = "Additional tags for Datadog agent"
  type        = map(string)
  default     = {}
}

variable "datadog_env" {
  description = "Environment tag for Datadog agent"
  type        = string
  default     = "prod"
}

variable "environment_variables" {
  description = "List of environment variables for the ECS task"
  default     = []
  type = list(object({
    name  = string
    value = string
  }))
}

variable "secrets" {
  description = "List of secrets for the ECS task"
  default     = []
  type = list(object({
    name      = string
    valueFrom = string
  }))
}

