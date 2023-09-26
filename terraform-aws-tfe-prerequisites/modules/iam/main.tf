locals {
  name = "${var.friendly_name_prefix}-${data.aws_region.current.name}-${var.product}"

  asg_role_name = var.create_asg_service_iam_role ? aws_iam_service_linked_role.asg_role[0].name : "AWSServiceRoleForAutoScaling"
  asg_role_type = var.create_asg_service_iam_role && var.asg_service_iam_role_custom_suffix != "" ? "Custom" : "Default"
}

data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_iam_service_linked_role" "asg_role" {
  count            = var.create_asg_service_iam_role ? 1 : 0
  aws_service_name = "autoscaling.amazonaws.com"
  description      = "${local.asg_role_type} Service-Linked Role enables access to AWS Services and Resources used or managed by Auto Scaling"
  custom_suffix    = var.asg_service_iam_role_custom_suffix == "" ? null : var.asg_service_iam_role_custom_suffix
}

data "aws_iam_role" "asg_role" {
  name = local.asg_role_name
}

resource "aws_iam_role" "instance_role" {
  name = "${local.name}-${var.iam_resources.role_name}"
  path = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = var.common_tags
}

data "aws_iam_policy_document" "instance_role_policy" {
  dynamic "statement" {
    for_each = length(var.iam_resources.bucket_arns) >= 1 ? [1] : []
    content {
      sid = "InteractWithS3"
      actions = [
        "s3:PutObject",
        "s3:ListBucket",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:GetBucketLocation",
        "s3:ListBucketVersions"
      ]
      resources = flatten([for arn in var.iam_resources.bucket_arns : [arn, "${arn}/*"]])
    }
  }
  dynamic "statement" {
    for_each = length(var.iam_resources.kms_key_arns) >= 1 ? [1] : []
    content {
      sid = "ManagedKmsKey"
      actions = [
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:DescribeKey",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:GenerateRandom",
        "kms:CreateGrant"
      ]
      resources = var.iam_resources.kms_key_arns
    }
  }
  dynamic "statement" {
    for_each = length(var.iam_resources.secret_manager_arns) >= 1 ? [1] : []
    content {
      sid = "RetrieveSecrets"
      actions = [
        "secretsmanager:GetSecretValue"
      ]
      resources = var.iam_resources.secret_manager_arns
    }
  }
  dynamic "statement" {
    for_each = var.iam_resources.log_group_arn != "" && var.iam_resources.log_forwarding_enabled ? [1] : []
    content {
      sid = "WriteToCloudWatchLogs"
      actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:PutRetentionPolicy"
      ]
      resources = [var.iam_resources.log_group_arn, "${var.iam_resources.log_group_arn}:*"]
    }
  }
  dynamic "statement" {
    for_each = var.iam_resources.log_group_arn != "" && var.iam_resources.log_forwarding_enabled ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "ec2:DescribeVolumes",
        "ec2:DescribeTags",
        "cloudwatch:PutMetricData"
      ]
      resources = ["*"]
    }
  }
  dynamic "statement" {
    for_each = length(var.iam_resources.custom_tbw_ecr_repo_arn) >= 1 ? [1] : []
    content {
      sid    = "PullFromEcr"
      effect = "Allow"
      actions = [
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:DescribeImages",
        "ecr:BatchGetImage"
      ]
      resources = [var.custom_tbw_ecr_repo_arn]
    }
  }
  dynamic "statement" {
    for_each = length(var.iam_resources.custom_tbw_ecr_repo_arn) >= 1 ? [1] : []
    content {
      sid    = "AuthToEcr"
      effect = "Allow"
      actions = [
        "ecr:GetAuthorizationToken",
      ]
      resources = ["*"]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
    ]
    resources = ["*"]
  }
  statement {
    sid = "ASGHook"
    actions = [
      "autoscaling:CompleteLifecycleAction",
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/asg-hook"
      values   = ["${local.name}-asg-hook"]
    }
  }
}

resource "aws_iam_policy" "instance_role_policy" {
  name        = "${local.name}-${var.iam_resources.policy_name}"
  path        = "/"
  description = "Managed policy for the ${var.product} deployment"
  policy      = data.aws_iam_policy_document.instance_role_policy.json
}

resource "aws_iam_role_policy_attachment" "instance_role" {
  role       = aws_iam_role.instance_role.name
  policy_arn = aws_iam_policy.instance_role_policy.arn
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${local.name}-${var.iam_resources.role_name}"
  path = "/"
  role = aws_iam_role.instance_role.name
}

resource "aws_iam_role_policy_attachment" "aws_ssm" {
  count = var.iam_resources.ssm_enable ? 1 : 0

  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_user" "boundary_user" {
  count = var.iam_resources.session_recording_user != "" && var.product == "boundary" ? 1 : 0
  name  = "${local.name}-${var.iam_resources.session_recording_user}"
}

data "aws_iam_policy_document" "boundary_user_policy" {
  count = var.iam_resources.session_recording_user != "" && var.product == "boundary" ? 1 : 0
  dynamic "statement" {
    for_each = length(var.iam_resources.bucket_arns) >= 1 ? [1] : []
    content {
      sid = "InteractWithS3"
      actions = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:GetObjectAttributes",
      ]
      resources = flatten([for arn in var.iam_resources.bucket_arns : [arn, "${arn}/*"]])
    }
  }
  dynamic "statement" {
    for_each = length(var.iam_resources.kms_key_arns) >= 1 ? [1] : []
    content {
      sid = "KMSPermissions"
      actions = [
        "kms:Decrypt",
        "kms:GenerateDataKey",
        "kms:DescribeKey",
      ]
      resources = var.iam_resources.kms_key_arns
    }
  }
  statement {
    actions = [
      "iam:DeleteAccessKey",
      "iam:GetUser",
      "iam:CreateAccessKey"
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${aws_iam_user.boundary_user[0].name}"
    ]
  }
}

resource "aws_iam_policy" "boundary_user_policy" {
  count       = var.iam_resources.session_recording_user != "" && var.product == "boundary" ? 1 : 0
  name        = "${local.name}-${var.iam_resources.session_recording_user}-policy"
  path        = "/"
  description = "Managed policy for the Boundary user recorder"
  policy      = data.aws_iam_policy_document.boundary_user_policy[0].json
}

resource "aws_iam_user_policy" "boundary_user_policy" {
  count  = var.iam_resources.session_recording_user != "" && var.product == "boundary" ? 1 : 0
  name   = "${local.name}-${var.iam_resources.session_recording_user}-policy"
  user   = aws_iam_user.boundary_user[0].name
  policy = data.aws_iam_policy_document.boundary_user_policy[0].json
}
