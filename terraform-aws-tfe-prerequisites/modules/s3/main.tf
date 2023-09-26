# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  s3_buckets_enabled = {
    for bucket, values in var.s3_buckets : bucket => values
    if values != null /* object */ && try(values.create, false) == true
  }

  s3_buckets_encrypted = {
    for bucket, values in local.s3_buckets_enabled : bucket => values
    if try(values.encrypt, false) == true
  }


  s3_buckets_replicated = {
    for bucket, values in local.s3_buckets_enabled : bucket => values
    if try(values.replication, false) == true && try(values.is_secondary_region, false) != true
  }
}

data "aws_region" "current" {}

resource "aws_s3_bucket" "s3" {
  for_each      = local.s3_buckets_enabled
  bucket        = "${var.friendly_name_prefix}-${each.value.bucket_name}-${data.aws_region.current.name}"
  force_destroy = each.value.force_destroy
  tags = merge({
    Name = "${var.friendly_name_prefix}-${each.value.bucket_name}-${data.aws_region.current.name}" },
    var.common_tags
  )
}

resource "aws_s3_bucket_versioning" "versioning" {
  for_each = local.s3_buckets_enabled
  bucket   = aws_s3_bucket.s3[each.key].id
  versioning_configuration {
    status = each.value.versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "kms" {
  for_each = local.s3_buckets_encrypted

  bucket = aws_s3_bucket.s3[each.key].id
  rule {
    bucket_key_enabled = each.value.bucket_key_enabled
    apply_server_side_encryption_by_default {
      kms_master_key_id = each.value.kms_key_arn != "" ? each.value.kms_key_arn : null
      sse_algorithm     = each.value.kms_key_arn != "" ? "aws:kms" : "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3" {
  for_each                = local.s3_buckets_enabled
  bucket                  = aws_s3_bucket.s3[each.key].id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_replication_configuration" "s3" {
  for_each = local.s3_buckets_replicated

  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.versioning]

  role   = aws_iam_role.s3_replication[0].arn
  bucket = aws_s3_bucket.s3[each.key].id

  rule {
    id     = "bootstrap-bucket-crr"
    status = "Enabled"

    dynamic "source_selection_criteria" {
      for_each = each.value.replication_destination_kms_key_arn == null ? [] : [1]

      content {
        sse_kms_encrypted_objects {
          status = "Enabled"
        }
      }
    }

    destination {
      bucket        = each.value.replication_destination_bucket_arn
      storage_class = "STANDARD"

      dynamic "encryption_configuration" {
        for_each = each.value.replication_destination_kms_key_arn == null ? [] : [1]
        content {
          replica_kms_key_id = each.value.replication_destination_kms_key_arn
        }
      }
    }
  }
}

data "aws_iam_policy_document" "s3_assume_role" {
  count = length(local.s3_buckets_replicated) >= 1 ? 1 : 0
  statement {
    sid     = "S3CRRRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "s3_replication" {
  for_each = local.s3_buckets_replicated

  statement {
    sid    = "S3GetList"
    effect = "Allow"
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket"
    ]

    resources = [aws_s3_bucket.s3[each.key].arn]
  }
  statement {
    sid    = "S3GetStatement"
    effect = "Allow"
    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging"
    ]

    resources = ["${aws_s3_bucket.s3[each.key].arn}/*"]
  }
  statement {
    sid    = "S3ReplicationStatement"
    effect = "Allow"
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags"
    ]

    resources = ["${each.value.replication_destination_bucket_arn}/*"]
  }

  dynamic "statement" {
    for_each = each.value.kms_key_arn == "" ? [] : [1]
    content {
      sid    = "DecryptSourceObject"
      effect = "Allow"
      actions = [
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ]
      resources = [each.value.kms_key_arn]
      condition {
        test     = "StringEquals"
        variable = "kms:ViaService"
        values   = ["s3.${data.aws_region.current.name}.amazonaws.com"]
      }
    }
  }

  dynamic "statement" {
    for_each = each.value.replication_destination_kms_key_arn == null ? [] : [1]
    content {
      sid    = "EncryptDestObject"
      effect = "Allow"
      actions = [
        "kms:Encrypt",
        "kms:GenerateDataKey"
      ]
      resources = [each.value.replication_destination_kms_key_arn]
      condition {
        test     = "StringEquals"
        variable = "kms:ViaService"
        values   = ["s3.${each.value.replication_destination_region}.amazonaws.com"]
      }
    }
  }
}

resource "aws_iam_role" "s3_replication" {
  count = length(local.s3_buckets_replicated) >= 1 ? 1 : 0

  name               = "${var.friendly_name_prefix}-s3-crr-iam-role-${data.aws_region.current.name}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.s3_assume_role[0].json
  tags = merge(
    { Name = "${var.friendly_name_prefix}-s3-crr-iam-role-${data.aws_region.current.name}" },
    var.common_tags
  )
}

resource "aws_iam_policy" "s3_replication" {
  for_each = local.s3_buckets_replicated

  name   = "${var.friendly_name_prefix}-s3-crr-iam-policy-${each.value.bucket_name}-${data.aws_region.current.name}"
  policy = data.aws_iam_policy_document.s3_replication[each.key].json
  tags = merge(
    { Name = "${var.friendly_name_prefix}-s3-crr-iam-policy-${each.value.bucket_name}-${data.aws_region.current.name}" },
    var.common_tags
  )
}

resource "aws_iam_policy_attachment" "s3_replication" {
  for_each = local.s3_buckets_replicated

  name       = "${var.friendly_name_prefix}-s3-crr-iam-policy-attachment-${each.value.bucket_name}-${data.aws_region.current.name}"
  roles      = [aws_iam_role.s3_replication[0].name]
  policy_arn = aws_iam_policy.s3_replication[each.key].arn
}

resource "aws_s3_bucket_lifecycle_configuration" "logging" {
  count  = try(local.s3_buckets_enabled.logging.lifecycle_enabled, false) ? 1 : 0
  bucket = aws_s3_bucket.s3["logging"].id
  rule {
    id     = "logging-expiration"
    status = local.s3_buckets_enabled.logging.lifecycle_enabled ? "Enabled" : "Disabled"

    expiration {
      days = local.s3_buckets_enabled.logging.lifecycle_expiration_days
    }
  }
}
