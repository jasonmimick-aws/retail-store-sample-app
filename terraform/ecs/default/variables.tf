variable "environment_name" {
  type        = string
  default     = "retail-store-ecs"
  description = "Name of the environment"
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

# Datadog Configuration
variable "datadog_api_key_arn" {
  description = "ARN of the Datadog API key stored in AWS Secrets Manager"
  type        = string
  default     = "arn:aws:secretsmanager:us-east-1:607221907875:secret:DD-API_KEY"
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

# Additional Datadog and Logging Configuration
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

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "datadog_api_key" {
  description = "Datadog API Key"
  type        = string
  sensitive   = true
}

