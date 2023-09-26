# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#------------------------------------------------------------------------------
# Common
#------------------------------------------------------------------------------
variable "friendly_name_prefix" {
  type        = string
  description = "Friendly name prefix used for tagging and naming AWS resources."
  validation {
    condition     = length(var.friendly_name_prefix) <= 12
    error_message = "`var.friendly_name_prefix` must be less than or equal to 12 characters"
  }
}

variable "common_tags" {
  type        = map(string)
  description = "Map of common tags for all taggable AWS resources."
  default     = {}
}

variable "product" {
  type        = string
  description = "Name of the HashiCorp product that will consume this service (tfe, tfefdo, vault, consul)"
  validation {
    condition     = contains(["tfe", "tfefdo", "vault", "consul"], var.product)
    error_message = "`var.product` must be \"tfe\", \"tfefdo\", \"vault\", or \"consul\"."
  }
  default = "tfe"
}

#------------------------------------------------------------------------------
# Conditional Variables
#------------------------------------------------------------------------------

variable "create_vpc" {
  description = "Boolean that when true will create a VPC for Terraform Enterprise to use. If this is false then a vpc_id must be provided."
  type        = bool
  default     = true
}

variable "create_secrets" {
  description = "Boolean that when true will create the required secrets and store them in AWS Secrets Manager for the installation. If this is not set to true then the ARNs for the required secrets must be specified"
  type        = bool
  default     = true
}

variable "create_kms" {
  description = "Boolean that when true will create the KMS keys for the S3 buckets to use"
  type        = bool
  default     = true
}

variable "create_s3_buckets" {
  description = "Boolean that when true will create the S3 buckets that TFE will use"
  type        = bool
  default     = true
}

variable "create_redis_replication_group" {
  description = "Boolean that determines if the pre-requisites for an active active deployment of TFE will be deployed."
  type        = bool
  default     = false
}

variable "create_ssh_keypair" {
  type        = bool
  description = "Boolean to deploy TFE SSH key pair. This does not create the private key, it only creates the key pair with a provided public key."
  default     = false
}

variable "create_lb" {
  type        = bool
  description = "Boolean value to indicate to create a LoadBalancer"
  default     = true
}

variable "create_log_group" {
  description = "Boolean that when true will create the cloud watch log group."
  type        = bool
  default     = true
}

variable "create_db_cluster" {
  description = "Boolean that when true will create a cluster for PostgreSQL to use for an Active/Standby configuration."
  type        = bool
  default     = true
}

variable "create_db_global_cluster" {
  description = "Boolean that when true will create a global cluster for Aurora to use for an Active/Standby configuration."
  type        = bool
  default     = false
}

variable "create_db_subnet_group" {
  type        = bool
  description = "Boolean that when true, will create the database subnet for the database cluster."
  default     = false
}

