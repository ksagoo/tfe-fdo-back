locals {
  merged_kms = {
    for k, v in var.s3_buckets :
    k => merge(v, {
      kms_key_arn = v.sse_s3_managed_key ? "" : try(module.kms[0].kms_key_alias_arn, v.kms_key_arn)
    })
  }
  # Friendly name prefix with a random hex ID to ensure uniqueness
  friendly_name_prefix_rid = "${var.friendly_name_prefix}-${random_id.pre_req_rid.hex}"

  #  Local that allows for the following scenarios (in order):
  #  * Use the BYO `db_subnet_ids` if `var.vpc_id` isn't null
  #  * Use of the collapsed subnets for redis and postgres (database subnet).
  #  * Use an even more collapsed design (2 subnets private and public) the private subnet will be used by the clusters.
  db_subnet_ids = var.vpc_id != null && length(var.db_subnet_ids) == 0 ? var.db_subnet_ids : try(module.networking[0].database_subnet_ids, null)
}

resource "random_id" "pre_req_rid" {
  byte_length = 3
}

data "aws_region" "current" {}

module "networking" {
  source = "./modules/networking"
  count  = var.create_vpc ? 1 : 0

  vpc_cidr                           = var.vpc_cidr
  vpc_name                           = var.vpc_name
  public_subnets                     = var.public_subnets
  private_subnets                    = var.private_subnets
  database_subnets                   = var.database_subnets
  friendly_name_prefix               = local.friendly_name_prefix_rid
  common_tags                        = var.common_tags
  vpc_enable_ssm                     = var.vpc_enable_ssm
  vpc_default_security_group_egress  = var.vpc_default_security_group_egress
  vpc_default_security_group_ingress = var.vpc_default_security_group_ingress
  vpc_option_flags                   = var.vpc_option_flags
  vpc_endpoint_flags                 = var.vpc_endpoint_flags
  product                            = var.product
}

module "ingress" {
  source = "./modules/ingress"
  count  = var.create_lb ? 1 : 0

  vpc_id                              = var.create_vpc ? try(module.networking[0].vpc_id, null) : var.vpc_id
  lb_subnet_ids                       = length(var.lb_subnet_ids) != 0 ? var.lb_subnet_ids : (var.create_vpc && !var.lb_internal ? try(module.networking[0].public_subnet_ids, null) : (var.create_vpc && var.lb_internal ? try(module.networking[0].private_subnet_ids, null) : null))
  lb_name                             = var.lb_name
  lb_internal                         = var.lb_internal
  lb_security_group_ids               = var.lb_security_group_ids
  lb_certificate_arn                  = var.lb_certificate_arn
  lb_type                             = var.lb_type
  create_lb_certificate               = var.create_lb_certificate
  create_lb_security_groups           = var.create_lb_security_groups
  lb_sg_rules_details                 = var.lb_sg_rules_details
  lb_listener_details                 = var.lb_listener_details
  lb_target_groups                    = var.lb_target_groups
  route53_zone_name                   = var.route53_zone_name
  route53_failover_record             = var.route53_failover_record
  route53_record_health_check_enabled = var.route53_record_health_check_enabled
  route53_private_zone                = var.route53_private_zone
  common_tags                         = var.common_tags
  friendly_name_prefix                = local.friendly_name_prefix_rid
}

module "kms" {
  source = "./modules/kms"
  count  = var.create_kms ? 1 : 0

  kms_default_policy_enabled = var.kms_default_policy_enabled
  kms_key_usage              = var.kms_key_usage
  kms_key_deletion_window    = var.kms_key_deletion_window
  kms_key_name               = var.kms_key_name
  kms_key_description        = var.kms_key_description
  kms_key_users_or_roles     = var.kms_key_users_or_roles
  kms_allow_asg_to_cmk       = var.kms_allow_asg_to_cmk
  kms_asg_role_arn           = var.create_iam_resources ? try(module.iam[0].asg_role_arn, null) : var.kms_asg_role_arn
  friendly_name_prefix       = local.friendly_name_prefix_rid
  common_tags                = var.common_tags
  product                    = var.product
}

module "s3" {
  source               = "./modules/s3"
  count                = var.create_s3_buckets ? 1 : 0
  s3_buckets           = local.merged_kms
  friendly_name_prefix = local.friendly_name_prefix_rid
}

module "secrets_manager" {
  source                 = "./modules/secrets_manager"
  count                  = var.create_secrets ? 1 : 0
  secretsmanager_secrets = var.secretsmanager_secrets
  optional_secrets       = var.optional_secrets
  friendly_name_prefix   = local.friendly_name_prefix_rid
  common_tags            = var.common_tags
  product                = var.product
}

