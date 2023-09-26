# # Copyright (c) HashiCorp, Inc.
# # SPDX-License-Identifier: MPL-2.0

#------------------------------------------------------------------------------
# General Outputs
#------------------------------------------------------------------------------

output "license_arn" {
  value       = try(aws_secretsmanager_secret.secrets["license"].arn, null)
  description = "AWS Secrets Manager `license` secret ARN."
}

output "ca_certificate_bundle_secret_arn" {
  value       = try(aws_secretsmanager_secret.secrets["ca_certificate_bundle"].arn, null)
  description = "AWS Secrets Manager TFE BYO CA certificate bundle ARN."
}

output "cert_pem_secret_arn" {
  value       = try(aws_secretsmanager_secret.secrets["cert_pem_secret"].arn, null)
  description = "AWS Secrets Manager TFE BYO CA certificate private key secret ARN."
}

output "cert_pem_private_key_secret_arn" {
  value       = try(aws_secretsmanager_secret.secrets["cert_pem_private_key_secret"].arn, null)
  description = "AWS Secrets Manager TFE BYO CA certificate private key secret ARN."
}

output "secret_arn_list" {
  value       = [for secret in aws_secretsmanager_secret.secrets : secret.arn]
  description = "A list of AWS Secrets Manager ARNs produced by the module."
}

output "optional_secrets" {
  value       = length(var.optional_secrets) >= 1 ? { for k, v in local.optional_secrets : k => aws_secretsmanager_secret.secrets[k].arn } : {}
  description = "A map of optional secrets that have been created if they were supplied during the time of execution. Output is a single map where the key of the map for the secret is the key and the ARN is the value."
}
#------------------------------------------------------------------------------
# TFE Outputs
#------------------------------------------------------------------------------

output "tfe_console_password_arn" {
  value       = try(aws_secretsmanager_secret.secrets["tfe_console_password"].arn, null)
  description = "AWS Secrets Manager `console_password` secret ARN."
}

output "tfe_enc_password_arn" {
  value       = try(aws_secretsmanager_secret.secrets["tfe_enc_password"].arn, null)
  description = "AWS Secrets Manager `enc_password` secret ARN."
}

#------------------------------------------------------------------------------
# Consul Outputs
#------------------------------------------------------------------------------

output "consul_acl_token_arn" {
  value       = try(aws_secretsmanager_secret.secrets["consul_acl_token"].arn, null)
  description = "AWS Secrets Manager `consul_acl_token` secret ARN."
}

output "consul_gossip_key_arn" {
  value       = try(aws_secretsmanager_secret.secrets["consul_gossip_key"].arn, null)
  description = "AWS Secrets Manager `consul_gossip_key` secret ARN."
}

output "consul_mesh_gw_token_arn" {
  value       = try(aws_secretsmanager_secret.secrets["consul_mesh_gw_token"].arn, null)
  description = "AWS Secrets Manager `consul_mesh_gw_token` secret ARN."
}

output "consul_ingress_gw_token" {
  value       = try(aws_secretsmanager_secret.secrets["consul_ingress_gw_token"].arn, null)
  description = "AWS Secrets Manager `consul_ingress_gw_token` secret ARN."
}