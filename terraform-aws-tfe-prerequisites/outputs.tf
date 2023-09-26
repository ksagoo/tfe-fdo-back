#------------------------------------------------------------------------------
# Network
#------------------------------------------------------------------------------
output "vpc_id" {
  description = "The ID of the VPC"
  value       = try(module.networking[0].vpc_id, null)
}

output "region" {
  description = "The AWS region where the resources have been created"
  value       = data.aws_region.current.name
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = try(module.networking[0].vpc_arn, null)
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = try(module.networking[0].vpc_cidr_block, null)
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = try(module.networking[0].default_security_group_id, null)
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = try(module.networking[0].private_subnet_ids, null)
}

output "private_subnet_arns" {
  description = "List of ARNs of private subnets"
  value       = try(module.networking[0].private_subnet_arns, null)
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = try(module.networking[0].private_subnets_cidr_blocks, null)
}

output "private_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of private subnets in an IPv6 enabled VPC"
  value       = try(module.networking[0].private_subnets_ipv6_cidr_blocks, null)
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = try(module.networking[0].public_subnet_ids, null)
}

output "public_subnet_arns" {
  description = "List of ARNs of public subnets"
  value       = try(module.networking[0].public_subnet_arns, null)
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = try(module.networking[0].public_subnets_cidr_blocks, null)
}

output "public_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of public subnets in an IPv6 enabled VPC"
  value       = try(module.networking[0].public_subnets_ipv6_cidr_blocks, null)
}

output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = try(module.networking[0].public_route_table_ids, null)
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = try(module.networking[0].private_route_table_ids, null)
}

output "db_subnet_ids" {
  description = "List of IDs of database subnets"
  value       = try(local.db_subnet_ids, null)
}

output "db_subnet_arns" {
  description = "List of ARNs of database subnets"
  value       = try(module.networking[0].database_subnet_arns, null)
}

output "db_subnets_cidr_blocks" {
  description = "List of cidr_blocks of database subnets"
  value       = try(module.networking[0].database_subnets_cidr_blocks, null)
}

output "db_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of database subnets in an IPv6 enabled VPC"
  value       = try(module.networking[0].database_subnets_ipv6_cidr_blocks, null)
}

output "db_subnet_group" {
  description = "ID of database subnet group"
  value       = try(module.networking[0].database_subnet_group != null ? module.networking[0].database_subnet_group : module.database[0].db_subnet_group, null)
}

output "db_subnet_group_name" {
  description = "Name of database subnet group"
  value       = try(module.networking[0].database_subnet_group != null ? module.networking[0].database_subnet_group : module.database[0].db_subnet_group, null)
}

output "tls_endpoint_security_group_id" {
  description = "ID for the TLS security group that is created for endpoint access."
  value       = try(module.networking[0].tls_endpoint_security_group_id, null)
}

output "tls_endpoint_security_group_name" {
  description = "Name for the TLS security group that is created for endpoint access."
  value       = try(module.networking[0].tls_endpoint_security_group_name, null)
}

output "redis_subnets" {
  description = "List of IDs of redis subnets"
  value       = try(local.db_subnet_ids, null)
}

output "redis_subnet_arns" {
  description = "List of ARNs of redis subnets"
  value       = try(module.networking[0].database_subnet_arns, null)
}

output "redis_subnets_cidr_blocks" {
  description = "List of cidr_blocks of redis subnets"
  value       = try(module.networking[0].database_subnets_cidr_blocks, null)
}

output "redis_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of redis subnets in an IPv6 enabled VPC"
  value       = try(module.networking[0].database_subnets_cidr_blocks, null)
}



#------------------------------------------------------------------------------
# Redis
#------------------------------------------------------------------------------
output "redis_security_group_id" {
  description = "ID of redis security group"
  value       = try(module.redis[0].redis_security_group_id, null)
}

output "redis_primary_endpoint" {
  value       = try(module.redis[0].redis_primary_endpoint, null)
  description = "Address of the endpoint of the primary node in the replication group."
}

output "redis_replication_group_arn" {
  value       = try(module.redis[0].redis_replication_group_arn, null)
  description = "ARN of the created Redis replication group."
}

output "redis_password" {
  value       = try(module.redis[0].redis_password, null)
  description = "Auth token that is used to access the Redis replication group."
  sensitive   = true
}

output "redis_port" {
  value       = try(module.redis[0].redis_port, null)
  description = "Port that the redis cluster is listening on."
}

