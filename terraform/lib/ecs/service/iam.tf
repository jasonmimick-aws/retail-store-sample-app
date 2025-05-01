resource "aws_iam_role" "task_execution_role" {
  name               = "${var.environment_name}-${var.service_name}-te"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "task_execution_role_policy" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "task_execution_role_additional" {
  count = length(var.additional_task_execution_role_iam_policy_arns)

  role       = aws_iam_role.task_execution_role.name
  policy_arn = var.additional_task_execution_role_iam_policy_arns[count.index]
}

# Add CloudWatch Logs policy
resource "aws_iam_policy" "cloudwatch_logs" {
  count = var.cloudwatch_logs_enabled ? 1 : 0

  name        = "${var.environment_name}-${var.service_name}-cloudwatch-logs"
  path        = "/"
  description = "Policy for CloudWatch Logs access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups"
        ]
        Resource = [
          "arn:aws:logs:${var.cloudwatch_logs_region}:${data.aws_caller_identity.current.account_id}:log-group:${var.log_group_name}:*",
          "arn:aws:logs:${var.cloudwatch_logs_region}:${data.aws_caller_identity.current.account_id}:log-group:${var.log_group_name}:*:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "task_execution_cloudwatch_logs" {
  count = var.cloudwatch_logs_enabled ? 1 : 0

  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs[0].arn
}

resource "aws_iam_role" "task_role" {
  name               = "${var.environment_name}-${var.service_name}-task"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "task_role_additional" {
  count = length(var.additional_task_role_iam_policy_arns)

  role       = aws_iam_role.task_role.name
  policy_arn = var.additional_task_role_iam_policy_arns[count.index]
}

resource "aws_iam_role_policy_attachment" "task_role_policy" {
  role       = aws_iam_role.task_role.name
  policy_arn = aws_iam_policy.ecs_exec.arn
}

resource "aws_iam_policy" "ecs_exec" {
  name        = "${var.environment_name}-${var.service_name}-exec"
  path        = "/"
  description = "ECS exec policy"

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
       "Effect": "Allow",
       "Action": [
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel"
       ],
      "Resource": "*"
      }
   ]
}
EOF
}

# Datadog Secrets Policy
resource "aws_iam_policy" "datadog_secrets" {
  count = var.enable_datadog ? 1 : 0

  name        = "${var.environment_name}-${var.service_name}-datadog-secrets"
  path        = "/"
  description = "Policy to access Datadog API key secret"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          var.datadog_api_key_arn
        ]
      }
    ]
  })
}

# Datadog Agent Policy
resource "aws_iam_policy" "datadog_agent" {
  count = var.enable_datadog ? 1 : 0

  name        = "${var.environment_name}-${var.service_name}-datadog-agent"
  path        = "/"
  description = "Policy for Datadog Agent permissions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:ListClusters",
          "ecs:ListContainerInstances",
          "ecs:DescribeContainerInstances",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:DescribeServices",
          "ecs:ListServices"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach Datadog policies
resource "aws_iam_role_policy_attachment" "task_execution_datadog" {
  count = var.enable_datadog ? 1 : 0

  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.datadog_secrets[0].arn
}

resource "aws_iam_role_policy_attachment" "task_role_datadog" {
  count = var.enable_datadog ? 1 : 0

  role       = aws_iam_role.task_role.name
  policy_arn = aws_iam_policy.datadog_agent[0].arn
}

# Add data source for AWS account ID
data "aws_caller_identity" "current" {}
