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

variable "db_vpc_security_group_ids" {
  type        = list(string)
  description = "List of VPC security groups to associate to the cluster. These will be associated along with the security groups that are created (if specified)."
  default     = []
}

variable "db_cluster_instance_parameter_group_name" {
  description = "Instance parameter group to associate with all instances of the DB cluster. The `db_cluster_db_instance_parameter_group_name` is only valid in combination with `db_allow_major_version_upgrade`"
  type        = string
  default     = null
}

variable "db_ca_cert_identifier" {
  description = "The identifier of the CA certificate for the DB instance"
  type        = string
  default     = null
}

variable "db_allow_major_version_upgrade" {
  description = "Boolean that when true allows major engine version upgrades when changing engine versions."
  type        = bool
  default     = false
}

variable "db_is_primary_cluster" {
  description = "Determines whether cluster is primary cluster with writer instance (set to `false` for global cluster and replica clusters)"
  type        = bool
  default     = true
}

variable "db_publicly_accessible" {
  description = "Determines whether the database is publicly accessible."
  type        = bool
  default     = false
}

variable "db_deletion_protection" {
  type        = bool
  description = "If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to `true`. The default is `false`"
  default     = false
}

variable "db_global_deletion_protection" {
  type        = bool
  description = "If the Global DB instance should have deletion protection enabled. The database can't be deleted when this value is set to `true`. The default is `false`"
  default     = false
}

variable "db_auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window. Default `true`"
  type        = bool
  default     = true
}

variable "create_db_security_group" {
  description = "Boolean that when true will create the security groups for the database cluster to use (if var.create_database is true)"
  type        = bool
  default     = true
}

variable "create_db_global_cluster" {
  description = "Boolean that when true will create a global cluster for Aurora to use for an Active/Standby configuration."
  type        = bool
  default     = false
}

variable "create_db_parameter_group" {
  description = "Boolean that when true will create a database parameter group for the TFE database cluster to use (if var.create_database is true)."
  type        = bool
  default     = true
}

variable "create_db_cluster_parameter_group" {
  description = "Boolean that when true will create a database cluster parameter group for the TFE database cluster to use (if var.create_database is true)."
  type        = bool
  default     = true
}

variable "create_db_subnet_group" {
  type        = bool
  description = "Boolean that when true, will create the database subnet for the database cluster."
  default     = false
}

variable "db_autoscaling_enabled" {
  type        = bool
  description = "Boolean that when true will enable auto scaling of the aurora postgres cluster."
  default     = false
}

variable "db_autoscaling_min_capacity" {
  type        = number
  description = "Minimum number of nodes that has to be present in the autoscaling group when db_autoscaling_enabled is set to true."
  default     = 1
}

variable "db_autoscaling_max_capacity" {
  type        = number
  description = "Maximum number of nodes that has to be present in the autoscaling group when db_autoscaling_enabled is set to true."
  default     = 3
}

variable "db_autoscaling_policy_name" {
  description = "Autoscaling policy name"
  type        = string
  default     = "target-metric"
}

variable "db_autoscaling_predefined_metric_type" {
  description = "The metric type to scale on. Valid values are `RDSReaderAverageCPUUtilization` and `RDSReaderAverageDatabaseConnections`"
  type        = string
  default     = "RDSReaderAverageCPUUtilization"
}

variable "db_autoscaling_scale_in_cooldown" {
  description = "Cooldown in seconds before allowing further scaling operations after a scale in"
  type        = number
  default     = 300
}

variable "db_autoscaling_scale_out_cooldown" {
  description = "Cooldown in seconds before allowing further scaling operations after a scale out"
  type        = number
  default     = 300
}

variable "db_autoscaling_target_cpu" {
  description = "CPU threshold which will initiate autoscaling"
  type        = number
  default     = 70
}

variable "db_autoscaling_target_connections" {
  description = "Average number of connections threshold which will initiate autoscaling. Default value is 70% of db.r4/r5/r6g.large's default max_connections"
  type        = number
  default     = 700
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC that the cluster will use"
  default     = "tfe-vpc"
}

variable "db_instances" {
  type        = number
  description = "Number of instances to deploy."
  default     = "2"
}

variable "db_parameter_group_name" {
  type        = string
  description = "Name of the database parameter group that will be created (if specified) or consumed if create_db_cluster_parameter_group is false."
  default     = "tfe-database-parameter-group"
}