output "redis_security_group_ids" {
  value       = try(module.redis[0].redis_security_group_ids, null)
  description = "List of security groups that are associated with the Redis replication group."
}

output "redis_subnet_group" {
  description = "ID of redis subnet group"
  value       = try(module.redis[0].redis_subnet_group_id, null)
}

output "redis_subnet_group_name" {
  description = "Name of redis subnet group"
  value       = try(module.redis[0].redis_subnet_group_name, null)
}

output "redis_security_group_name" {
  description = "Name of redis security group"
  value       = try(module.redis[0].redis_security_group_name, null)
}

#------------------------------------------------------------------------------
# S3
#------------------------------------------------------------------------------

output "s3_bucket_arn_list" {
  value       = try(module.s3[0].s3_bucket_arn_list, null)
  description = "A list of the ARNs for the buckets that have been configured"
}

output "s3_replication_iam_role_arn" {
  value       = try(module.s3[0].s3_replication_iam_role_arn, null)
  description = "ARN of IAM Role for S3 replication."
}

output "s3_bootstrap_bucket_name" {
  value       = try(module.s3[0].s3_bootstrap_bucket_name, null)
  description = "Name of S3 'bootstrap' bucket."
}

output "s3_bootstrap_bucket_arn" {
  value       = try(module.s3[0].s3_bootstrap_bucket_arn, null)
  description = "ARN of S3 'bootstrap' bucket"
}

output "s3_bootstrap_bucket_replication_policy" {
  value       = try(module.s3[0].s3_bootstrap_bucket_replication_policy, null)
  description = "Replication policy of the S3 'bootstrap' bucket."
}

output "s3_log_bucket_name" {
  value       = try(module.s3[0].s3_log_bucket_name, null)
  description = "Name of S3 'logging' bucket."
}

output "s3_log_bucket_arn" {
  value       = try(module.s3[0].s3_log_bucket_arn, null)
  description = "Name of S3 'logging' bucket."
}

output "s3_log_bucket_replication_policy" {
  value       = try(module.s3[0].s3_log_bucket_replication_policy, null)
  description = "Replication policy of the S3 'logging' bucket."
}

output "s3_tfe_app_bucket_name" {
  value       = try(module.s3[0].s3_tfe_app_bucket_name, null)
  description = "Name of S3 S3 Terraform Enterprise Object Store bucket."
}

output "s3_tfe_app_bucket_arn" {
  value       = try(module.s3[0].s3_tfe_app_bucket_arn, null)
  description = "ARN of the S3 Terraform Enterprise Object Store bucket."
}

output "s3_tfe_app_bucket_replication_policy" {
  value       = try(module.s3[0].s3_tfe_app_bucket_replication_policy, null)
  description = "Replication policy of the S3 Terraform Enterprise Object Store bucket."
}

#------------------------------------------------------------------------------
# KMS
#------------------------------------------------------------------------------
output "kms_key_arn" {
  value       = try(module.kms[0].kms_key_arn, null)
  description = "The KMS key used to encrypt data."
}

output "kms_key_alias" {
  value       = try(module.kms[0].kms_key_alias, null)
  description = "The KMS Key Alias"
}

output "kms_key_alias_arn" {
  value       = try(module.kms[0].kms_key_alias_arn, null)
  description = "The KMS Key Alias arn"
}

# #------------------------------------------------------------------------------
# # Secrets Manager
# #------------------------------------------------------------------------------
output "license_secret_arn" {
  value       = try(module.secrets_manager[0].license_arn, null)
  description = "AWS Secrets Manager tfe_license secret ARN."
}

output "tfe_console_password_arn" {
  value       = try(module.secrets_manager[0].tfe_console_password_arn, null)
  description = "AWS Secrets Manager console_password secret ARN."
}

output "tfe_enc_password_arn" {
  value       = try(module.secrets_manager[0].tfe_enc_password_arn, null)
  description = "AWS Secrets Manager enc_password secret ARN."
}

output "ca_certificate_bundle_secret_arn" {
  value       = try(module.secrets_manager[0].ca_certificate_bundle_secret_arn, null)
  description = "AWS Secrets Manager TFE BYO CA certificate secret ARN."
}

output "cert_pem_secret_arn" {
  value       = try(module.secrets_manager[0].cert_pem_secret_arn, null)
  description = "AWS Secrets Manager TFE BYO CA certificate private key secret ARN."
}

output "cert_pem_private_key_secret_arn" {
  value       = try(module.secrets_manager[0].cert_pem_private_key_secret_arn, null)
  description = "AWS Secrets Manager TFE BYO CA certificate private key secret ARN."
}

