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

variable "datadog_api_key_arn" {
  description = "ARN of the Datadog API key stored in AWS Secrets Manager"
  type        = string
}

# New variables for Datadog configuration
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
