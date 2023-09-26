# Database Module  

## Overview  
This module deploys an Aurora Cluster as a database store for the HashiCorp Terraform Enterprise deployment.  Currently, it is limited to a PostgreSQL engine type.  The module controls deployment of the DB cluster and its components.  In addition, it will allow the deployment of a global DB Aurora cluster to support multi-region deployments.  Lastly, if a PostgreSQL RDS instance is desired, this can be achieved as well, if Aurora is not preferred.  

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | <6.0.0,>=5.0.0  |
| <a name="requirement_time"></a> [time](#requirement\_time) | >=0.9.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | <6.0.0,>=5.0.0  |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | >=0.9.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_rds"></a> [rds](#module\_rds) | terraform-aws-modules/rds-aurora/aws | ~> 8.3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_rds_global_cluster.global](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_global_cluster) | resource |
| [terraform_data.cluster](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [time_sleep.cluster](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_friendly_name_prefix"></a> [friendly\_name\_prefix](#input\_friendly\_name\_prefix) | Friendly name prefix used for tagging and naming AWS resources. | `string` | n/a | yes |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Map of common tags for all taggable AWS resources. | `map(string)` | `{}` | no |
| <a name="input_create_db_cloudwatch_log_group"></a> [create\_db\_cloudwatch\_log\_group](#input\_create\_db\_cloudwatch\_log\_group) | Determines whether a CloudWatch log group is created for each `enabled_cloudwatch_logs_exports` | `bool` | `true` | no |
| <a name="input_create_db_cluster_parameter_group"></a> [create\_db\_cluster\_parameter\_group](#input\_create\_db\_cluster\_parameter\_group) | Boolean that when true will create a database cluster parameter group for the TFE database cluster to use (if var.create\_database is true). | `bool` | `true` | no |
| <a name="input_create_db_global_cluster"></a> [create\_db\_global\_cluster](#input\_create\_db\_global\_cluster) | Boolean that when true will create a global cluster for Aurora to use for an Active/Standby configuration. | `bool` | `false` | no |
| <a name="input_create_db_parameter_group"></a> [create\_db\_parameter\_group](#input\_create\_db\_parameter\_group) | Boolean that when true will create a database parameter group for the TFE database cluster to use (if var.create\_database is true). | `bool` | `true` | no |
| <a name="input_create_db_security_group"></a> [create\_db\_security\_group](#input\_create\_db\_security\_group) | Boolean that when true will create the security groups for the database cluster to use (if var.create\_database is true) | `bool` | `true` | no |
| <a name="input_create_db_subnet_group"></a> [create\_db\_subnet\_group](#input\_create\_db\_subnet\_group) | Boolean that when true, will create the database subnet for the database cluster. | `bool` | `false` | no |
| <a name="input_db_allocated_storage"></a> [db\_allocated\_storage](#input\_db\_allocated\_storage) | The amount of storage in gibibytes (GiB) to allocate to each DB instance in the Multi-AZ DB cluster. (This setting is required to create a Multi-AZ DB cluster) | `number` | `256` | no |
| <a name="input_db_allow_major_version_upgrade"></a> [db\_allow\_major\_version\_upgrade](#input\_db\_allow\_major\_version\_upgrade) | Boolean that when true allows major engine version upgrades when changing engine versions. | `bool` | `false` | no |
| <a name="input_db_allowed_cidr_blocks"></a> [db\_allowed\_cidr\_blocks](#input\_db\_allowed\_cidr\_blocks) | A list of CIDR blocks which are allowed to access the database | `list(string)` | `[]` | no |
| <a name="input_db_apply_immediately"></a> [db\_apply\_immediately](#input\_db\_apply\_immediately) | Boolean that when true will apply any changes to the cluster immediately instead of waiting until the next maintenance window. | `bool` | `true` | no |
| <a name="input_db_auto_minor_version_upgrade"></a> [db\_auto\_minor\_version\_upgrade](#input\_db\_auto\_minor\_version\_upgrade) | Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window. Default `true` | `bool` | `true` | no |
| <a name="input_db_autoscaling_enabled"></a> [db\_autoscaling\_enabled](#input\_db\_autoscaling\_enabled) | Boolean that when true will enable auto scaling of the aurora postgres cluster. | `bool` | `false` | no |
| <a name="input_db_autoscaling_max_capacity"></a> [db\_autoscaling\_max\_capacity](#input\_db\_autoscaling\_max\_capacity) | Maximum number of nodes that has to be present in the autoscaling group when db\_autoscaling\_enabled is set to true. | `number` | `3` | no |
| <a name="input_db_autoscaling_min_capacity"></a> [db\_autoscaling\_min\_capacity](#input\_db\_autoscaling\_min\_capacity) | Minimum number of nodes that has to be present in the autoscaling group when db\_autoscaling\_enabled is set to true. | `number` | `1` | no |
| <a name="input_db_autoscaling_policy_name"></a> [db\_autoscaling\_policy\_name](#input\_db\_autoscaling\_policy\_name) | Autoscaling policy name | `string` | `"target-metric"` | no |
| <a name="input_db_autoscaling_predefined_metric_type"></a> [db\_autoscaling\_predefined\_metric\_type](#input\_db\_autoscaling\_predefined\_metric\_type) | The metric type to scale on. Valid values are `RDSReaderAverageCPUUtilization` and `RDSReaderAverageDatabaseConnections` | `string` | `"RDSReaderAverageCPUUtilization"` | no |
| <a name="input_db_autoscaling_scale_in_cooldown"></a> [db\_autoscaling\_scale\_in\_cooldown](#input\_db\_autoscaling\_scale\_in\_cooldown) | Cooldown in seconds before allowing further scaling operations after a scale in | `number` | `300` | no |
| <a name="input_db_autoscaling_scale_out_cooldown"></a> [db\_autoscaling\_scale\_out\_cooldown](#input\_db\_autoscaling\_scale\_out\_cooldown) | Cooldown in seconds before allowing further scaling operations after a scale out | `number` | `300` | no |
| <a name="input_db_autoscaling_target_connections"></a> [db\_autoscaling\_target\_connections](#input\_db\_autoscaling\_target\_connections) | Average number of connections threshold which will initiate autoscaling. Default value is 70% of db.r4/r5/r6g.large's default max\_connections | `number` | `700` | no |
| <a name="input_db_autoscaling_target_cpu"></a> [db\_autoscaling\_target\_cpu](#input\_db\_autoscaling\_target\_cpu) | CPU threshold which will initiate autoscaling | `number` | `70` | no |
| <a name="input_db_availability_zones"></a> [db\_availability\_zones](#input\_db\_availability\_zones) | List of EC2 Availability Zones for the DB cluster storage where DB cluster instances can be created. RDS automatically assigns 3 AZs if less than 3 AZs are configured, which will show as a difference requiring resource recreation next Terraform apply | `list(string)` | `null` | no |
| <a name="input_db_backup_retention_period"></a> [db\_backup\_retention\_period](#input\_db\_backup\_retention\_period) | The number of days to retain backups for. Must be between 0 and 35. Must be greater than 0 if the database is used as a source for a Read Replica. | `number` | `35` | no |
| <a name="input_db_ca_cert_identifier"></a> [db\_ca\_cert\_identifier](#input\_db\_ca\_cert\_identifier) | The identifier of the CA certificate for the DB instance | `string` | `null` | no |
| <a name="input_db_cloudwatch_kms_key_arn"></a> [db\_cloudwatch\_kms\_key\_arn](#input\_db\_cloudwatch\_kms\_key\_arn) | The ARN of the KMS Key to use when encrypting log data | `string` | `null` | no |
| <a name="input_db_cloudwatch_log_exports"></a> [db\_cloudwatch\_log\_exports](#input\_db\_cloudwatch\_log\_exports) | Set of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: `audit`, `error`, `general`, `slowquery`, `postgresql` | `list(string)` | <pre>[<br>  "postgresql"<br>]</pre> | no |
| <a name="input_db_cloudwatch_retention_days"></a> [db\_cloudwatch\_retention\_days](#input\_db\_cloudwatch\_retention\_days) | The number of days to retain CloudWatch logs for the DB instance | `number` | `7` | no |
| <a name="input_db_cluster_instance_class"></a> [db\_cluster\_instance\_class](#input\_db\_cluster\_instance\_class) | Instance class of the PostgreSQL database. | `string` | `"db.r6g.xlarge"` | no |
| <a name="input_db_cluster_instance_parameter_group_name"></a> [db\_cluster\_instance\_parameter\_group\_name](#input\_db\_cluster\_instance\_parameter\_group\_name) | Instance parameter group to associate with all instances of the DB cluster. The `db_cluster_db_instance_parameter_group_name` is only valid in combination with `db_allow_major_version_upgrade` | `string` | `null` | no |
| <a name="input_db_cluster_parameter_group_description"></a> [db\_cluster\_parameter\_group\_description](#input\_db\_cluster\_parameter\_group\_description) | Description that will be attatched to the database parameter group if create\_db\_parameter\_group is set to true. | `string` | `"Database cluster parameter group for the databases that are used for Terraform Enterprise."` | no |
| <a name="input_db_cluster_parameter_group_family"></a> [db\_cluster\_parameter\_group\_family](#input\_db\_cluster\_parameter\_group\_family) | Family of PostgreSQL DB cluster parameter group. | `string` | `"aurora-postgresql14"` | no |
| <a name="input_db_cluster_parameter_group_name"></a> [db\_cluster\_parameter\_group\_name](#input\_db\_cluster\_parameter\_group\_name) | Name of the database cluster parameter group that will be created (if specified) or consumed if create\_db\_cluster\_parameter\_group is false. | `string` | `"tfe-database-cluster-parameter-group"` | no |
| <a name="input_db_cluster_parameter_group_parameters"></a> [db\_cluster\_parameter\_group\_parameters](#input\_db\_cluster\_parameter\_group\_parameters) | A list of DB cluster parameters to apply. Note that parameters may differ from a family to an other. | `list(map(string))` | `[]` | no |
| <a name="input_db_copy_tags_to_snapshot"></a> [db\_copy\_tags\_to\_snapshot](#input\_db\_copy\_tags\_to\_snapshot) | Boolean to enable copying all cluster tags to the snapshot. | `bool` | `true` | no |
| <a name="input_db_create_monitoring_role"></a> [db\_create\_monitoring\_role](#input\_db\_create\_monitoring\_role) | Determines whether to create the IAM role for RDS enhanced monitoring | `bool` | `true` | no |
| <a name="input_db_database_name"></a> [db\_database\_name](#input\_db\_database\_name) | Name of database that will be created (if specified) or consumed by TFE. | `string` | `"tfe"` | no |
| <a name="input_db_deletion_protection"></a> [db\_deletion\_protection](#input\_db\_deletion\_protection) | If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to `true`. The default is `false` | `bool` | `false` | no |
| <a name="input_db_engine"></a> [db\_engine](#input\_db\_engine) | Database engine type that will be configured. Valid values are `aurora-postgresql` and `postgres` | `string` | `"aurora-postgresql"` | no |
| <a name="input_db_engine_mode"></a> [db\_engine\_mode](#input\_db\_engine\_mode) | Database engine mode. | `string` | `"provisioned"` | no |
| <a name="input_db_engine_version"></a> [db\_engine\_version](#input\_db\_engine\_version) | Database engine version. | `number` | `14.5` | no |
| <a name="input_db_final_snapshot_identifier_prefix"></a> [db\_final\_snapshot\_identifier\_prefix](#input\_db\_final\_snapshot\_identifier\_prefix) | Prefix that will be associated with the final snapshot for the database instance | `string` | `"tfe"` | no |
| <a name="input_db_global_cluster_id"></a> [db\_global\_cluster\_id](#input\_db\_global\_cluster\_id) | Aurora Global Database cluster identifier. Intended to be used by Aurora DB Cluster instance in Secondary region. | `string` | `null` | no |
| <a name="input_db_global_deletion_protection"></a> [db\_global\_deletion\_protection](#input\_db\_global\_deletion\_protection) | If the Global DB instance should have deletion protection enabled. The database can't be deleted when this value is set to `true`. The default is `false` | `bool` | `false` | no |
| <a name="input_db_iam_authentication_enabled"></a> [db\_iam\_authentication\_enabled](#input\_db\_iam\_authentication\_enabled) | Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled | `bool` | `null` | no |
| <a name="input_db_instance_class"></a> [db\_instance\_class](#input\_db\_instance\_class) | Instance class that will be applied to all of the autoscaling nodes for the PostgreSQL database if db\_enable\_autoscaling is set to true. | `string` | `"db.r6g.xlarge"` | no |
| <a name="input_db_instances"></a> [db\_instances](#input\_db\_instances) | Number of instances to deploy. | `number` | `"2"` | no |
| <a name="input_db_iops"></a> [db\_iops](#input\_db\_iops) | The amount of Provisioned IOPS (input/output operations per second) to be initially allocated for each DB instance in the Multi-AZ DB cluster | `number` | `3000` | no |
| <a name="input_db_is_primary_cluster"></a> [db\_is\_primary\_cluster](#input\_db\_is\_primary\_cluster) | Determines whether cluster is primary cluster with writer instance (set to `false` for global cluster and replica clusters) | `bool` | `true` | no |
| <a name="input_db_kms_key_arn"></a> [db\_kms\_key\_arn](#input\_db\_kms\_key\_arn) | ARN of KMS key that will be used to encrypt the storage for the database instances. | `string` | `""` | no |
| <a name="input_db_monitoring_interval"></a> [db\_monitoring\_interval](#input\_db\_monitoring\_interval) | The interval, in seconds, between points when Enhanced Monitoring metrics are collected for instances. Set to `0` to disable. Default is `0` | `number` | `0` | no |
| <a name="input_db_monitoring_role_arn"></a> [db\_monitoring\_role\_arn](#input\_db\_monitoring\_role\_arn) | IAM role used by RDS to send enhanced monitoring metrics to CloudWatch | `string` | `""` | no |
| <a name="input_db_parameter_group_description"></a> [db\_parameter\_group\_description](#input\_db\_parameter\_group\_description) | Description that will be attatched to the database parameter group if create\_db\_parameter\_group is set to true. | `string` | `"Database parameter group for the databases that are used for Terraform Enterprise."` | no |
| <a name="input_db_parameter_group_family"></a> [db\_parameter\_group\_family](#input\_db\_parameter\_group\_family) | Family of Aurora PostgreSQL DB Parameter Group. | `string` | `"aurora-postgresql14"` | no |
| <a name="input_db_parameter_group_name"></a> [db\_parameter\_group\_name](#input\_db\_parameter\_group\_name) | Name of the database parameter group that will be created (if specified) or consumed if create\_db\_cluster\_parameter\_group is false. | `string` | `"tfe-database-parameter-group"` | no |
| <a name="input_db_parameter_group_parameters"></a> [db\_parameter\_group\_parameters](#input\_db\_parameter\_group\_parameters) | A list of DB cluster parameters to apply. Note that parameters may differ from a family to an other. | `list(map(string))` | `[]` | no |
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | Password for the DB user. | `string` | `null` | no |
| <a name="input_db_performance_insights_enabled"></a> [db\_performance\_insights\_enabled](#input\_db\_performance\_insights\_enabled) | Specifies whether Performance Insights is enabled or not | `bool` | `false` | no |
| <a name="input_db_performance_insights_kms_key_arn"></a> [db\_performance\_insights\_kms\_key\_arn](#input\_db\_performance\_insights\_kms\_key\_arn) | The ARN for the KMS key to encrypt Performance Insights data | `string` | `null` | no |
| <a name="input_db_performance_insights_retention_period"></a> [db\_performance\_insights\_retention\_period](#input\_db\_performance\_insights\_retention\_period) | Amount of time in days to retain Performance Insights data. Either 7 (7 days) or 731 (2 years) | `number` | `null` | no |
| <a name="input_db_port"></a> [db\_port](#input\_db\_port) | The port on which the DB accepts connections. Defaults to the default db port for what you are deploying if null. | `number` | `5432` | no |
| <a name="input_db_preferred_backup_window"></a> [db\_preferred\_backup\_window](#input\_db\_preferred\_backup\_window) | Daily time range (UTC) for RDS backup to occur. Must not overlap with `db_preferred_maintenance_window` if specified. | `string` | `"04:00-04:30"` | no |
| <a name="input_db_preferred_maintenance_window"></a> [db\_preferred\_maintenance\_window](#input\_db\_preferred\_maintenance\_window) | Window (UTC) to perform database maintenance. Must not overlap with `db_preferred_backup_window` if specified. | `string` | `"Sun:08:00-Sun:09:00"` | no |
| <a name="input_db_publicly_accessible"></a> [db\_publicly\_accessible](#input\_db\_publicly\_accessible) | Determines whether the database is publicly accessible. | `bool` | `false` | no |
| <a name="input_db_security_group_description"></a> [db\_security\_group\_description](#input\_db\_security\_group\_description) | The description of the security group. If value is set to empty string it will contain cluster name in the description | `string` | `null` | no |
| <a name="input_db_skip_final_snapshot"></a> [db\_skip\_final\_snapshot](#input\_db\_skip\_final\_snapshot) | Determines whether a final snapshot is created before the cluster is deleted. If true is specified, no snapshot is created | `bool` | `false` | no |
| <a name="input_db_source_region"></a> [db\_source\_region](#input\_db\_source\_region) | Source region for Aurora Cross-Region Replication. Only specify for Secondary instance. | `string` | `null` | no |
| <a name="input_db_storage_encrypted"></a> [db\_storage\_encrypted](#input\_db\_storage\_encrypted) | Boolean that when set to true will use the kms\_key\_arn that has been provided via the inputs to this module | `bool` | `true` | no |
| <a name="input_db_storage_type"></a> [db\_storage\_type](#input\_db\_storage\_type) | Specifies the storage type to be associated with the DB cluster. (This setting is required to create a Multi-AZ DB cluster). Valid values: `io1`, Default: `io1` | `string` | `"io1"` | no |
| <a name="input_db_subnet_group_name"></a> [db\_subnet\_group\_name](#input\_db\_subnet\_group\_name) | The name of the subnet group name (existing or created). | `string` | `""` | no |
| <a name="input_db_subnet_ids"></a> [db\_subnet\_ids](#input\_db\_subnet\_ids) | A list of subnets IDs that will be used when creating the subnet group. If this is passed in along with create\_db\_subnet\_group = true and a subnet group isn't then it will be created based on the IDs in this list. | `list(string)` | `[]` | no |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | Username for the DB user. | `string` | `"tfe"` | no |
| <a name="input_db_vpc_security_group_ids"></a> [db\_vpc\_security\_group\_ids](#input\_db\_vpc\_security\_group\_ids) | List of VPC security groups to associate to the cluster. These will be associated along with the security groups that are created (if specified). | `list(string)` | `[]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC that the cluster will use | `string` | `"tfe-vpc"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_additional_cluster_endpoints"></a> [db\_additional\_cluster\_endpoints](#output\_db\_additional\_cluster\_endpoints) | A map of additional cluster endpoints and their attributes |
| <a name="output_db_cluster_arn"></a> [db\_cluster\_arn](#output\_db\_cluster\_arn) | Amazon Resource Name (ARN) of cluster |
| <a name="output_db_cluster_cloudwatch_log_groups"></a> [db\_cluster\_cloudwatch\_log\_groups](#output\_db\_cluster\_cloudwatch\_log\_groups) | Map of CloudWatch log groups created and their attributes |
| <a name="output_db_cluster_database_name"></a> [db\_cluster\_database\_name](#output\_db\_cluster\_database\_name) | Name for an automatically created database on cluster creation |
| <a name="output_db_cluster_endpoint"></a> [db\_cluster\_endpoint](#output\_db\_cluster\_endpoint) | Writer endpoint for the cluster |
| <a name="output_db_cluster_engine_version_actual"></a> [db\_cluster\_engine\_version\_actual](#output\_db\_cluster\_engine\_version\_actual) | The running version of the cluster database |
| <a name="output_db_cluster_hosted_zone_id"></a> [db\_cluster\_hosted\_zone\_id](#output\_db\_cluster\_hosted\_zone\_id) | The Route53 Hosted Zone ID of the endpoint |
| <a name="output_db_cluster_id"></a> [db\_cluster\_id](#output\_db\_cluster\_id) | The RDS Cluster Identifier |
| <a name="output_db_cluster_instances"></a> [db\_cluster\_instances](#output\_db\_cluster\_instances) | A map of cluster instances and their attributes |
| <a name="output_db_cluster_members"></a> [db\_cluster\_members](#output\_db\_cluster\_members) | List of RDS Instances that are a part of this cluster |
| <a name="output_db_cluster_port"></a> [db\_cluster\_port](#output\_db\_cluster\_port) | Configured port that the database cluster is listening on. |
| <a name="output_db_cluster_reader_endpoint"></a> [db\_cluster\_reader\_endpoint](#output\_db\_cluster\_reader\_endpoint) | A read-only endpoint for the cluster, automatically load-balanced across replicas |
| <a name="output_db_cluster_resource_id"></a> [db\_cluster\_resource\_id](#output\_db\_cluster\_resource\_id) | The RDS Cluster Resource ID |
| <a name="output_db_cluster_role_associations"></a> [db\_cluster\_role\_associations](#output\_db\_cluster\_role\_associations) | A map of IAM roles associated with the cluster and their attributes |
| <a name="output_db_enhanced_monitoring_iam_role_arn"></a> [db\_enhanced\_monitoring\_iam\_role\_arn](#output\_db\_enhanced\_monitoring\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the enhanced monitoring role |
| <a name="output_db_enhanced_monitoring_iam_role_name"></a> [db\_enhanced\_monitoring\_iam\_role\_name](#output\_db\_enhanced\_monitoring\_iam\_role\_name) | The name of the enhanced monitoring role |
| <a name="output_db_enhanced_monitoring_iam_role_unique_id"></a> [db\_enhanced\_monitoring\_iam\_role\_unique\_id](#output\_db\_enhanced\_monitoring\_iam\_role\_unique\_id) | Stable and unique string identifying the enhanced monitoring role |
| <a name="output_db_global_cluster_id"></a> [db\_global\_cluster\_id](#output\_db\_global\_cluster\_id) | ID of the global cluster that has been created (if specified). |
| <a name="output_db_password"></a> [db\_password](#output\_db\_password) | The database user password |
| <a name="output_db_security_group_id"></a> [db\_security\_group\_id](#output\_db\_security\_group\_id) | The security group ID of the cluster |
| <a name="output_db_subnet_group_name"></a> [db\_subnet\_group\_name](#output\_db\_subnet\_group\_name) | Database subnet group name |
| <a name="output_db_username"></a> [db\_username](#output\_db\_username) | The database user that was created |
<!-- END_TF_DOCS -->
