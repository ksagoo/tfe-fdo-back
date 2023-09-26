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
    condition     = contains(["tfe", "tfefdo", "vault", "consul", "boundary", "nomad"], var.product)
    error_message = "`var.product` must be \"tfe\", \"tfefdo\", \"vault\", \"consul\", \"nomad\", or \"boundary\"."
  }
}

variable "common_tags" {
  type        = map(string)
  description = "Map of common tags for all taggable AWS resources."
  default     = {}
}

variable "iam_resources" {
  type = object({
    bucket_arns             = optional(list(string), [])
    kms_key_arns            = optional(list(string), [])
    secret_manager_arns     = optional(list(string), [])
    log_group_arn           = optional(string, "")
    log_forwarding_enabled  = optional(bool, true)
    role_name               = optional(string, "deployment-role")
    policy_name             = optional(string, "deployment-policy")
    ssm_enable              = optional(bool, false)
    custom_tbw_ecr_repo_arn = optional(string, "")
    session_recording_user  = optional(string, "")
  })
  description = "A list of objects for to be referenced in an IAM policy for the instance.  Each is a list of strings that reference infra related to the install"
}

variable "create_asg_service_iam_role" {
  type        = bool
  description = "Boolean to create a service linked role for AWS Auto Scaling.  This is required to be created prior to the KMS Key Policy.  This may or may not exist in an AWS Account and needs to be explicilty determined"
  default     = false
}

variable "asg_service_iam_role_custom_suffix" {
  type        = string
  description = "Custom suffix for the AWS Service Linked Role.  AWS IAM only allows unique names.  Leave blank with create_asg_service_iam_role to create the Default Service Linked Role, or add a value to create a secondary role for use with this module"
  default     = ""
}
