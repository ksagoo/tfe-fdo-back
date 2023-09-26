# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "kms_key_arn" {
  value       = aws_kms_key.key.arn
  description = "The KMS key used to encrypt data."
}

output "kms_key_alias" {
  value       = aws_kms_alias.alias.name
  description = "The KMS Key Alias"
}

output "kms_key_alias_arn" {
  value       = aws_kms_alias.alias.arn
  description = "The KMS Key Alias arn"
}

output "kms_key_id" {
  value       = aws_kms_key.key.key_id
  description = "The KMS Key ID"
}
