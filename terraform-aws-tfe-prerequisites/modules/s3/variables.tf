# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "friendly_name_prefix" {
  type        = string
  description = "Friendly name prefix used for tagging and naming AWS resources."
}

variable "common_tags" {
  type        = map(string)
  description = "Map of common tags for all taggable AWS resources."
  default     = {}
}

variable "s3_buckets" {
  type = object({
    bootstrap = optional(object({
      create                              = optional(bool, true)
      bucket_name                         = optional(string, "tfe-bootstrap-bucket")
      description                         = optional(string, "Bootstrap bucket for the TFE instances and install")
      versioning                          = optional(bool, true)
      force_destroy                       = optional(bool, false)
      replication                         = optional(bool)
      replication_destination_bucket_arn  = optional(string)
      replication_destination_kms_key_arn = optional(string)
      replication_destination_region      = optional(string)
      encrypt                             = optional(bool, true)
      bucket_key_enabled                  = optional(bool, true)
      kms_key_arn                         = optional(string)
      sse_s3_managed_key                  = optional(bool, false)
      is_secondary_region                 = optional(bool, false)
    }))
    tfe_app = optional(object({
      create                              = optional(bool, true)
      bucket_name                         = optional(string, "tfe-app-bucket")
      description                         = optional(string, "Object store for TFE")
      versioning                          = optional(bool, true)
      force_destroy                       = optional(bool, false)
      replication                         = optional(bool)
      replication_destination_bucket_arn  = optional(string)
      replication_destination_kms_key_arn = optional(string)
      replication_destination_region      = optional(string)
      encrypt                             = optional(bool, true)
      bucket_key_enabled                  = optional(bool, true)
      kms_key_arn                         = optional(string)
      sse_s3_managed_key                  = optional(bool, false)
      is_secondary_region                 = optional(bool, false)
    }))
    logging = optional(object({
      create                              = optional(bool, true)
      bucket_name                         = optional(string, "hashicorp-log-bucket")
      versioning                          = optional(bool, false)
      force_destroy                       = optional(bool, false)
      replication                         = optional(bool, false)
      replication_destination_bucket_arn  = optional(string)
      replication_destination_kms_key_arn = optional(string)
      replication_destination_region      = optional(string)
      encrypt                             = optional(bool, true)
      bucket_key_enabled                  = optional(bool, true)
      kms_key_arn                         = optional(string)
      sse_s3_managed_key                  = optional(bool, false)
      lifecycle_enabled                   = optional(bool, true)
      lifecycle_expiration_days           = optional(number, 7)
      is_secondary_region                 = optional(bool, false)
    }))
    snapshot = optional(object({
      create                              = optional(bool, true)
      bucket_name                         = optional(string, "snapshot-bucket")
      description                         = optional(string, "Storage location for HashiCorp snapshots that will be exported")
      versioning                          = optional(bool, true)
      force_destroy                       = optional(bool, false)
      replication                         = optional(bool, false)
      replication_destination_bucket_arn  = optional(string)
      replication_destination_kms_key_arn = optional(string)
      replication_destination_region      = optional(string)
      encrypt                             = optional(bool, true)
      bucket_key_enabled                  = optional(bool, true)
      kms_key_arn                         = optional(string)
      sse_s3_managed_key                  = optional(bool, false)
    }))
  })
  description = "Object Map that contains the configuration for the S3 logging and bootstrap bucket configuration."
  default     = {}
}
