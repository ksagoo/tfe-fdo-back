# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  name = "${var.friendly_name_prefix}-${var.product}-${var.kms_key_name}"
}

data "aws_region" "current" {}

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "key" {
  description             = "${var.product} ${var.kms_key_description}"
  key_usage               = var.kms_key_usage
  deletion_window_in_days = var.kms_key_deletion_window
  is_enabled              = true
  enable_key_rotation     = false
  policy                  = data.aws_iam_policy_document.policy.json
  multi_region            = var.create_multi_region_key ? true : false

  tags = merge(
    { Name = local.name },
    var.common_tags
  )
}

resource "aws_kms_alias" "alias" {
  name          = "alias/${local.name}-alias"
  target_key_id = aws_kms_key.key.id
}

data "aws_iam_policy_document" "policy" {
  statement {
    sid = "AllowAccessForKeyAdministrators"
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.arn]
    }

  }

  dynamic "statement" {
    for_each = var.kms_default_policy_enabled ? [1] : []
    content {
      sid       = "Default"
      actions   = ["kms:*"]
      resources = ["*"]

      principals {
        type        = "AWS"
        identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.kms_allow_asg_to_cmk && var.kms_asg_role_arn != "" ? [1] : []

    content {
      sid = "AllowServiceLinkedRoleUseOf"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey",
      ]
      resources = ["*"]

      principals {
        type        = "AWS"
        identifiers = [var.kms_asg_role_arn]
      }
    }
  }
  dynamic "statement" {
    for_each = var.kms_allow_asg_to_cmk && var.kms_asg_role_arn != "" ? [1] : []

    content {
      sid = "ASGAttatchmentToPersistentResources"
      actions = [
        "kms:CreateGrant"
      ]
      resources = ["*"]

      principals {
        type        = "AWS"
        identifiers = [var.kms_asg_role_arn]
      }

      condition {
        test     = "Bool"
        variable = "kms:GrantIsForAWSResource"
        values   = [true]
      }
    }
  }
  dynamic "statement" {
    for_each = var.kms_allow_asg_to_cmk ? [1] : []

    content {
      sid = "AllowLoggingConsumption"
      actions = [
        "kms:Encrypt*",
        "kms:Decrypt*",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:Describe*",
      ]
      resources = ["*"]

      principals {
        type        = "Service"
        identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
      }
    }
  }

  dynamic "statement" {
    for_each = length(var.kms_key_users_or_roles) > 0 ? [1] : []

    content {
      sid = "KeyUsage"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey",
        "kms:CreateGrant"
      ]
      resources = ["*"]

      principals {
        type        = "AWS"
        identifiers = var.kms_key_users_or_roles
      }
    }
  }
}
