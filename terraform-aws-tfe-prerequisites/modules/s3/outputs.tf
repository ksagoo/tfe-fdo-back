# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "s3_replication_iam_role_arn" {
  value       = try(aws_iam_role.s3_replication[0].arn, null)
  description = "ARN of IAM Role for S3 replication."
}

output "s3_replication_policy" {
  value       = try(aws_iam_policy.s3_replication[0].policy, null)
  description = "Replication policy of the S3 'bootstrap' bucket."
}

output "s3_bootstrap_bucket_name" {
  value       = try(aws_s3_bucket.s3["bootstrap"].id, null)
  description = "Name of S3 'bootstrap' bucket."
}

output "s3_bootstrap_bucket_arn" {
  value       = try(aws_s3_bucket.s3["bootstrap"].arn, null)
  description = "ARN of S3 'bootstrap' bucket"
}

output "s3_log_bucket_name" {
  value       = try(aws_s3_bucket.s3["logging"].id, null)
  description = "Name of S3 'logging' bucket."
}

output "s3_log_bucket_arn" {
  value       = try(aws_s3_bucket.s3["logging"].arn, null)
  description = "Name of S3 'logging' bucket."
}

output "s3_tfe_app_bucket_name" {
  value       = try(aws_s3_bucket.s3["tfe_app"].id, null)
  description = "Name of S3 Terraform Enterprise Object Store bucket."
}

output "s3_tfe_app_bucket_arn" {
  value       = try(aws_s3_bucket.s3["tfe_app"].arn, null)
  description = "ARN of S3 Terraform Enterprise Object Store bucket."
}

output "s3_snapshot_bucket_name" {
  value       = try(aws_s3_bucket.s3["snapshot"].id, null)
  description = "Name of S3 HashiCorp Enterprise Object Store bucket for Snapshots."
}

output "s3_snapshot_bucket_arn" {
  value       = try(aws_s3_bucket.s3["snapshot"].arn, null)
  description = "ARN of S3 HashiCorp Enterprise Object Store bucket for Snapshots."
}

output "s3_bucket_arn_list" {
  value       = [for bucket in aws_s3_bucket.s3 : bucket.arn]
  description = "A list of the ARNs for the buckets that have been configured"
}