module "iam" {
  source               = "./modules/iam"
  count                = var.create_iam_resources ? 1 : 0
  friendly_name_prefix = local.friendly_name_prefix_rid
  iam_resources = {
    bucket_arns            = var.create_s3_buckets ? try(module.s3[0].s3_bucket_arn_list, null) : var.iam_resources.bucket_arns
    kms_key_arns           = var.create_kms ? try(concat([module.kms[0].kms_key_alias_arn], [module.kms[0].kms_key_arn]), null) : var.iam_resources.kms_key_arns
    secret_manager_arns    = var.create_secrets ? try(module.secrets_manager[0].secret_arn_list, null) : var.iam_resources.secrets_manager_arns
    log_group_arn          = var.create_log_group ? try(aws_cloudwatch_log_group.tfe[0].arn, null) : var.iam_resources.log_group_arn
    log_forwarding_enabled = var.iam_resources.log_forwarding_enabled
    ssm_enable             = var.iam_resources.ssm_enable ? var.iam_resources.ssm_enable : (var.vpc_enable_ssm ? true : false)
    role_name              = var.iam_resources.role_name
    policy_name            = var.iam_resources.policy_name
  }
  create_asg_service_iam_role        = var.create_asg_service_iam_role
  asg_service_iam_role_custom_suffix = var.asg_service_iam_role_custom_suffix
  product                            = var.product
}

module "database" {
  source                   = "./modules/database"
  count                    = var.create_db_cluster ? 1 : 0
  friendly_name_prefix     = local.friendly_name_prefix_rid
  create_db_global_cluster = var.create_db_global_cluster
  db_global_cluster_id     = var.db_global_cluster_id
  db_kms_key_arn           = var.db_kms_key_arn != null ? var.db_kms_key_arn : (var.create_kms ? try(module.kms[0].kms_key_arn, null) : null)
  db_availability_zones    = var.db_availability_zones
  db_instance_class        = var.db_instance_class

  #------------------------------------------------------------------------------
  # Storage
  #------------------------------------------------------------------------------
  db_iops              = var.db_iops
  db_storage_type      = var.db_storage_type
  db_allocated_storage = var.db_allocated_storage

  #------------------------------------------------------------------------------
  # Networking
  #------------------------------------------------------------------------------
  create_db_subnet_group        = var.create_vpc && length(var.database_subnets) == 0 ? true : var.create_db_subnet_group
  create_db_security_group      = var.create_db_security_group
  db_subnet_ids                 = local.db_subnet_ids # see locals block at the top
  vpc_id                        = var.create_vpc ? try(module.networking[0].vpc_id, null) : var.vpc_id
  db_subnet_group_name          = var.create_vpc && length(var.database_subnets) > 0 ? try(module.networking[0].database_subnet_group_name, null) : var.db_subnet_group_name
  db_allowed_cidr_blocks        = var.create_vpc ? try(module.networking[0].private_subnets_cidr_blocks, null) : var.db_allowed_cidr_blocks
  db_port                       = var.db_port
  db_security_group_description = var.db_security_group_description
  db_publicly_accessible        = var.db_publicly_accessible
  db_vpc_security_group_ids     = var.db_vpc_security_group_ids

  #------------------------------------------------------------------------------
  # Database Configuration
  #------------------------------------------------------------------------------
  db_apply_immediately                     = var.db_apply_immediately
  db_username                              = var.db_username
  db_password                              = var.db_password
  db_database_name                         = var.db_database_name
  db_engine                                = var.db_engine
  db_engine_version                        = var.db_engine_version
  db_engine_mode                           = var.db_engine_mode
  create_db_parameter_group                = var.create_db_parameter_group
  db_parameter_group_name                  = var.db_parameter_group_name
  db_parameter_group_family                = var.db_parameter_group_family
  db_parameter_group_description           = var.db_parameter_group_description
  db_parameter_group_parameters            = var.db_parameter_group_parameters
  db_cluster_instance_parameter_group_name = var.db_cluster_instance_parameter_group_name
  db_iam_authentication_enabled            = var.db_iam_authentication_enabled

  #------------------------------------------------------------------------------
  # Backups / Maintenance
  #------------------------------------------------------------------------------
  db_backup_retention_period          = var.db_backup_retention_period
  db_preferred_backup_window          = var.db_preferred_backup_window
  db_preferred_maintenance_window     = var.db_preferred_maintenance_window
  db_copy_tags_to_snapshot            = var.db_copy_tags_to_snapshot
  db_skip_final_snapshot              = var.db_skip_final_snapshot
  db_final_snapshot_identifier_prefix = var.db_final_snapshot_identifier_prefix

  #------------------------------------------------------------------------------
  # Cluster Configuration
  #------------------------------------------------------------------------------
  db_storage_encrypted                   = var.db_storage_encrypted
  db_is_primary_cluster                  = var.db_is_primary_cluster
  db_cluster_instance_class              = var.db_cluster_instance_class
  db_source_region                       = var.db_source_region
  create_db_cluster_parameter_group      = var.create_db_cluster_parameter_group
  db_cluster_parameter_group_name        = var.db_cluster_parameter_group_name
  db_cluster_parameter_group_family      = var.db_cluster_parameter_group_family
  db_cluster_parameter_group_description = var.db_cluster_parameter_group_description
  db_cluster_parameter_group_parameters  = var.db_cluster_parameter_group_parameters
  db_auto_minor_version_upgrade          = var.db_auto_minor_version_upgrade
  db_instances                           = var.db_instances
  db_allow_major_version_upgrade         = var.db_allow_major_version_upgrade
  db_ca_cert_identifier                  = var.db_ca_cert_identifier
  db_global_deletion_protection          = var.db_global_deletion_protection
  db_deletion_protection                 = var.db_deletion_protection

