# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  traditional_rds = var.db_engine != "aurora-postgresql" ? true : false
}

resource "aws_rds_global_cluster" "global" {
  count                     = var.create_db_global_cluster && var.db_engine == "aurora-postgresql" ? 1 : 0
  global_cluster_identifier = "${var.friendly_name_prefix}-${var.db_global_cluster_id}"
  engine                    = var.db_engine
  engine_version            = var.db_engine_version
  database_name             = var.db_database_name
  storage_encrypted         = var.db_storage_encrypted
  deletion_protection       = var.db_global_deletion_protection
}

module "rds" {
  source = "./modules/rds"

  name = var.friendly_name_prefix

  global_cluster_identifier = var.create_db_global_cluster ? aws_rds_global_cluster.global[0].global_cluster_identifier : var.db_global_cluster_id
  instance_class            = var.db_instance_class
  instances                 = local.traditional_rds && var.db_availability_zones != null ? {} : { for i in range(var.db_instances) : i => {} }
  kms_key_id                = var.db_kms_key_arn

  availability_zones = var.db_availability_zones

  #------------------------------------------------------------------------------
  # Storage
  #------------------------------------------------------------------------------
  iops              = local.traditional_rds ? var.db_iops : null
  storage_type      = local.traditional_rds ? var.db_storage_type : null
  allocated_storage = local.traditional_rds ? var.db_allocated_storage : null

  #------------------------------------------------------------------------------
  # Networking
  #------------------------------------------------------------------------------
  create_db_subnet_group      = var.create_db_subnet_group
  create_security_group       = var.create_db_security_group
  subnets                     = var.create_db_subnet_group ? var.db_subnet_ids : []
  vpc_id                      = var.vpc_id
  db_subnet_group_name        = var.db_subnet_group_name
  vpc_security_group_ids      = var.db_vpc_security_group_ids
  manage_master_user_password = false
  security_group_rules = var.create_db_security_group ? {
    vpc_ingress = {
      cidr_blocks = var.db_allowed_cidr_blocks
    }
  } : null
  port                       = var.db_port
  security_group_description = var.db_security_group_description
  publicly_accessible        = var.db_publicly_accessible

  #------------------------------------------------------------------------------
  # Database Configuration
  #------------------------------------------------------------------------------
  apply_immediately              = var.db_apply_immediately
  master_username                = var.db_username
  master_password                = var.db_password
  database_name                  = var.create_db_global_cluster ? aws_rds_global_cluster.global[0].database_name : (var.db_is_primary_cluster ? var.db_database_name : null)
  engine                         = var.create_db_global_cluster ? aws_rds_global_cluster.global[0].engine : var.db_engine
  engine_version                 = var.create_db_global_cluster ? aws_rds_global_cluster.global[0].engine_version : var.db_engine_version
  engine_mode                    = var.db_engine_mode
  db_parameter_group_description = var.db_parameter_group_description
  db_parameter_group_parameters  = var.db_parameter_group_parameters
  db_parameter_group_family      = var.db_parameter_group_family
  db_parameter_group_name        = var.db_parameter_group_name
  deletion_protection            = var.db_deletion_protection

  #------------------------------------------------------------------------------
  # Backups / Maintenance
  #------------------------------------------------------------------------------
  backup_retention_period      = var.db_backup_retention_period
  preferred_backup_window      = var.db_preferred_backup_window
  preferred_maintenance_window = var.db_preferred_maintenance_window
  copy_tags_to_snapshot        = var.db_copy_tags_to_snapshot
  skip_final_snapshot          = var.db_skip_final_snapshot
  final_snapshot_identifier    = "${var.friendly_name_prefix}-${var.db_final_snapshot_identifier_prefix}"

  #------------------------------------------------------------------------------
  # Cluster Configuration
  #------------------------------------------------------------------------------
  storage_encrypted                           = var.db_storage_encrypted
  is_primary_cluster                          = var.db_is_primary_cluster
  db_cluster_instance_class                   = local.traditional_rds ? var.db_cluster_instance_class : null
  source_region                               = !var.db_is_primary_cluster ? var.db_source_region : null
  create_db_cluster_parameter_group           = var.create_db_cluster_parameter_group
  db_cluster_parameter_group_name             = var.db_cluster_parameter_group_name
  db_cluster_parameter_group_family           = var.db_cluster_parameter_group_family
  db_cluster_parameter_group_description      = var.db_cluster_parameter_group_description
  db_cluster_parameter_group_parameters       = var.db_cluster_parameter_group_parameters
  auto_minor_version_upgrade                  = var.db_auto_minor_version_upgrade
  allow_major_version_upgrade                 = var.db_allow_major_version_upgrade
  ca_cert_identifier                          = var.db_ca_cert_identifier
  create_db_parameter_group                   = var.create_db_parameter_group
  iam_database_authentication_enabled         = var.db_iam_authentication_enabled
  db_cluster_db_instance_parameter_group_name = var.db_cluster_instance_parameter_group_name

  #------------------------------------------------------------------------------
  # Scaling Configuration
  #------------------------------------------------------------------------------
  autoscaling_enabled            = var.db_autoscaling_enabled
  autoscaling_min_capacity       = var.db_autoscaling_min_capacity
  autoscaling_max_capacity       = var.db_autoscaling_max_capacity
  autoscaling_policy_name        = var.db_autoscaling_policy_name
  autoscaling_target_cpu         = var.db_autoscaling_target_cpu
  autoscaling_scale_in_cooldown  = var.db_autoscaling_scale_in_cooldown
  autoscaling_scale_out_cooldown = var.db_autoscaling_scale_out_cooldown
  predefined_metric_type         = var.db_autoscaling_predefined_metric_type
  autoscaling_target_connections = var.db_autoscaling_target_connections

  #------------------------------------------------------------------------------
  # Monitoring Configuration
  #------------------------------------------------------------------------------
  monitoring_interval                    = var.db_monitoring_interval
  performance_insights_enabled           = var.db_performance_insights_enabled
  performance_insights_kms_key_id        = var.db_performance_insights_kms_key_arn
  performance_insights_retention_period  = var.db_performance_insights_retention_period
  create_cloudwatch_log_group            = var.create_db_cloudwatch_log_group
  enabled_cloudwatch_logs_exports        = var.db_cloudwatch_log_exports
  create_monitoring_role                 = var.db_create_monitoring_role
  monitoring_role_arn                    = var.db_monitoring_role_arn
  cloudwatch_log_group_retention_in_days = var.db_cloudwatch_retention_days
  cloudwatch_log_group_kms_key_id        = var.db_cloudwatch_kms_key_arn


  tags = var.common_tags
}

# Required if you are creating a global cluster and doing both site pre-reqs within 1 run. There is a race condition where the global cluster will not be available when the secondary RDS cluster tries to join it.
resource "time_sleep" "cluster" {
  count = var.db_is_primary_cluster && var.create_db_global_cluster ? 1 : 0
  depends_on = [
    module.rds
  ]
  create_duration = "60s"
  triggers = {
    global_cluster_id = var.db_is_primary_cluster ? aws_rds_global_cluster.global[0].global_cluster_identifier : null
  }
}

resource "terraform_data" "cluster" {
  count = var.db_is_primary_cluster && var.create_db_global_cluster ? 1 : 0

  depends_on = [
    module.rds
  ]

  input = aws_rds_global_cluster.global[0].global_cluster_identifier
}