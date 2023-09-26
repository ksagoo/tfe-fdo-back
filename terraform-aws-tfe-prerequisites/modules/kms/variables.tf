# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "friendly_name_prefix" {
  type        = string
  description = "Friendly name prefix used for tagging and naming AWS resources."
}

variable "product" {
  type        = string
  description = "Name of the HashiCorp product that will consume this service (tfe, tfefdo, vault, consul, nomad, boundary)"
  validation {
    condition     = contains(["tfe", "tfefdo", "vault", "consul", "nomad", "boundary"], var.product)
    error_message = "`var.product` must be \"tfe\", \"tfefdo\", \"vault\", \"consul\", \"nomad\", or \"boundary\"."
  }
}

variable "common_tags" {
  type        = map(string)
  description = "Map of common tags for all taggable AWS resources."
  default     = {}
}

variable "kms_key_description" {
  description = "Description that will be attached to the KMS key (if created)"
  type        = string
  default     = "AWS KMS Customer-managed key to encrypt RDS, S3, EBS, etc."
}

variable "kms_key_usage" {
  description = "Intended use of the KMS key that will be created."
  type        = string
  default     = "ENCRYPT_DECRYPT"
}

variable "kms_key_deletion_window" {
  type        = number
  description = "Duration in days to destroy the key after it is deleted. Must be between 7 and 30 days."
  default     = 7
}

variable "kms_allow_asg_to_cmk" {
  type        = bool
  description = "Boolen to create a KMS CMK Key policy that grants the Service Linked Role AWSServiceRoleForAutoScaling permissions to the CMK."
  default     = true
}

variable "kms_key_name" {
  description = "Name that will be added to the KMS key via tags"
  type        = string
  default     = "kms-key"
}

variable "kms_default_policy_enabled" {
  description = "Enables a default policy that allows KMS operations to be defined by IAM"
  type        = string
  default     = true
}

variable "kms_key_users_or_roles" {
  type        = list(string)
  description = "List of arns for users or roles that should have access to perform Cryptographic Operations with KMS Key"
  default     = []
}

variable "kms_asg_role_arn" {
  type        = string
  description = "ARN of AWS Service Linked role for AWS Autoscaling."
  default     = ""
}

variable "create_multi_region_key" {
  type        = bool
  description = "Boolean to enable a multi-region key pair"
  default     = false
}
