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

variable "product" {
  type        = string
  description = "Name of the HashiCorp product that will consume this service (tfe, tfenext, vault, consul, nomad, boundary)"
  validation {
    condition     = contains(["tfe", "tfenext", "vault", "consul", "boundary", "nomad"], var.product)
    error_message = "`var.product` must be \"tfe\", \"tfenext\", \"vault\", \"consul\", \"nomad\", or \"boundary\"."
  }
}

variable "secretsmanager_secrets" {
  type = object({
    license = optional(object({
      name        = optional(string, "license")
      path        = optional(string, null)
      description = optional(string, "license")
      data        = optional(string, null)
    }))
    tfe_console_password = optional(object({
      name        = optional(string, "console-password")
      description = optional(string, "Console password used in the TFE installation")
      data        = optional(string, null)
    }))
    tfe_enc_password = optional(object({
      name        = optional(string, "enc-password")
      description = optional(string, "Encryption password used in the TFE installation")
      data        = optional(string, null)
    }))
    consul_acl_token = optional(object({
      name        = optional(string, null)
      path        = optional(string, null)
      description = optional(string, "Consul default ACL token")
      data        = optional(string, null)
      generate    = optional(bool, true)
    }))
    consul_gossip_key = optional(object({
      name        = optional(string, null)
      path        = optional(string, null)
      description = optional(string, "Consul gossip encryption key")
      data        = optional(string, null)
      generate    = optional(bool, true)
    }))
    consul_mesh_gw_token = optional(object({
      name        = optional(string, null)
      path        = optional(string, null)
      description = optional(string, "Consul gossip encryption key")
      data        = optional(string, null)
      generate    = optional(bool, true)
    }))
    consul_ingress_gw_token = optional(object({
      name        = optional(string, null)
      path        = optional(string, null)
      description = optional(string, "Consul gossip encryption key")
      data        = optional(string, null)
      generate    = optional(bool, true)
    }))
    ca_certificate_bundle = optional(object({
      name        = optional(string, null)
      path        = optional(string, null)
      description = optional(string, "BYO CA certificate bundle")
      data        = optional(string, null)
    }))
    cert_pem_secret = optional(object({
      name        = optional(string, null)
      path        = optional(string, null)
      description = optional(string, "BYO PEM-encoded TLS certificate")
      data        = optional(string, null)
    }))
    cert_pem_private_key_secret = optional(object({
      name        = optional(string, null)
      path        = optional(string, null)
      description = optional(string, "BYO PEM-encoded TLS private key")
      data        = optional(string, null)
    }))
  })
  description = "Object Map that contains various secrets that will be created and stored in AWS Secrets Manager."
  default     = {}
}

variable "optional_secrets" {
  type        = map(any)
  default     = {}
  description = <<DESC
  Optional variable that when supplied will be merged with the `secretsmanager_secrets` map. These secrets need to have the following specification:
  optional_secrets = {
    secret_1 = {
      name = "supesecret"
      description = "it's my secret that is important"
      path = "path to file if you are using one"
      data = "string data if you are supplying it"
    }
    secret_2 = {
      name = "supesecret2"
      description = "it's my secret that is also important probably"
      path = "path to file if you are using one"
      data = "string data if you are supplying it"
    }
  }
  DESC
}