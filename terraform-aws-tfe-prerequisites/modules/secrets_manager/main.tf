# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  provided_secrets  = { for parameter, value in var.secretsmanager_secrets : parameter => value if value != null /* object */ }
  optional_secrets  = length(var.optional_secrets) >= 1 ? { for parameter, value in var.optional_secrets : parameter => value if value != null /* object */ } : {}
  generate_secrets  = { for k, v in local.provided_secrets : k => v if try(v.generate, false) && try(v.data, null) == null }
  product_generated = { for k, v in local.generate_secrets : k => v if startswith(k, var.product) }


  generated_secrets = {
    consul_gossip_key = {
      data = try(random_id.gossip_gen[0].b64_std, null)
    }
    consul_acl_token = {
      data = try(random_uuid.bootstrap_gen[0].result, null)
    }
    tfe_console_password = {
      data = try(random_password.tfe["tfe_console_password"].result, null)
    }
    tfe_enc_password = {
      data = try(random_password.tfe["tfe_enc_password"].result, null)
    }
  }

  merge_generated = { for k, v in local.product_generated : k => merge(v, lookup(local.generated_secrets, k, v.data)) }

  merged_secrets = merge(local.provided_secrets, local.optional_secrets, local.merge_generated)
}


resource "random_password" "tfe" {
  for_each         = var.product == "tfe" ? local.product_generated : {}
  length           = 16
  special          = true
  min_special      = 1
  min_numeric      = 1
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_id" "gossip_gen" {
  count       = try(local.product_generated.consul_gossip_key.generate, false) ? 1 : 0
  byte_length = 32
}

resource "random_uuid" "bootstrap_gen" {
  count = try(local.product_generated.consul_acl_token.generate, false) ? 1 : 0
}

resource "aws_secretsmanager_secret" "secrets" {
  for_each    = local.merged_secrets
  name        = "${var.friendly_name_prefix}-${each.value.name}"
  description = each.value.description
  tags        = var.common_tags
}

resource "aws_secretsmanager_secret_version" "secrets" {
  for_each      = local.merged_secrets
  secret_binary = try(filebase64(each.value.path), null)
  secret_string = try(each.value.data, null)
  secret_id     = aws_secretsmanager_secret.secrets[each.key].id
  lifecycle {
    precondition {
      condition     = (var.product == "consul" && try(local.merged_secrets.license.path, null) == null) || var.product != "consul"
      error_message = "The Consul Enterprise license needs to be submitted as a string value using the `data` key. This is because the license file is too small and base64 encoding adds padding which leads to Terraform thinking the value changed and needs to be replaced."
    }
  }
}

