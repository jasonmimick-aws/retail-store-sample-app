variable "environment_name" {
  type        = string
  description = "Name of the environment"
}

variable "service_name" {
  type        = string
  description = "Name of the ECS service"
}

variable "cluster_arn" {
  description = "ECS cluster ARN"
  type        = string
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

variable "container_image" {
  description = "Container image for the service"
  type        = string
}

variable "service_discovery_namespace_arn" {
  description = "ARN of the service discovery namespace for Service Connect"
  type        = string
}

variable "environment_variables" {
  description = "Map of environment variables for the ECS task"
  default     = {}
  type        = any
}

variable "secrets" {
  description = "Map of secrets for the ECS task"
  default     = {}
  type        = any
}

variable "additional_task_role_iam_policy_arns" {
  description = "Additional IAM policy ARNs to be added to the task role"
  default     = []
  type        = list(string)
}

variable "additional_task_execution_role_iam_policy_arns" {
  description = "Additional IAM policy ARNs to be added to the task execution role"
  default     = []
  type        = list(string)
}

variable "healthcheck_path" {
  description = "HTTP path used to health check the service"
  default     = "/health"
  type        = string
}

variable "cloudwatch_logs_group_id" {
  description = "CloudWatch logs group ID"
  type        = string
}

variable "alb_target_group_arn" {
  description = "ARN of the ALB target group the ECS service should register tasks to"
  default     = ""
  type        = string
}

# Datadog Variables
variable "enable_datadog" {
  description = "Enable Datadog integration"
  type        = bool
  default     = true
}

variable "datadog_api_key_arn" {
  description = "ARN of the Datadog API key secret"
  type        = string
}

variable "datadog_agent_image" {
  description = "Datadog agent image to use"
  type        = string
  default     = "public.ecr.aws/datadog/agent:latest"
}

# Logging Variables
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

# Container Configuration
variable "default_container_def" {
  description = "Default container definition configuration"
  type        = any
  default     = {}
}

variable "datadog_container_def" {
  description = "Datadog container definition configuration"
  type        = any
  default     = null
}

variable "datadog_tags" {
  description = "Additional tags for Datadog agent"
  type        = map(string)
  default     = {}
}
