#------------------------------------------------------------------------------
# Network
#------------------------------------------------------------------------------
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.pre_req_primary.vpc_id
}

output "region" {
  description = "The AWS region where the resources have been created"
  value       = module.pre_req_primary.region
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = module.pre_req_primary.vpc_arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.pre_req_primary.vpc_cidr_block
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = module.pre_req_primary.default_security_group_id
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.pre_req_primary.private_subnet_ids
}

output "private_subnet_arns" {
  description = "List of ARNs of private subnets"
  value       = module.pre_req_primary.private_subnet_arns
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = module.pre_req_primary.private_subnets_cidr_blocks
}

output "private_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of private subnets in an IPv6 enabled VPC"
  value       = module.pre_req_primary.private_subnets_ipv6_cidr_blocks
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.pre_req_primary.public_subnet_ids
}

output "public_subnet_arns" {
  description = "List of ARNs of public subnets"
  value       = module.pre_req_primary.public_subnet_arns
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = module.pre_req_primary.public_subnets_cidr_blocks
}

output "public_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of public subnets in an IPv6 enabled VPC"
  value       = module.pre_req_primary.public_subnets_ipv6_cidr_blocks
}

output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = module.pre_req_primary.public_route_table_ids
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = module.pre_req_primary.private_route_table_ids
}

output "db_subnet_ids" {
  description = "List of IDs of database subnets"
  value       = module.pre_req_primary.db_subnet_ids
}

output "db_subnet_arns" {
  description = "List of ARNs of database subnets"
  value       = module.pre_req_primary.db_subnet_arns
}

output "db_subnets_cidr_blocks" {
  description = "List of cidr_blocks of database subnets"
  value       = module.pre_req_primary.db_subnets_cidr_blocks
}

output "db_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of database subnets in an IPv6 enabled VPC"
  value       = module.pre_req_primary.db_subnets_ipv6_cidr_blocks
}

output "db_subnet_group" {
  description = "ID of database subnet group"
  value       = module.pre_req_primary.db_subnet_group
}

output "db_subnet_group_name" {
  description = "Name of database subnet group"
  value       = module.pre_req_primary.db_subnet_group_name
}

#------------------------------------------------------------------------------
# S3
#------------------------------------------------------------------------------

output "s3_bucket_arn_list" {
  value       = module.pre_req_primary.s3_bucket_arn_list
  description = "A list of the ARNs for the buckets that have been configured"
}

output "s3_replication_iam_role_arn" {
  value       = module.pre_req_primary.s3_replication_iam_role_arn
  description = "ARN of IAM Role for S3 replication."
}

output "s3_bootstrap_bucket_name" {
  value       = module.pre_req_primary.s3_bootstrap_bucket_name
  description = "Name of S3 'bootstrap' bucket."
}

output "s3_bootstrap_bucket_arn" {
  value       = module.pre_req_primary.s3_bootstrap_bucket_arn
  description = "ARN of S3 'bootstrap' bucket"
}

output "s3_bootstrap_bucket_replication_policy" {
  value       = module.pre_req_primary.s3_bootstrap_bucket_replication_policy
  description = "Replication policy of the S3 'bootstrap' bucket."
}

output "s3_log_bucket_name" {
  value       = module.pre_req_primary.s3_log_bucket_name
  description = "Name of S3 'logging' bucket."
}

output "s3_log_bucket_arn" {
  value       = module.pre_req_primary.s3_log_bucket_arn
  description = "Name of S3 'logging' bucket."
}

output "s3_log_bucket_replication_policy" {
  value       = module.pre_req_primary.s3_log_bucket_replication_policy
  description = "Replication policy of the S3 'logging' bucket."
}

output "s3_tfe_app_bucket_name" {
  value       = module.pre_req_primary.s3_tfe_app_bucket_name
  description = "Name of S3 S3 Terraform Enterprise Object Store bucket."
}

output "s3_tfe_app_bucket_arn" {
  value       = module.pre_req_primary.s3_tfe_app_bucket_arn
  description = "ARN of the S3 Terraform Enterprise Object Store bucket."
}