variable "db_parameter_group_family" {
  type        = string
  description = "Family of Aurora PostgreSQL DB Parameter Group."
  default     = "aurora-postgresql14"
}

variable "db_parameter_group_description" {
  type        = string
  description = "Description that will be attatched to the database parameter group if create_db_parameter_group is set to true."
  default     = "Database parameter group for the databases that are used for Terraform Enterprise."
}

variable "db_parameter_group_parameters" {
  type        = list(map(string))
  description = "A list of DB cluster parameters to apply. Note that parameters may differ from a family to an other."
  default     = []
}

variable "db_allowed_cidr_blocks" {
  type        = list(string)
  description = " A list of CIDR blocks which are allowed to access the database"
  default     = []
}

variable "db_subnet_ids" {
  type        = list(string)
  description = "A list of subnets IDs that will be used when creating the subnet group. If this is passed in along with create_db_subnet_group = true and a subnet group isn't then it will be created based on the IDs in this list."
  default     = []
}

variable "db_cluster_parameter_group_name" {
  type        = string
  description = "Name of the database cluster parameter group that will be created (if specified) or consumed if create_db_cluster_parameter_group is false."
  default     = "tfe-database-cluster-parameter-group"
}

variable "db_cluster_parameter_group_family" {
  type        = string
  description = "Family of PostgreSQL DB cluster parameter group."
  default     = "aurora-postgresql14"
}

variable "db_final_snapshot_identifier_prefix" {
  type        = string
  description = "Prefix that will be associated with the final snapshot for the database instance"
  default     = "tfe"
}

variable "db_cluster_parameter_group_parameters" {
  type        = list(map(string))
  description = "A list of DB cluster parameters to apply. Note that parameters may differ from a family to an other."
  default     = []
}

variable "db_cluster_parameter_group_description" {
  type        = string
  description = "Description that will be attatched to the database parameter group if create_db_parameter_group is set to true."
  default     = "Database cluster parameter group for the databases that are used for Terraform Enterprise."
}

variable "db_engine_mode" {
  type        = string
  description = "Database engine mode."
  default     = "provisioned"
}

variable "db_engine_version" {
  type        = number
  description = "Database engine version."
  default     = 14.5
}

variable "db_engine" {
  description = "Database engine type that will be configured. Valid values are `aurora-postgresql` and `postgres`"
  type        = string
  default     = "aurora-postgresql"
  validation {
    condition     = contains(["aurora-postgresql", "postgres"], var.db_engine)
    error_message = "db_engine must be either \"aurora-postgresql\" or \"postgres\"."
  }
}

variable "db_preferred_backup_window" {
  type        = string
  description = "Daily time range (UTC) for RDS backup to occur. Must not overlap with `db_preferred_maintenance_window` if specified."
  default     = "04:00-04:30"
}

variable "db_copy_tags_to_snapshot" {
  type        = bool
  description = "Boolean to enable copying all cluster tags to the snapshot."
  default     = true
}

variable "db_storage_encrypted" {
  description = "Boolean that when set to true will use the kms_key_arn that has been provided via the inputs to this module"
  type        = bool
  default     = true
}

variable "db_kms_key_arn" {
  type        = string
  description = "ARN of KMS key that will be used to encrypt the storage for the database instances."
  default     = ""
}

variable "db_username" {
  type        = string
  description = "Username for the DB user."
  default     = "tfe"
}

variable "db_password" {
  type        = string
  description = "Password for the DB user."
  default     = null
}

variable "db_subnet_group_name" {
  type        = string
  description = "The name of the subnet group name (existing or created)."
  default     = ""
}

variable "db_database_name" {
  type        = string
  description = "Name of database that will be created (if specified) or consumed by TFE."
  default     = "tfe"
}

variable "db_port" {
  description = "The port on which the DB accepts connections. Defaults to the default db port for what you are deploying if null."
  type        = number
  default     = 5432
}

variable "db_apply_immediately" {
  description = "Boolean that when true will apply any changes to the cluster immediately instead of waiting until the next maintenance window."
  type        = bool
  default     = true
}

variable "db_backup_retention_period" {
  type        = number
  description = "The number of days to retain backups for. Must be between 0 and 35. Must be greater than 0 if the database is used as a source for a Read Replica."
  default     = 35
}

