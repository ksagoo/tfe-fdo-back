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

variable "vpc_name" {
  type        = string
  description = "Friendly name prefix used for tagging and naming AWS resources."
  default     = "tfe-vpc"
}

variable "vpc_enable_ssm" {
  type        = bool
  description = "Boolean that when true will create a security group allowing port 443 to the private_subnets"
  default     = false
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
  default     = null
}

variable "vpc_default_security_group_egress" {
  type        = list(map(string))
  description = "List of maps of egress rules to set on the default security group"
  default     = []
}

variable "vpc_default_security_group_ingress" {
  type        = list(map(string))
  description = "List of maps of ingress rules to set on the default security group"
  default     = []
}

variable "vpc_option_flags" {
  type = object({
    create_igw                    = optional(bool, true)
    enable_dns_hostnames          = optional(bool, true)
    enable_dns_support            = optional(bool, true)
    enable_nat_gateway            = optional(bool, true)
    map_public_ip_on_launch       = optional(bool, true)
    manage_default_security_group = optional(bool, true)
    one_nat_gateway_per_az        = optional(bool, false)
    single_nat_gateway            = optional(bool, false)
  })
  description = "Object map of boolean flags to enable or disable certain features of the AWS VPC"
  default     = {}
}

variable "create_vpc_endpoint_access_public_subnets" {
  type        = bool
  description = "Boolean to enable endpoint access for the public subnets"
  default     = false
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet CIDR ranges to create in the VPC."
  default     = []
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet CIDR ranges to create in the VPC."
  default     = []
}

variable "database_subnets" {
  type        = list(string)
  description = "List of database subnets CIDR ranges to create in the VPC."
  default     = []
}

variable "vpc_endpoint_flags" {
  type = object({
    create_ec2         = optional(bool, true)
    create_ec2messages = optional(bool, true)
    create_kms         = optional(bool, true)
    create_s3          = optional(bool, true)
    create_ssm         = optional(bool, true)
    create_ssmmessages = optional(bool, true)
  })
  description = "Collection of flags to enable various VPC Endpoints"
  default     = {}
}