output "secret_arn_list" {
  value       = try(module.secrets_manager[0].secret_arn_list, null)
  description = "A list of AWS Secrets Manager Arns produced by the module"
}

output "optional_secrets" {
  value       = try(module.secrets_manager[0].optional_secrets, null)
  description = "A map of optional secrets that have been created if they were supplied during the time of execution. Output is a single map where the key of the map for the secret is the key and the ARN is the value."
}

#------------------------------------------------------------------------------
# CloudWatch
#------------------------------------------------------------------------------
output "log_group_name" {
  value       = try(aws_cloudwatch_log_group.tfe[0].name, null)
  description = "AWS CloudWatch Log Group Name."
}

#------------------------------------------------------------------------------
# TFE Key Pair
#------------------------------------------------------------------------------
output "ssh_keypair_name" {
  value       = try(aws_key_pair.ssh[0].key_name, null)
  description = "Name of the keypair that was created (if specified)."
}

output "ssh_keypair_arn" {
  value       = try(aws_key_pair.ssh[0].arn, null)
  description = "ARN of the keypair that was created (if specified)."
}

output "ssh_keypair_id" {
  value       = try(aws_key_pair.ssh[0].key_pair_id, null)
  description = "ID of the SSH Key Pair."
}

output "ssh_keypair_fingerprint" {
  value       = try(aws_key_pair.ssh[0].fingerprint, null)
  description = "Fingerprint of the  SSH Key Pair."
}

#------------------------------------------------------------------------------
# Databases
#------------------------------------------------------------------------------

output "db_cluster_arn" {
  description = "Amazon Resource Name (ARN) of cluster"
  value       = try(module.database[0].db_cluster_arn, null)
}

output "db_cluster_id" {
  description = "The RDS Cluster Identifier"
  value       = try(module.database[0].db_cluster_id, null)
}

output "db_cluster_resource_id" {
  description = "The RDS Cluster Resource ID"
  value       = try(module.database[0].db_cluster_resource_id, null)
}

output "db_cluster_members" {
  description = "List of RDS Instances that are a part of this cluster"
  value       = try(module.database[0].db_cluster_members, null)
}

output "db_cluster_endpoint" {
  description = "Writer endpoint for the cluster"
  value       = try(module.database[0].db_cluster_endpoint, null)
}

output "db_cluster_reader_endpoint" {
  description = "A read-only endpoint for the cluster, automatically load-balanced across replicas"
  value       = try(module.database[0].db_cluster_reader_endpoint, null)
}

output "db_cluster_engine_version_actual" {
  description = "The running version of the cluster database"
  value       = try(module.database[0].db_cluster_engine_version_actual, null)
}

output "db_cluster_database_name" {
  description = "Name for an automatically created database on cluster creation"
  value       = try(module.database[0].db_cluster_database_name, null)
}

output "db_cluster_port" {
  description = "The database port"
  value       = try(module.database[0].db_cluster_port, null)
}

output "db_password" {
  description = "The database master password"
  value       = try(module.database[0].db_password, null)
  sensitive   = true
}

output "db_username" {
  description = "The database master username"
  value       = try(module.database[0].db_username, null)
  sensitive   = true
}

output "db_cluster_instances" {
  description = "A map of cluster instances and their attributes"
  value       = try(module.database[0].db_cluster_instances, null)
}

output "db_additional_cluster_endpoints" {
  description = "A map of additional cluster endpoints and their attributes"
  value       = try(module.database[0].db_additional_cluster_endpoints, null)
}

output "db_cluster_role_associations" {
  description = "A map of IAM roles associated with the cluster and their attributes"
  value       = try(module.database[0].db_cluster_role_associations, null)
}

output "db_enhanced_monitoring_iam_role_name" {
  description = "The name of the enhanced monitoring role"
  value       = try(module.database[0].db_enhanced_monitoring_iam_role_name, null)
}

output "db_enhanced_monitoring_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the enhanced monitoring role"
  value       = try(module.database[0].db_enhanced_monitoring_iam_role_arn, null)
}

output "db_enhanced_monitoring_iam_role_unique_id" {
  description = "Stable and unique string identifying the enhanced monitoring role"
  value       = try(module.database[0].db_enhanced_monitoring_iam_role_unique_id, null)
}

output "db_security_group_id" {
  description = "The security group ID of the cluster"
  value       = try(module.database[0].db_security_group_id, null)
}

