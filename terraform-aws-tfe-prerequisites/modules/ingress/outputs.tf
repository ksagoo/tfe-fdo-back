# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "lb_arn" {
  value       = try(aws_lb.lb.arn, null)
  description = "The Resource Identifier of the LB"
}

output "lb_arn_suffix" {
  value       = try(aws_lb.lb.arn_suffix, null)
  description = "ARN Suffix for use with CloudWatch Metrics."
}

output "lb_name" {
  value       = try(aws_lb.lb.name, null)
  description = "Name of the LB"
}

output "lb_dns_name" {
  value       = try(aws_lb.lb.dns_name, null)
  description = "The DNS name created with the LB"
}

output "lb_zone_id" {
  value       = try(aws_lb.lb.zone_id, null)
  description = "The Zone ID of the LB"
}

output "lb_internal" {
  value       = try(aws_lb.lb.internal, null)
  description = "Boolean value of the internal/external status of the LB.  Determines if the LB gets Elastic IPs assigned"
}

output "lb_security_group_ids" {
  value       = try(aws_lb.lb.security_groups, null)
  description = "List of security group IDs in use by the LB"
}

output "lb_tg_arns" {
  value       = try([for k, v in aws_lb_target_group.lb_tgs : v.arn], [])
  description = "List of target group ARNs for LB"
}

output "lb_tg_arns_map" {
  value       = try({ for k, v in aws_lb_target_group.lb_tgs : k => v.arn }, null)
  description = "Map of target group ARNs to Target Group Object Key"
}

output "lb_type" {
  value       = try(var.lb_type, null)
  description = "Type of LB created (ALB or NLB)"
}

output "acm_certificate_arn" {
  value       = try(module.acm[0].acm_certificate_arn, null)
  description = "The ARN of the certificate"
}

output "acm_certificate_status" {
  value       = try(module.acm[0].acm_certificate_status, null)
  description = "Status of the certificate"
}

output "acm_distinct_domain_names" {
  value       = try(module.acm[0].distinct_domain_names, null)
  description = "List of distinct domains names used for the validation"
}

output "acm_validation_domains" {
  value       = try(module.acm[0].validation_domains, null)
  description = "List of distinct domain validation options. This is useful if subject alternative names contain wildcards"
}

output "acm_validation_route53_record_fqdns" {
  value       = try(module.acm[0].validation_route53_record_fqdns, null)
  description = "List of FQDNs built using the zone domain and name"
}

output "route53_regional_record_name" {
  value       = try(aws_route53_record.r53_record.name, null)
  description = "Name of the regional LB Route53 record name"
}

output "route53_regional_fqdn" {
  value       = try(aws_route53_record.r53_record.fqdn, null)
  description = "FQDN of regional LB Route53 record"
}

output "route53_failover_record_name" {
  value       = try(aws_route53_record.failover[0].name, null)
  description = "Name of the failover LB Route53 record name"
}

output "route53_failover_fqdn" {
  value       = try(aws_route53_record.failover[0].fqdn, null)
  description = "FQDN of failover LB Route53 record"
}