output "s3_tfe_app_bucket_replication_policy" {
  value       = module.pre_req_primary.s3_tfe_app_bucket_replication_policy
  description = "Replication policy of the S3 Terraform Enterprise Object Store bucket."
}

#------------------------------------------------------------------------------
# KMS
#------------------------------------------------------------------------------
output "kms_key_arn" {
  value       = module.pre_req_primary.kms_key_arn
  description = "The KMS key used to encrypt data."
}

output "kms_key_alias" {
  value       = module.pre_req_primary.kms_key_alias
  description = "The KMS Key Alias"
}

output "kms_key_alias_arn" {
  value       = module.pre_req_primary.kms_key_alias_arn
  description = "The KMS Key Alias arn"
}

#------------------------------------------------------------------------------
# Secrets Manager
#------------------------------------------------------------------------------
output "license_secret_arn" {
  value       = module.pre_req_primary.license_secret_arn
  description = "AWS Secrets Manager tfe_license secret ARN."
}

output "tfe_console_password_arn" {
  value       = module.pre_req_primary.tfe_console_password_arn
  description = "AWS Secrets Manager console_password secret ARN."
}

output "tfe_enc_password_arn" {
  value       = module.pre_req_primary.tfe_enc_password_arn
  description = "AWS Secrets Manager enc_password secret ARN."
}

output "ca_certificate_bundle_secret_arn" {
  value       = module.pre_req_primary.ca_certificate_bundle_secret_arn
  description = "AWS Secrets Manager TFE BYO CA certificate secret ARN."
}

output "cert_pem_secret_arn" {
  value       = module.pre_req_primary.cert_pem_secret_arn
  description = "AWS Secrets Manager TFE BYO CA certificate private key secret ARN."
}

output "cert_pem_private_key_secret_arn" {
  value       = module.pre_req_primary.cert_pem_private_key_secret_arn
  description = "AWS Secrets Manager TFE BYO CA certificate private key secret ARN."
}

output "secret_arn_list" {
  value       = module.pre_req_primary.secret_arn_list
  description = "A list of AWS Secrets Manager Arns produced by the module"
}

#------------------------------------------------------------------------------
# CloudWatch
#------------------------------------------------------------------------------
output "log_group_name" {
  value       = module.pre_req_primary.log_group_name
  description = "AWS CloudWatch Log Group Name."
}

#------------------------------------------------------------------------------
# TFE Key Pair
#------------------------------------------------------------------------------
output "ssh_keypair_name" {
  value       = module.pre_req_primary.ssh_keypair_name
  description = "Name of the keypair that was created (if specified)."
}

output "ssh_keypair_arn" {
  value       = module.pre_req_primary.ssh_keypair_arn
  description = "ARN of the keypair that was created (if specified)."
}

output "ssh_keypair_id" {
  value       = module.pre_req_primary.ssh_keypair_id
  description = "ID of TFE SSH Key Pair."
}

output "ssh_keypair_fingerprint" {
  value       = module.pre_req_primary.ssh_keypair_fingerprint
  description = "Fingerprint of TFE SSH Key Pair."
}

#------------------------------------------------------------------------------
# Databases
#------------------------------------------------------------------------------

output "db_cluster_arn" {
  description = "Amazon Resource Name (ARN) of cluster"
  value       = module.pre_req_primary.db_cluster_arn
}

output "db_cluster_id" {
  description = "The RDS Cluster Identifier"
  value       = module.pre_req_primary.db_cluster_id
}

output "db_cluster_resource_id" {
  description = "The RDS Cluster Resource ID"
  value       = module.pre_req_primary.db_cluster_resource_id
}

output "db_cluster_members" {
  description = "List of RDS Instances that are a part of this cluster"
  value       = module.pre_req_primary.db_cluster_members
}

output "db_cluster_endpoint" {
  description = "Writer endpoint for the cluster"
  value       = module.pre_req_primary.db_cluster_endpoint
}

output "db_cluster_reader_endpoint" {
  description = "A read-only endpoint for the cluster, automatically load-balanced across replicas"
  value       = module.pre_req_primary.db_cluster_reader_endpoint
}