variable "create_db_security_group" {
  description = "Boolean that when true will create the security groups for the database cluster to use (if var.create_database is true)"
  type        = bool
  default     = true
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

variable "create_db_cloudwatch_log_group" {
  description = "Determines whether a CloudWatch log group is created for each `enabled_cloudwatch_logs_exports`"
  type        = bool
  default     = true
}

#------------------------------------------------------------------------------
# KMS
#------------------------------------------------------------------------------

variable "kms_key_description" {
  description = "Description that will be attached to the KMS key (if created)"
  type        = string
  default     = "AWS KMS Customer-managed key to encrypt TFE RDS, S3, EBS, etc."
}

variable "kms_key_usage" {
  description = "Intended use of the KMS key that will be created."
  type        = string
  default     = "ENCRYPT_DECRYPT"
}

variable "kms_key_deletion_window" {
  type        = number
  description = "Duration in days to destroy the key after it is deleted. Must be between 7 and 30 days."
  default     = 7
}

variable "kms_allow_asg_to_cmk" {
  type        = bool
  description = "Boolen to create a KMS CMK Key policy that grants the Service Linked Role AWSServiceRoleForAutoScaling permissions to the CMK."
  default     = true
}

variable "kms_asg_role_arn" {
  type        = string
  description = "ARN of AWS Service Linked role for AWS Autoscaling."
  default     = ""
}

variable "kms_key_name" {
  description = "Name that will be added to the KMS key via tags"
  type        = string
  default     = "kms-key"
}

variable "kms_default_policy_enabled" {
  description = "Enables a default policy that allows KMS operations to be defined by IAM"
  type        = string
  default     = true
}

variable "kms_key_users_or_roles" {
  type        = list(string)
  description = "List of arns for users or roles that should have access to perform Cryptographic Operations with KMS Key"
  default     = []
}

#------------------------------------------------------------------------------
# Network
#------------------------------------------------------------------------------

variable "vpc_name" {
  type        = string
  description = "Friendly name prefix used for tagging and naming AWS resources."
  default     = "tfe-vpc"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC."
  default     = "10.1.0.0/16"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC that the cluster will use. (Only used if var.create_vpc is false)"
  default     = null
}

variable "vpc_enable_ssm" {
  type        = bool
  description = "Boolean that when true will create a security group allowing port 443 to the private_subnets within the VPC (if create_vpc is true)"
  default     = false
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet CIDR ranges to create in VPC."
  default     = ["10.1.255.0/24", "10.1.254.0/24", "10.1.253.0/24"]
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet CIDR ranges to create in VPC."
  default     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
}

variable "database_subnets" {
  type        = list(string)
  description = "List of database subnets CIDR ranges to create in VPC."
  default     = ["10.1.20.0/24", "10.1.21.0/24", "10.1.22.0/24"]
}

variable "vpc_default_security_group_egress" {
  type        = list(map(string))
  description = "List of maps of egress rules to set on the default security group"
  default     = []
}

variable "vpc_default_security_group_ingress" {
  type        = list(map(string))
  description = "List of maps of ingress rules to set on the default security group"
  default     = []
}

variable "vpc_endpoint_flags" {
  type = object({
    create_ec2         = optional(bool, true)
    create_ec2messages = optional(bool, true)
    create_kms         = optional(bool, true)
    create_s3          = optional(bool, true)
    create_ssm         = optional(bool, true)
    create_ssmmessages = optional(bool, true)
  })
  description = "Collection of flags to enable various VPC Endpoints"
  default     = {}
}

variable "vpc_option_flags" {
  type = object({
    create_igw                    = optional(bool, true)
    enable_dns_hostnames          = optional(bool, true)
    enable_dns_support            = optional(bool, true)
    enable_nat_gateway            = optional(bool, true)
    map_public_ip_on_launch       = optional(bool, true)
    manage_default_security_group = optional(bool, true)
    one_nat_gateway_per_az        = optional(bool, false)
    single_nat_gateway            = optional(bool, false)
  })
  description = "Object map of boolean flags to enable or disable certain features of the AWS VPC"
  default     = {}
}

#------------------------------------------------------------------------------
# Database
#------------------------------------------------------------------------------

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
  default     = null
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

variable "db_cloudwatch_retention_days" {
  description = "The number of days to retain CloudWatch logs for the DB instance"
  type        = number
  default     = 7
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

#------------------------------------------------------------------------------
# IAM
#------------------------------------------------------------------------------

variable "create_iam_resources" {
  type        = bool
  description = "Flag to create IAM Resources"
  default     = true
}

variable "iam_resources" {
  type = object({
    bucket_arns             = optional(list(string), [])
    kms_key_arns            = optional(list(string), [])
    secret_manager_arns     = optional(list(string), [])
    log_group_arn           = optional(string, "")
    log_forwarding_enabled  = optional(bool, true)
    role_name               = optional(string, "tfe-role")
    policy_name             = optional(string, "tfe-policy")
    ssm_enable              = optional(bool, false)
    custom_tbw_ecr_repo_arn = optional(string, "")
  })
  description = "A list of objects for to be referenced in an IAM policy for the instance.  Each is a list of strings that reference infra related to the install"
}

variable "create_asg_service_iam_role" {
  type        = bool
  description = "Boolean to create a service linked role for AWS Auto Scaling.  This is required to be created prior to the KMS Key Policy.  This may or may not exist in an AWS Account and needs to be explicilty determined"
  default     = false
}

variable "asg_service_iam_role_custom_suffix" {
  type        = string
  description = "Custom suffix for the AWS Service Linked Role.  AWS IAM only allows unique names.  Leave blank with create_asg_service_iam_role to create the Default Service Linked Role, or add a value to create a secondary role for use with this module"
  default     = ""
}

#------------------------------------------------------------------------------
# LoadBalancing
#------------------------------------------------------------------------------
variable "route53_zone_name" {
  type        = string
  description = "Route 53 public zone name"
  default     = ""
}

variable "route53_record_health_check_enabled" {
  type        = bool
  description = "Enabled evaluation of target health for direct LB record"
  default     = false
}

variable "route53_private_zone" {
  type        = bool
  description = "Boolean that when true, designates the data lookup to use a private Route 53 zone name"
  default     = false
}

variable "route53_failover_record" {
  type = object({
    create              = optional(bool, true)
    set_id              = optional(string, "fso1")
    lb_failover_primary = optional(bool, true)
    record_name         = optional(string)
  })
  default     = {}
  description = "If set, creates a Route53 failover record.  Ensure that the record name is the same between both modules.  Also, the Record ID needs to be unique per module"
}

variable "lb_target_groups" {
  type = object({
    tfe_api = optional(object({
      create               = optional(bool, true)
      description          = optional(string, "Target Group for TLS API/Web application traffic")
      name                 = optional(string, "tfe-tls-tg")
      deregistration_delay = optional(number, 60)
      port                 = optional(number, 443)
      protocol             = optional(string, "HTTPS")
      health_check = optional(object({
        enabled             = optional(bool, true)
        port                = optional(number, 443)
        healthy_threshold   = optional(number, 2)
        unhealthy_threshold = optional(number, 3)
        timeout             = optional(number, 5)
        interval            = optional(number, 15)
        matcher             = optional(string, "200")
        path                = optional(string, "/_health_check")
        protocol            = optional(string, "HTTPS")
      }), {})
    }), {})
    tfe_console = optional(object({
      create               = optional(bool, true)
      name                 = optional(string, "tfe-console-tg")
      description          = optional(string, "Target Group for TFE/Replicated web admin console traffic")
      deregistration_delay = optional(number, 60)
      port                 = optional(number, 8800)
      protocol             = optional(string, "HTTPS")
      health_check = optional(object({
        enabled             = optional(bool, true)
        port                = optional(number, 8800)
        healthy_threshold   = optional(number, 2)
        unhealthy_threshold = optional(number, 3)
        timeout             = optional(number, 5)
        interval            = optional(number, 15)
        matcher             = optional(string, "200-299")
        path                = optional(string, "/ping")
        protocol            = optional(string, "HTTPS")
      }), {})
    }), {})
  })
  default     = {}
  description = "Object map that creates the LB target groups for the enterprise products"
}

variable "lb_sg_rules_details" {
  type = object({
    tfe_api_ingress = optional(object({
      type        = optional(string, "ingress")
      create      = optional(bool, true)
      from_port   = optional(string, "443")
      to_port     = optional(string, "443")
      protocol    = optional(string, "tcp")
      cidr_blocks = optional(list(string), [])
      description = optional(string, "Allow 443 traffic inbound for TFE")
    }), {})
    tfe_console_ingress = optional(object({
      type        = optional(string, "ingress")
      create      = optional(bool, true)
      from_port   = optional(string, "8800")
      to_port     = optional(string, "8800")
      protocol    = optional(string, "tcp")
      cidr_blocks = optional(list(string), [])
      description = optional(string, "Allow 8800 traffic inbound for TFE")
    }), {})
    egress = optional(object({
      create      = optional(bool, true)
      type        = optional(string, "egress")
      from_port   = optional(string, "0")
      to_port     = optional(string, "0")
      protocol    = optional(string, "-1")
      cidr_blocks = optional(list(string), ["0.0.0.0/0"])
      description = optional(string, "Allow traffic outbound for TFE")
    }), {})
  })
  description = "Object map for various Security Group Rules as pertains to the Load Balancer for TFE"
  default     = {}
}

variable "create_lb_certificate" {
  type        = bool
  default     = true
  description = "Boolean that when true will create the SSL certificate for the ALB to use."
}

variable "create_lb_security_groups" {
  type        = bool
  default     = true
  description = "Boolean that when true will create the required security groups for the load balancers to use."
}

variable "lb_name" {
  type        = string
  default     = "lb"
  description = "Name of the Load Balancer to be deployed"
}

variable "lb_security_group_ids" {
  type        = list(string)
  default     = []
  description = "Optional list of security group IDs to be used if providing security groups created outside of this module"
}

variable "lb_internal" {
  type        = bool
  default     = false
  description = "Boolean to determine if the Load Balancer will be internal or internet facing"
}

variable "lb_subnet_ids" {
  type        = list(string)
  default     = []
  description = "List of Subnet IDs to deploy Load Balancer into"
}

variable "lb_type" {
  type        = string
  default     = "application"
  description = "Type of load balancer that will be provisioned as a part of the module execution (if specified)."
}

variable "lb_certificate_arn" {
  type        = string
  default     = null
  description = "Bring your own certificate ARN"
}

variable "lb_listener_details" {
  type = object({
    tfe_api = optional(object({
      create      = optional(bool, true)
      port        = optional(number, 443)
      ssl_policy  = optional(string, "ELBSecurityPolicy-2016-08")
      action_type = optional(string, "forward")
    }), {})
    tfe_console = optional(object({
      create      = optional(bool, true)
      port        = optional(number, 8800)
      ssl_policy  = optional(string, "ELBSecurityPolicy-2016-08")
      action_type = optional(string, "forward")
    }), {})
  })
  description = "Configures the LB Listeners for TFE"
  default     = {}
}

#------------------------------------------------------------------------------
# S3
#------------------------------------------------------------------------------

variable "s3_buckets" {
  type = object({
    bootstrap = optional(object({
      create                              = optional(bool, true)
      bucket_name                         = optional(string, "tfe-bootstrap-bucket")
      description                         = optional(string, "Bootstrap bucket for the TFE instances and install")
      versioning                          = optional(bool, true)
      force_destroy                       = optional(bool, false)
      replication                         = optional(bool)
      replication_destination_bucket_arn  = optional(string)
      replication_destination_kms_key_arn = optional(string)
      replication_destination_region      = optional(string)
      encrypt                             = optional(bool, true)
      bucket_key_enabled                  = optional(bool, true)
      kms_key_arn                         = optional(string)
      sse_s3_managed_key                  = optional(bool, false)
      is_secondary_region                 = optional(bool, false)
    }), {})
    tfe_app = optional(object({
      create                              = optional(bool, true)
      bucket_name                         = optional(string, "tfe-app-bucket")
      description                         = optional(string, "Object store for TFE")
      versioning                          = optional(bool, true)
      force_destroy                       = optional(bool, false)
      replication                         = optional(bool)
      replication_destination_bucket_arn  = optional(string)
      replication_destination_kms_key_arn = optional(string)
      replication_destination_region      = optional(string)
      encrypt                             = optional(bool, true)
      bucket_key_enabled                  = optional(bool, true)
      kms_key_arn                         = optional(string)
      sse_s3_managed_key                  = optional(bool, false)
      is_secondary_region                 = optional(bool, false)
    }), {})
    logging = optional(object({
      create                              = optional(bool, true)
      bucket_name                         = optional(string, "hashicorp-log-bucket")
      versioning                          = optional(bool, false)
      force_destroy                       = optional(bool, false)
      replication                         = optional(bool, false)
      replication_destination_bucket_arn  = optional(string)
      replication_destination_kms_key_arn = optional(string)
      replication_destination_region      = optional(string)
      encrypt                             = optional(bool, true)
      bucket_key_enabled                  = optional(bool, true)
      kms_key_arn                         = optional(string)
      sse_s3_managed_key                  = optional(bool, false)
      lifecycle_enabled                   = optional(bool, true)
      lifecycle_expiration_days           = optional(number, 7)
      is_secondary_region                 = optional(bool, false)
    }), {})
  })
  description = "Object Map that contains the configuration for the S3 logging and bootstrap bucket configuration."
  default     = {}
}

#------------------------------------------------------------------------------
# Secrets Manager
#------------------------------------------------------------------------------
variable "secretsmanager_secrets" {
  type = object({
    license = optional(object({
      name        = optional(string, "tfe-license")
      path        = optional(string, null)
      description = optional(string, "TFE license")
      data        = optional(string, null)
    }), {})
    tfe_console_password = optional(object({
      name        = optional(string, "console-password")
      description = optional(string, "Console password used in the TFE installation")
      data        = optional(string, null)
    }), {})
    tfe_enc_password = optional(object({
      name        = optional(string, "enc-password")
      description = optional(string, "Encryption password used in the TFE installation")
      data        = optional(string, null)
    }), {})
    ca_certificate_bundle = optional(object({
      name        = optional(string, null)
      path        = optional(string, null)
      description = optional(string, "TFE BYO CA certificate bundle")
      data        = optional(string, null)
    }))
    cert_pem_secret = optional(object({
      name        = optional(string, null)
      path        = optional(string, null)
      description = optional(string, "TFE BYO PEM-encoded TLS certificate")
      data        = optional(string, null)
    }))
    cert_pem_private_key_secret = optional(object({
      name        = optional(string, null)
      path        = optional(string, null)
      description = optional(string, "TFE BYO PEM-encoded TLS private key")
      data        = optional(string, null)
    }))
  })
  description = "Object Map that contains various TFE secrets that will be created and stored in AWS Secrets Manager."
  default     = {}
}

variable "optional_secrets" {
  type        = map(any)
  default     = {}
  description = <<DESC
  Optional variable that when supplied will be merged with the `secretsmanager_secrets` map. These secrets need to have the following specification:
  optional_secrets = {
    secret_1 = {
      name = "supesecret"
      description = "it's my secret that is important"
      path = "path to file if you are using one"
      data = "string data if you are supplying it"
    }
    secret_2 = {
      name = "supesecret2"
      description = "it's my secret that is also important probably"
      path = "path to file if you are using one"
      data = "string data if you are supplying it"
    }
  }
  DESC
}

variable "log_group_name" {
  type        = string
  description = "Name of the Cloud Watch Log Group to be used for TFE Logs."
  default     = "tfe-log-group"
}

variable "log_group_retention_days" {
  type        = number
  description = "Number of days to retain logs in Log Group."
  default     = 30

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 180, 365, 400, 545, 731, 1827, 3653], var.log_group_retention_days)
    error_message = "Supported values are `1`, `3`, `5`, `7`, `14`, `30`, `60`, `90`, `120`, `150`, `180`, `365`, `400`, `545`, `731`, `1827`, `3653`."
  }
}

