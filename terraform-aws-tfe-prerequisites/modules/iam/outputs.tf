# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "iam_role_arn" {
  value       = try(aws_iam_role.instance_role.arn, null)
  description = "ARN of IAM role in use by the instances"
}

output "iam_role_name" {
  value       = try(aws_iam_role.instance_role.name, null)
  description = "Name of IAM role in use by the instances"
}

output "iam_managed_policy_arn" {
  value       = try(aws_iam_policy.instance_role_policy.arn, null)
  description = "ARN of IAM managed policy for the instance role"
}

output "iam_managed_policy_name" {
  value       = try(aws_iam_policy.instance_role_policy.name, null)
  description = "Name of IAM managed policy for the instance role"
}

output "iam_instance_profile" {
  value       = try(aws_iam_instance_profile.instance_profile.arn, null)
  description = "ARN of IAM instance profile for the instance role"
}

output "asg_hook_value" {
  value       = "${local.name}-asg-hook"
  description = "Value for the `asg-hook` tag that will be attatched to the instance in the other module. Use this value to ensure the lifecycle hook is updated during deployment."
}

output "asg_role_arn" {
  value       = data.aws_iam_role.asg_role.arn
  description = "ARN of AWS Service Linked Role for AWS EC2 AutoScaling"
}

output "iam_boundary_user" {
  value       = try(aws_iam_user.boundary_user[0].name, null)
  description = "Name of IAM user for Boundary Session Recording"
}