output "db_cluster_engine_version_actual" {
  description = "The running version of the cluster database"
  value       = module.pre_req_primary.db_cluster_engine_version_actual
}

# database_name is not set on `aws_rds_cluster` resource if it was not specified, so can't be used in output
output "db_cluster_database_name" {
  description = "Name for an automatically created database on cluster creation"
  value       = module.pre_req_primary.db_cluster_database_name
}

output "db_cluster_port" {
  description = "The database port"
  value       = module.pre_req_primary.db_cluster_port
}

output "db_password" {
  description = "The database master password"
  value       = module.pre_req_primary.db_password
  sensitive   = true
}

output "db_username" {
  description = "The database master username"
  value       = module.pre_req_primary.db_username
  sensitive   = true
}

output "db_cluster_instances" {
  description = "A map of cluster instances and their attributes"
  value       = module.pre_req_primary.db_cluster_instances
}

output "db_additional_cluster_endpoints" {
  description = "A map of additional cluster endpoints and their attributes"
  value       = module.pre_req_primary.db_additional_cluster_endpoints
}

output "db_cluster_role_associations" {
  description = "A map of IAM roles associated with the cluster and their attributes"
  value       = module.pre_req_primary.db_cluster_role_associations
}

output "db_enhanced_monitoring_iam_role_name" {
  description = "The name of the enhanced monitoring role"
  value       = module.pre_req_primary.db_enhanced_monitoring_iam_role_name
}

output "db_enhanced_monitoring_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the enhanced monitoring role"
  value       = module.pre_req_primary.db_enhanced_monitoring_iam_role_arn
}

output "db_enhanced_monitoring_iam_role_unique_id" {
  description = "Stable and unique string identifying the enhanced monitoring role"
  value       = module.pre_req_primary.db_enhanced_monitoring_iam_role_unique_id
}

output "db_security_group_id" {
  description = "The security group ID of the cluster"
  value       = module.pre_req_primary.db_security_group_id
}

output "db_global_cluster_id" {
  description = "ID of the global cluster that has been created (if specified.)"
  value       = module.pre_req_primary.db_global_cluster_id
}

output "db_cluster_cloudwatch_log_groups" {
  description = "Map of CloudWatch log groups created and their attributes"
  value       = module.pre_req_primary.db_cluster_cloudwatch_log_groups
}

#------------------------------------------------------------------------------
# TFE IAM Resources
#------------------------------------------------------------------------------
output "iam_role_arn" {
  value       = module.pre_req_primary.iam_role_arn
  description = "ARN of IAM Role in use by TFE Instances"
}

output "iam_role_name" {
  value       = module.pre_req_primary.iam_role_name
  description = "Name of IAM Role in use by TFE Instances"
}

output "iam_managed_policy_arn" {
  value       = module.pre_req_primary.iam_managed_policy_arn
  description = "ARN of IAM Managed Policy for TFE Instance Role"
}

output "iam_managed_policy_name" {
  value       = module.pre_req_primary.iam_managed_policy_name
  description = "Name of IAM Managed Policy for TFE Instance Role"
}

output "iam_instance_profile" {
  value       = module.pre_req_primary.iam_instance_profile
  description = "ARN of IAM Instance Profile for TFE Instance Role"
}


#------------------------------------------------------------------------------
# TFE Ingress Resources
#------------------------------------------------------------------------------
output "lb_arn" {
  value       = module.pre_req_primary.lb_arn
  description = "The Resource Identifier of the LB"
}

output "lb_name" {
  value       = module.pre_req_primary.lb_name
  description = "Name of the LB"
}

output "lb_dns_name" {
  value       = module.pre_req_primary.lb_dns_name
  description = "The DNS name created with the LB"
}

output "lb_zone_id" {
  value       = module.pre_req_primary.lb_zone_id
  description = "The Zone ID of the LB"
}

output "lb_internal" {
  value       = module.pre_req_primary.lb_internal
  description = "Boolean value of the internal/external status of the LB.  Determines if the LB gets Elastic IPs assigned"
}