variable "cloudwatch_kms_key_arn" {
  type        = string
  description = "KMS key that cloudwatch will use. If not specified, the kms key that is created will be used."
  default     = null
}


#------------------------------------------------------------------------------
# TFE Key Pair
#------------------------------------------------------------------------------

variable "ssh_public_key" {
  type        = string
  description = "Public key material for TFE SSH Key Pair."
  default     = null
}

variable "ssh_keypair_name" {
  type        = string
  description = "Name of the TFE keypair that will be created or used (if it already exists)."
  default     = "tfe-keypair"
}

#------------------------------------------------------------------------------
# Redis
#------------------------------------------------------------------------------

variable "tfe_active_active" {
  description = "Boolean that determines if the pre-requisites for an active active deployment of TFE will be deployed."
  type        = bool
  default     = false
}

variable "redis_engine" {
  type        = string
  default     = "redis"
  description = "Engine that will be provisioned for the Redis replication group"
}

variable "redis_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to use for Redis replication group subnet group."
  default     = []
}

variable "redis_subnet_group_name" {
  type        = string
  description = "Name of the existing subnet group for the Redis replication group to use."
  default     = null
}

variable "redis_engine_version" {
  type        = string
  description = "Redis version number."
  default     = "6.2"
}

variable "redis_port" {
  type        = number
  description = "Port number the Redis nodes will accept connections on."
  default     = 6379
}

