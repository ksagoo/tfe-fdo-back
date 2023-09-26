# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = module.vpc.vpc_arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = module.vpc.default_security_group_id
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "private_subnet_arns" {
  description = "List of ARNs of private subnets"
  value       = module.vpc.private_subnet_arns
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = module.vpc.private_subnets_cidr_blocks
}

output "private_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of private subnets in an IPv6 enabled VPC"
  value       = module.vpc.private_subnets_ipv6_cidr_blocks
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "public_subnet_arns" {
  description = "List of ARNs of public subnets"
  value       = module.vpc.public_subnet_arns
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = module.vpc.public_subnets_cidr_blocks
}

output "public_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of public subnets in an IPv6 enabled VPC"
  value       = module.vpc.public_subnets_ipv6_cidr_blocks
}

output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = module.vpc.public_route_table_ids
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = module.vpc.private_route_table_ids
}

output "database_subnet_ids" {
  description = "List of IDs of database subnets"
  value       = length(var.database_subnets) > 0 ? module.vpc.database_subnets : module.vpc.private_subnets
}

output "database_subnet_arns" {
  description = "List of ARNs of database subnets"
  value       = length(var.database_subnets) > 0 ? module.vpc.database_subnet_arns : module.vpc.private_subnet_arns
}

output "database_subnets_cidr_blocks" {
  description = "List of cidr_blocks of database subnets"
  value       = length(var.database_subnets) > 0 ? module.vpc.database_subnets_cidr_blocks : module.vpc.private_subnets_cidr_blocks
}

output "database_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of database subnets in an IPv6 enabled VPC"
  value       = length(var.database_subnets) > 0 ? module.vpc.database_subnets_ipv6_cidr_blocks : module.vpc.private_subnets_ipv6_cidr_blocks
}

output "database_subnet_group" {
  description = "ID of database subnet group. This will be null if var.database_subnets isn't populated and will be generated via the database module."
  value       = module.vpc.database_subnet_group
}

output "database_subnet_group_name" {
  description = "Name of database subnet group.  This will be null if var.database_subnets isn't populated and will be generated via the database module."
  value       = module.vpc.database_subnet_group_name
}

output "tls_endpoint_security_group_id" {
  description = "ID for the TLS security group that is created for endpoint access."
  value       = try(aws_security_group.tls.id, null)
}

output "tls_endpoint_security_group_name" {
  description = "Name for the TLS security group that is created for endpoint access."
  value       = try(aws_security_group.tls.name, null)
}