output "lb_security_group_ids" {
  value       = module.pre_req_primary.lb_security_group_ids
  description = "List of security group IDs in use by the LB"
}

output "lb_tg_arns" {
  value       = module.pre_req_primary.lb_tg_arns
  description = "List of target group ARNs for LB"
}

output "lb_type" {
  value       = module.pre_req_primary.lb_type
  description = "Type of LB created (ALB or NLB)"
}

output "acm_certificate_arn" {
  value       = module.pre_req_primary.acm_certificate_arn
  description = "The ARN of the certificate"
}

output "acm_certificate_status" {
  value       = module.pre_req_primary.acm_certificate_status
  description = "Status of the certificate"
}

output "acm_distinct_domain_names" {
  value       = module.pre_req_primary.acm_distinct_domain_names
  description = "List of distinct domains names used for the validation"
}

output "acm_validation_domains" {
  value       = module.pre_req_primary.acm_validation_domains
  description = "List of distinct domain validation options. This is useful if subject alternative names contain wildcards"
}

output "acm_validation_route53_record_fqdns" {
  value       = module.pre_req_primary.acm_validation_route53_record_fqdns
  description = "List of FQDNs built using the zone domain and name"
}

output "route53_regional_record_name" {
  value       = module.pre_req_primary.route53_regional_record_name
  description = "Name of the regional LB Route53 record name"
}

output "route53_regional_fqdn" {
  value       = module.pre_req_primary.route53_regional_fqdn
  description = "FQDN of regional LB Route53 record"
}

output "route53_failover_record_name" {
  value       = module.pre_req_primary.route53_failover_record_name
  description = "Name of the failover LB Route53 record name"
}

output "route53_failover_fqdn" {
  value       = module.pre_req_primary.route53_failover_fqdn
  description = "FQDN of failover LB Route53 record"
}

output "asg_hook_value" {
  value       = module.pre_req_primary.asg_hook_value
  description = "Value for the `asg-hook` tag that will be attatched to the TFE instance in the other module. Use this value to ensure the lifecycle hook is updated during deployment."
}

#------------------------------------------------------------------------------
# Redis
#------------------------------------------------------------------------------

output "redis_security_group_id" {
  description = "ID of redis security group"
  value       = module.pre_req_primary.redis_security_group_id
}

output "redis_primary_endpoint" {
  value       = module.pre_req_primary.redis_primary_endpoint
  description = "Address of the endpoint of the primary node in the replication group."
}

output "redis_replication_group_arn" {
  value       = module.pre_req_primary.redis_replication_group_arn
  description = "ARN of the created Redis replication group."
}

output "redis_password" {
  value       = module.pre_req_primary.redis_password
  description = "Auth token that is used to access the Redis replication group."
  sensitive   = true
}

output "redis_port" {
  value       = module.pre_req_primary.redis_port
  description = "Port that the redis cluster is listening on."
}

output "redis_security_group_ids" {
  value       = module.pre_req_primary.redis_security_group_ids
  description = "List of security groups that are associated with the Redis replication group."
}

output "redis_security_group_name" {
  description = "Name of redis security group"
  value       = module.pre_req_primary.redis_security_group_name
}

output "redis_subnets" {
  description = "List of IDs of redis subnets"
  value       = module.pre_req_primary.redis_subnets
}

output "redis_subnet_arns" {
  description = "List of ARNs of redis subnets"
  value       = module.pre_req_primary.redis_subnet_arns
}

output "redis_subnets_cidr_blocks" {
  description = "List of cidr_blocks of redis subnets"
  value       = module.pre_req_primary.redis_subnets_cidr_blocks
}

output "redis_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of redis subnets in an IPv6 enabled VPC"
  value       = module.pre_req_primary.redis_subnets_ipv6_cidr_blocks
}

output "redis_subnet_group" {
  description = "ID of redis subnet group"
  value       = module.pre_req_primary.redis_subnet_group
}

output "redis_subnet_group_name" {
  description = "Name of redis subnet group"
  value       = module.pre_req_primary.redis_subnet_group_name
}