  #------------------------------------------------------------------------------
  # Scaling Configuration
  #------------------------------------------------------------------------------
  db_autoscaling_enabled                = var.db_autoscaling_enabled
  db_autoscaling_min_capacity           = var.db_autoscaling_min_capacity
  db_autoscaling_max_capacity           = var.db_autoscaling_max_capacity
  db_autoscaling_policy_name            = var.db_autoscaling_policy_name
  db_autoscaling_target_cpu             = var.db_autoscaling_target_cpu
  db_autoscaling_scale_in_cooldown      = var.db_autoscaling_scale_in_cooldown
  db_autoscaling_scale_out_cooldown     = var.db_autoscaling_scale_out_cooldown
  db_autoscaling_predefined_metric_type = var.db_autoscaling_predefined_metric_type
  db_autoscaling_target_connections     = var.db_autoscaling_target_connections


  #------------------------------------------------------------------------------
  # Monitoring
  #------------------------------------------------------------------------------
  db_monitoring_interval                   = var.db_monitoring_interval
  db_performance_insights_enabled          = var.db_performance_insights_enabled
  db_performance_insights_kms_key_arn      = var.db_performance_insights_kms_key_arn
  db_performance_insights_retention_period = var.db_performance_insights_retention_period
  create_db_cloudwatch_log_group           = var.create_db_cloudwatch_log_group
  db_cloudwatch_log_exports                = var.db_cloudwatch_log_exports
  db_create_monitoring_role                = var.db_create_monitoring_role
  db_monitoring_role_arn                   = var.db_monitoring_role_arn
  db_cloudwatch_retention_days             = var.db_cloudwatch_retention_days
  db_cloudwatch_kms_key_arn                = var.cloudwatch_kms_key_arn != null ? var.cloudwatch_kms_key_arn : try(module.kms[0].kms_key_alias_arn, null)
  common_tags                              = var.common_tags
}

module "redis" {
  source                              = "./modules/redis"
  count                               = var.tfe_active_active && var.create_redis_replication_group ? 1 : 0
  common_tags                         = var.common_tags
  product                             = var.product
  vpc_id                              = var.create_vpc ? try(module.networking[0].vpc_id, null) : var.vpc_id
  friendly_name_prefix                = local.friendly_name_prefix_rid
  redis_engine                        = var.redis_engine
  redis_engine_version                = var.redis_engine_version
  redis_port                          = var.redis_port
  redis_node_type                     = var.redis_node_type
  redis_subnet_ids                    = var.vpc_id != null ? var.redis_subnet_ids : local.db_subnet_ids
  redis_subnet_group_name             = var.redis_subnet_group_name
  redis_security_group_ids            = var.redis_security_group_ids != null ? var.redis_security_group_ids : null
  redis_kms_key_arn                   = var.redis_kms_key_arn != null ? var.redis_kms_key_arn : (var.create_kms ? try(module.kms[0].kms_key_alias_arn, null) : null)
  redis_parameter_group_name          = var.redis_parameter_group_name
  redis_enable_encryption_at_rest     = var.redis_enable_encryption_at_rest
  redis_enable_multi_az               = var.redis_enable_multi_az
  redis_password                      = var.redis_password
  redis_replication_group_description = var.redis_replication_group_description
  redis_enable_transit_encryption     = var.redis_enable_transit_encryption
  redis_log_group_name                = var.redis_log_group_name != "" ? var.redis_log_group_name : (var.create_log_group ? try(aws_cloudwatch_log_group.tfe[0].name, null) : null)
}

resource "aws_cloudwatch_log_group" "tfe" {
  count             = var.create_log_group ? 1 : 0
  name              = "${local.friendly_name_prefix_rid}-${var.log_group_name}"
  retention_in_days = var.log_group_retention_days
  kms_key_id        = var.cloudwatch_kms_key_arn != null ? var.cloudwatch_kms_key_arn : try(module.kms[0].kms_key_alias_arn, null)

  tags = merge({ "Name" = "${local.friendly_name_prefix_rid}-${var.log_group_name}" }, var.common_tags)
}

resource "aws_key_pair" "ssh" {
  count = var.create_ssh_keypair ? 1 : 0

  key_name   = "${local.friendly_name_prefix_rid}-${var.ssh_keypair_name}"
  public_key = var.ssh_public_key

  tags = merge(
    { Name = "${local.friendly_name_prefix_rid}-${var.ssh_keypair_name}" },
    var.common_tags
  )
}