variable "redis_parameter_group_name" {
  type        = string
  description = "Name of parameter group to associate with Redis replication group."
  default     = "default.redis6.x"
}

variable "redis_node_type" {
  type        = string
  description = "Type of Redis node from a compute, memory, and network throughput standpoint."
  default     = "cache.m5.large"
}

variable "redis_security_group_ids" {
  type        = list(string)
  description = "List of existing security groups to associate with the Redis replication group. If Active/Active is true and this is default, then one will be created."
  default     = []
}

variable "redis_enable_multi_az" {
  type        = bool
  description = "Boolean for deploying Redis nodes in multiple Availability Zones and enabling automatic failover."
  default     = true
}

variable "redis_enable_encryption_at_rest" {
  type        = bool
  description = "Boolean to enable encryption at rest on Redis replication group. A `kms_key_arn` is required when set to `true`."
  default     = false
}

variable "redis_password" {
  type        = string
  description = "Password (auth token) used to enable transit encryption (TLS) with Redis."
  default     = ""
}

variable "redis_kms_key_arn" {
  type        = string
  description = "ARN of KMS key that will be used to encrypt the storage for the Redis instances."
  default     = ""
}


variable "redis_replication_group_description" {
  type        = string
  default     = "External Redis Replication Group for TFE Active/Active"
  description = "Description that will be associated with the Redis replication group "
}

variable "redis_log_group_name" {
  type        = string
  description = "Name of the Cloud Watch Log Group to be used for Redis Logs."
  default     = ""
}

variable "redis_enable_transit_encryption" {
  type        = bool
  description = "Boolean to enable transit encryption at rest on Redis replication group."
  default     = true
}