variable "db_preferred_maintenance_window" {
  type        = string
  description = "Window (UTC) to perform database maintenance. Must not overlap with `db_preferred_backup_window` if specified."
  default     = "Sun:08:00-Sun:09:00"
}

variable "db_source_region" {
  type        = string
  description = "Source region for Aurora Cross-Region Replication. Only specify for Secondary instance."
  default     = null
}

variable "db_global_cluster_id" {
  type        = string
  description = "Aurora Global Database cluster identifier. Intended to be used by Aurora DB Cluster instance in Secondary region."
  default     = null
}

variable "db_security_group_description" {
  description = "The description of the security group. If value is set to empty string it will contain cluster name in the description"
  type        = string
  default     = null
}

variable "db_instance_class" {
  type        = string
  description = "Instance class that will be applied to all of the autoscaling nodes for the PostgreSQL database if db_enable_autoscaling is set to true."
  default     = "db.r6g.xlarge"
}

variable "db_skip_final_snapshot" {
  description = "Determines whether a final snapshot is created before the cluster is deleted. If true is specified, no snapshot is created"
  type        = bool
  default     = false
}

variable "db_availability_zones" {
  description = "List of EC2 Availability Zones for the DB cluster storage where DB cluster instances can be created. RDS automatically assigns 3 AZs if less than 3 AZs are configured, which will show as a difference requiring resource recreation next Terraform apply"
  type        = list(string)
  default     = null
}

variable "create_db_cloudwatch_log_group" {
  description = "Determines whether a CloudWatch log group is created for each `enabled_cloudwatch_logs_exports`"
  type        = bool
  default     = true
}

variable "db_cloudwatch_retention_days" {
  description = "The number of days to retain CloudWatch logs for the DB instance"
  type        = number
  default     = 7
}

variable "db_cloudwatch_kms_key_arn" {
  description = "The ARN of the KMS Key to use when encrypting log data"
  type        = string
  default     = null
}

variable "db_cloudwatch_log_exports" {
  description = "Set of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: `audit`, `error`, `general`, `slowquery`, `postgresql`"
  type        = list(string)
  default     = ["postgresql"]
}

variable "db_monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for instances. Set to `0` to disable. Default is `0`"
  type        = number
  default     = 0
}

variable "db_performance_insights_enabled" {
  description = "Specifies whether Performance Insights is enabled or not"
  type        = bool
  default     = false
}

variable "db_performance_insights_kms_key_arn" {
  description = "The ARN for the KMS key to encrypt Performance Insights data"
  type        = string
  default     = null
}

variable "db_performance_insights_retention_period" {
  description = "Amount of time in days to retain Performance Insights data. Either 7 (7 days) or 731 (2 years)"
  type        = number
  default     = null
}

variable "db_create_monitoring_role" {
  description = "Determines whether to create the IAM role for RDS enhanced monitoring"
  type        = bool
  default     = true
}

variable "db_monitoring_role_arn" {
  description = "IAM role used by RDS to send enhanced monitoring metrics to CloudWatch"
  type        = string
  default     = ""
}

variable "db_iam_authentication_enabled" {
  description = "Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled"
  type        = bool
  default     = null
}

#------------------------------------------------------------------------------
# RDS Variables (Non Aurora)
#------------------------------------------------------------------------------

variable "db_iops" {
  description = "The amount of Provisioned IOPS (input/output operations per second) to be initially allocated for each DB instance in the Multi-AZ DB cluster"
  type        = number
  default     = 3000
  validation {
    condition = (
      var.db_iops >= 3000 &&
      var.db_iops <= 16000
    )
    error_message = "The IOPS must be at least `3000` GB and lower than `16000` (16TB)."
  }
}

variable "db_storage_type" {
  description = "Specifies the storage type to be associated with the DB cluster. (This setting is required to create a Multi-AZ DB cluster). Valid values: `io1`, Default: `io1`"
  type        = string
  default     = "io1"
}

variable "db_allocated_storage" {
  description = "The amount of storage in gibibytes (GiB) to allocate to each DB instance in the Multi-AZ DB cluster. (This setting is required to create a Multi-AZ DB cluster)"
  type        = number
  default     = 256
}

variable "db_cluster_instance_class" {
  type        = string
  description = "Instance class of the PostgreSQL database."
  default     = "db.r6g.xlarge"
}
