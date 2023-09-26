variable "friendly_name_prefix" {
  type        = string
  description = "Friendly name prefix used for tagging and naming AWS resources."
}


variable "vpc_id" {
  type        = string
  description = "VPC ID that will be used by the workloads."
}


variable "common_tags" {
  type        = map(string)
  description = "Map of common tags for all taggable AWS resources."
  default     = {}
}

variable "product" {
  type        = string
  description = "Name of the HashiCorp product that will consume this service (tfe, tfefdo, vault, consul, nomad, boundary)"
  validation {
    condition     = contains(["tfe", "tfefdo", "vault", "consul", "nomad", "boundary"], var.product)
    error_message = "`var.product` must be \"tfe\", \"tfefdo\", \"vault\", \"consul\", \"nomad\", or \"boundary\"."
  }
}


variable "redis_engine" {
  type        = string
  default     = "redis"
  description = "Engine that will be provisioned for the elasticache replication group"
}

variable "redis_replication_group_description" {
  type        = string
  default     = "External Redis Replication Group for TFE Active/Active"
  description = "Description that will be associated with the Redis replication group "
}

variable "redis_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to use for Redis replication group subnet group."
  default     = []
}

variable "redis_subnet_group_name" {
  type        = string
  description = "Name of the existing subnet group for the Redis replication group to use."
  default     = null
}

variable "redis_engine_version" {
  type        = string
  description = "Redis version number."
  default     = "6.2"
}

variable "redis_port" {
  type        = number
  description = "Port number the Redis nodes will accept connections on."
  default     = 6379
}

variable "redis_parameter_group_name" {
  type        = string
  description = "Name of parameter group to associate with the Redis replication group."
  default     = "default.redis6.x"
}

variable "redis_node_type" {
  type        = string
  description = "Type of Redis node from a compute, memory, and network throughput standpoint."
  default     = "cache.m5.large"
}

variable "redis_security_group_ids" {
  type        = list(string)
  description = "List of existing security groups to associate with the Redis replication group. If Active/Active is true and this is default, the one created in the VPC module will be used."
  default     = []
}

variable "redis_enable_multi_az" {
  type        = bool
  description = "Boolean for deploying Redis nodes in multiple Availability Zones and enabling automatic failover."
  default     = true
}

variable "redis_enable_encryption_at_rest" {
  type        = bool
  description = "Boolean to enable encryption at rest on Redis replication group. A `kms_key_arn` is required when set to `true`."
  default     = false
}

variable "redis_password" {
  type        = string
  description = "Password (auth token) used to enable transit encryption (TLS) with Redis."
  default     = ""
  validation {
    condition     = var.redis_password != ""
    error_message = "When creating a Redis cluster, the variable `redis_password` is required."
  }
  validation {
    condition     = length(var.redis_password) >= 16
    error_message = "`redis_password` must be at least 16 characters in length."
  }
}

variable "redis_kms_key_arn" {
  type        = string
  description = "ARN of KMS key that will be used to encrypt the storage for the database instances."
  default     = ""
}

variable "redis_log_group_name" {
  type        = string
  description = "Name of the Cloud Watch Log Group to be used for Redis Logs."
  default     = ""
}

variable "redis_enable_transit_encryption" {
  type        = bool
  description = "Boolean to enable transit encryption on the Redis replication group."
  default     = true
}
