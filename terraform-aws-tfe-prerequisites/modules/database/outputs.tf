# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#------------------------------------------------------------------------------
# Networking
#------------------------------------------------------------------------------

output "db_cluster_port" {
  description = "Configured port that the database cluster is listening on."
  value       = module.rds.cluster_port
}

output "db_cluster_hosted_zone_id" {
  description = "The Route53 Hosted Zone ID of the endpoint"
  value       = module.rds.cluster_hosted_zone_id
}

output "db_security_group_id" {
  description = "The security group ID of the cluster"
  value       = module.rds.security_group_id
}

output "db_subnet_group_name" {
  description = "Database subnet group name"
  value       = module.rds.db_subnet_group_name
}

#------------------------------------------------------------------------------
# Cluster
#------------------------------------------------------------------------------

output "db_global_cluster_id" {
  description = "ID of the global cluster that has been created (if specified)."
  value       = try(time_sleep.cluster[0].triggers["global_cluster_id"], null)
}

output "db_cluster_arn" {
  description = "Amazon Resource Name (ARN) of cluster"
  value       = module.rds.cluster_arn
}

output "db_cluster_id" {
  description = "The RDS Cluster Identifier"
  value       = module.rds.cluster_id
}

output "db_cluster_resource_id" {
  description = "The RDS Cluster Resource ID"
  value       = module.rds.cluster_resource_id
}

output "db_cluster_members" {
  description = "List of RDS Instances that are a part of this cluster"
  value       = module.rds.cluster_members
}

output "db_cluster_endpoint" {
  description = "Writer endpoint for the cluster"
  value       = module.rds.cluster_endpoint
}

output "db_cluster_reader_endpoint" {
  description = "A read-only endpoint for the cluster, automatically load-balanced across replicas"
  value       = module.rds.cluster_reader_endpoint
}

output "db_cluster_engine_version_actual" {
  description = "The running version of the cluster database"
  value       = module.rds.cluster_engine_version_actual
}

output "db_cluster_database_name" {
  description = "Name for an automatically created database on cluster creation"
  value       = module.rds.cluster_database_name
}

output "db_cluster_instances" {
  description = "A map of cluster instances and their attributes"
  value       = module.rds.cluster_instances
}

output "db_additional_cluster_endpoints" {
  description = "A map of additional cluster endpoints and their attributes"
  value       = module.rds.additional_cluster_endpoints
}

output "db_cluster_role_associations" {
  description = "A map of IAM roles associated with the cluster and their attributes"
  value       = module.rds.cluster_role_associations
}

output "db_username" {
  description = "The database user that was created"
  value       = try(module.rds.cluster_master_username, "")
  sensitive   = true
}

output "db_password" {
  description = "The database user password"
  value       = try(module.rds.cluster_master_password, "")
  sensitive   = true
}

#------------------------------------------------------------------------------
# Monitoring
#------------------------------------------------------------------------------
output "db_enhanced_monitoring_iam_role_name" {
  description = "The name of the enhanced monitoring role"
  value       = module.rds.enhanced_monitoring_iam_role_name
}

output "db_enhanced_monitoring_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the enhanced monitoring role"
  value       = module.rds.enhanced_monitoring_iam_role_arn
}

output "db_enhanced_monitoring_iam_role_unique_id" {
  description = "Stable and unique string identifying the enhanced monitoring role"
  value       = module.rds.enhanced_monitoring_iam_role_unique_id
}

output "db_cluster_cloudwatch_log_groups" {
  description = "Map of CloudWatch log groups created and their attributes"
  value       = module.rds.db_cluster_cloudwatch_log_groups
}