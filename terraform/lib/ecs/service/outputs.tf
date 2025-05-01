output "ecs_service_name" {
  value       = aws_ecs_service.this.name
  description = "Name of the ECS service"
}

output "task_security_group_id" {
  value       = aws_security_group.this.id
  description = "ID of the task security group"
}

output "task_definition_arn" {
  value       = aws_ecs_task_definition.this.arn
  description = "ARN of the task definition"
}

output "task_role_arn" {
  value       = aws_iam_role.task_role.arn
  description = "ARN of the task IAM role"
}

output "task_execution_role_arn" {
  value       = aws_iam_role.task_execution_role.arn
  description = "ARN of the task execution IAM role"
}

output "log_group_name" {
  value       = var.log_group_name
  description = "Name of the CloudWatch Logs group"
}

output "datadog_enabled" {
  value       = var.enable_datadog
  description = "Whether Datadog integration is enaenabled"
}

output "service_tags" {
  value = merge(
    var.tags,
    {
      "dd_service" = var.service_name
      "dd_env"     = var.environment_name
    }
  )
  description = "Tags applied to the service including Datadog tags"
}
