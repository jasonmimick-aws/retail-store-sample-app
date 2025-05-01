resource "aws_iam_role" "task_execution_role" {
  name               = "${var.environment_name}-task-role"
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

resource "aws_iam_role" "task_role" {
  name               = "${var.environment_name}-task"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "task_role_policy" {
  role       = aws_iam_role.task_role.name
  policy_arn = aws_iam_policy.ecs_exec.arn
}

resource "aws_iam_policy" "ecs_exec" {
  name        = "${var.environment_name}-ecs-exec"
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

# Add CloudWatch Logs policy
resource "aws_iam_role_policy" "task_execution_cloudwatch_logs" {
  count = var.cloudwatch_logs_enabled ? 1 : 0
  name  = "${var.environment_name}-task-execution-cloudwatch-logs"
  role  = aws_iam_role.task_execution_role.id

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

# Add Datadog secrets access policy
resource "aws_iam_role_policy" "datadog_access" {
  count = var.enable_datadog ? 1 : 0
  name  = "${var.environment_name}-datadog-access"
  role  = aws_iam_role.task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [var.datadog_api_key_arn]
      }
    ]
  })
}

# Add policy for Datadog agent permissions
resource "aws_iam_role_policy" "datadog_agent" {
  count = var.enable_datadog ? 1 : 0
  name  = "${var.environment_name}-datadog-agent"
  role  = aws_iam_role.task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:ListClusters",
          "ecs:ListContainerInstances",
          "ecs:DescribeContainerInstances"
        ]
        Resource = "*"
      }
    ]
  })
}

# Data source for AWS account ID
data "aws_caller_identity" "current" {}