output "db_global_cluster_id" {
  description = "ID of the global cluster that has been created (if specified.)"
  value       = try(module.database[0].db_global_cluster_id, null)
}

output "db_cluster_cloudwatch_log_groups" {
  description = "Map of CloudWatch log groups created and their attributes"
  value       = try(module.database[0].db_cluster_cloudwatch_log_groups, null)
}
#------------------------------------------------------------------------------
# TFE IAM Resources
#------------------------------------------------------------------------------
output "iam_role_arn" {
  value       = try(module.iam[0].iam_role_arn, null)
  description = "ARN of IAM Role in use by TFE Instances"
}

output "iam_role_name" {
  value       = try(module.iam[0].iam_role_name, null)
  description = "Name of IAM Role in use by TFE Instances"
}

output "iam_managed_policy_arn" {
  value       = try(module.iam[0].iam_managed_policy_arn, null)
  description = "ARN of IAM Managed Policy for TFE Instance Role"
}

output "iam_managed_policy_name" {
  value       = try(module.iam[0].iam_managed_policy_name, null)
  description = "Name of IAM Managed Policy for TFE Instance Role"
}

output "iam_instance_profile" {
  value       = try(module.iam[0].iam_instance_profile, null)
  description = "ARN of IAM Instance Profile for TFE Instance Role"
}

output "iam_asg_service_role" {
  value       = try(module.iam[0].asg_role_arn, null)
  description = "ARN of AWS Service Linked Role for AWS EC2 AutoScaling"
}
#------------------------------------------------------------------------------
# TFE Ingress Resources
#------------------------------------------------------------------------------
output "lb_arn" {
  value       = try(module.ingress[0].lb_arn, null)
  description = "The Resource Identifier of the LB"
}

output "lb_name" {
  value       = try(module.ingress[0].lb_name, null)
  description = "Name of the LB"
}

output "lb_dns_name" {
  value       = try(module.ingress[0].lb_dns_name, null)
  description = "The DNS name created with the LB"
}

output "lb_zone_id" {
  value       = try(module.ingress[0].lb_zone_id, null)
  description = "The Zone ID of the LB"
}

output "lb_internal" {
  value       = try(module.ingress[0].internal, null)
  description = "Boolean value of the internal/external status of the LB.  Determines if the LB gets Elastic IPs assigned"
}

output "lb_security_group_ids" {
  value       = try(module.ingress[0].lb_security_group_ids, null)
  description = "List of security group IDs in use by the LB"
}

output "lb_tg_arns" {
  value       = try(module.ingress[0].lb_tg_arns, [])
  description = "List of target group ARNs for LB"
}

output "lb_type" {
  value       = try(module.ingress[0].lb_type, null)
  description = "Type of LB created (ALB or NLB)"
}

output "acm_certificate_arn" {
  value       = try(module.ingress[0].acm_certificate_arn, null)
  description = "The ARN of the certificate"
}

output "acm_certificate_status" {
  value       = try(module.ingress[0].acm_certificate_status, null)
  description = "Status of the certificate"
}

output "acm_distinct_domain_names" {
  value       = try(module.ingress[0].acm_distinct_domain_names, null)
  description = "List of distinct domains names used for the validation"
}

output "acm_validation_domains" {
  value       = try(module.ingress[0].acm_validation_domains, null)
  description = "List of distinct domain validation options. This is useful if subject alternative names contain wildcards"
}

output "acm_validation_route53_record_fqdns" {
  value       = try(module.ingress[0].acm_validation_route53_record_fqdns, null)
  description = "List of FQDNs built using the zone domain and name"
}

output "route53_regional_record_name" {
  value       = try(module.ingress[0].route53_regional_record_name, null)
  description = "Name of the regional LB Route53 record name"
}

output "route53_regional_fqdn" {
  value       = try(module.ingress[0].route53_regional_fqdn, null)
  description = "FQDN of regional LB Route53 record"
}

output "route53_failover_record_name" {
  value       = try(module.ingress[0].route53_failover_record_name, null)
  description = "Name of the failover LB Route53 record name"
}

output "route53_failover_fqdn" {
  value       = try(module.ingress[0].route53_failover_fqdn, null)
  description = "FQDN of failover LB Route53 record"
}

output "asg_hook_value" {
  value       = try(module.iam[0].asg_hook_value, null)
  description = "Value for the `asg-hook` tag that will be attatched to the TFE instance in the other module. Use this value to ensure the lifecycle hook is updated during deployment."
}

