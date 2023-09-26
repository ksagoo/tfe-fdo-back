# HVD Terraform Enterprise Flexible Deployment Option Example

This module is an example of utilizing the `terraform-aws-tfe-prerequisites` module as part of the HashiCorp Validated Design prerequisite Solution Design Guide.  Users can use this to deploy prerequisite infrastructure required to install Terraform Enterprise into AWS 

## Description

This module showcases an example of utilizing the root module of this repository to build out the following high level components for a TFE FDO **active-active** deployment inside of AWS in a **specific region**:  

**Root Module**  
-  VPC with Public and Private access  
-  VPC Endpoints  
-  Secrets Manager Secrets  
-  S3 buckets  
-  Regional Aurora PostgreSQL cluster  
-  Redis Cluster for High Availability  
-  Application Load Balancer, Listeners, and Target Groups  
-  Route 53 entries  
-  KMS Encryption Keys  
-  Log Groups for TFE  
-  TFE KeyPair for TFE  

## Getting Started

### Dependencies

* Terraform Community Edition or Terraform Cloud for seeding
* A valid certificate for TFE.  
>**Note**
>
>There is a **supplemental-modules** folder and within that there is some sample code that will generate a certificate with LetsEncrypt. If you do not have certificates prepared, you can modified the values in `supplemental-modules/generate-cert/terraform-auto.tfvars` and then do a `terraform plan` and `terraform apply`. This will create certificates within the `generate-cert` folder that can be referenced in the main run.

### Executing program

Modify the `terraform.auto.tfvars` file with parameters pertinent to your environment.  As part of the HVD, some settings are pre-selected or marked as recommended or required. 

Once this is updated, authenticate to AWS then run through the standard Terraform Workflow:  

``` hcl
terraform init
terraform plan
terraform apply
```

The deployment will take roughly 14 minutes to complete.  

## Deployment of TFE  

Note that this module is designed to create the necessary pre-requisite infrastructure within AWS to prepare for the deployment of TFE on EC2.  Once the deployment completes, utilize a different workspace to manage the deployment of TFE on AWS, separating state and responsibilities.  

An example of the recommended and minimum inputs for TFE on AWS following the HVD Solution Design Guide can be found within the [terraform-aws-tfe](https://github.com/hashicorp-modules/terraform-aws-tfe-prerequisites/tree/33-refactor/) module under `/examples/hvd-tfe`.  

## Authors

* Kalen Arndt  
* Sean Doyle  
* HVD Terraform Team  

## HVD Example Version History

* 0.1
    * Initial Release

## Acknowledgments

HashiCorp IS and HashiCorp Engineering have been huge inspirations for this effort

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=4.55.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_pre_req_primary"></a> [pre\_req\_primary](#module\_pre\_req\_primary) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_redis_replication_group"></a> [create\_redis\_replication\_group](#input\_create\_redis\_replication\_group) | Boolean that determines if the pre-requisites for an active active deployment of TFE will be deployed. | `bool` | n/a | yes |
| <a name="input_db_database_name"></a> [db\_database\_name](#input\_db\_database\_name) | Name of database that will be created (if specified) or consumed by TFE. | `string` | n/a | yes |
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | Password for the DB user. | `string` | n/a | yes |
| <a name="input_friendly_name_prefix"></a> [friendly\_name\_prefix](#input\_friendly\_name\_prefix) | Friendly name prefix used for tagging and naming AWS resources. | `string` | n/a | yes |
| <a name="input_iam_resources"></a> [iam\_resources](#input\_iam\_resources) | A list of objects for to be referenced in an IAM policy for the instance.  Each is a list of strings that reference infra related to the install | <pre>object({<br>    bucket_arns             = optional(list(string), [])<br>    kms_key_arns            = optional(list(string), [])<br>    secret_manager_arns     = optional(list(string), [])<br>    log_group_arn           = optional(string, "")<br>    log_forwarding_enabled  = optional(bool, true)<br>    role_name               = optional(string, "deployment-role")<br>    policy_name             = optional(string, "deployment-policy")<br>    ssm_enable              = optional(bool, false)<br>    custom_tbw_ecr_repo_arn = optional(string, "")<br>  })</pre> | n/a | yes |
| <a name="input_tfe_active_active"></a> [tfe\_active\_active](#input\_tfe\_active\_active) | Boolean that determines if the pre-requisites for an active active deployment of TFE will be deployed. | `bool` | n/a | yes |
| <a name="input_vpc_enable_ssm"></a> [vpc\_enable\_ssm](#input\_vpc\_enable\_ssm) | Boolean that when true will create a security group allowing port 443 to the private\_subnets within the VPC (if create\_vpc is true) | `bool` | n/a | yes |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Map of common tags for all taggable AWS resources. | `map(string)` | `{}` | no |
| <a name="input_create_ssh_keypair"></a> [create\_ssh\_keypair](#input\_create\_ssh\_keypair) | Boolean to deploy TFE SSH key pair. This does not create the private key, it only creates the key pair with a provided public key. | `bool` | `false` | no |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | Username for the DB user. | `string` | `"tfe"` | no |
| <a name="input_lb_sg_rules_details"></a> [lb\_sg\_rules\_details](#input\_lb\_sg\_rules\_details) | Object map for various Security Group Rules as pertains to the Load Balancer for TFE | <pre>object({<br>    tfe_api_ingress = optional(object({<br>      type        = optional(string, "ingress")<br>      create      = optional(bool, true)<br>      from_port   = optional(string, "443")<br>      to_port     = optional(string, "443")<br>      protocol    = optional(string, "tcp")<br>      cidr_blocks = optional(list(string), [])<br>      description = optional(string, "Allow 443 traffic inbound for TFE")<br>    }), {})<br>    tfe_console_ingress = optional(object({<br>      type        = optional(string, "ingress")<br>      create      = optional(bool, true)<br>      from_port   = optional(string, "8800")<br>      to_port     = optional(string, "8800")<br>      protocol    = optional(string, "tcp")<br>      cidr_blocks = optional(list(string), [])<br>      description = optional(string, "Allow 8800 traffic inbound for TFE")<br>    }), {})<br>    egress = optional(object({<br>      create      = optional(bool, true)<br>      type        = optional(string, "egress")<br>      from_port   = optional(string, "0")<br>      to_port     = optional(string, "0")<br>      protocol    = optional(string, "-1")<br>      cidr_blocks = optional(list(string), ["0.0.0.0/0"])<br>      description = optional(string, "Allow traffic outbound for TFE")<br>    }), {})<br>  })</pre> | `{}` | no |
| <a name="input_optional_secrets"></a> [optional\_secrets](#input\_optional\_secrets) | Optional variable that when supplied will be merged with the `secretsmanager_secrets` map. These secrets need to have the following specification:<br>  optional\_secrets = {<br>    secret\_1 = {<br>      name = "supesecret"<br>      description = "it's my secret that is important"<br>      path = "path to file if you are using one"<br>      data = "string data if you are supplying it"<br>    }<br>    secret\_2 = {<br>      name = "supesecret2"<br>      description = "it's my secret that is also important probably"<br>      path = "path to file if you are using one"<br>      data = "string data if you are supplying it"<br>    }<br>  } | `map(any)` | `{}` | no |
| <a name="input_redis_password"></a> [redis\_password](#input\_redis\_password) | Password for the redis instance. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | `"us-east-2"` | no |
| <a name="input_route53_failover_record"></a> [route53\_failover\_record](#input\_route53\_failover\_record) | If set, creates a Route53 failover record.  Ensure that the record name is the same between both modules.  Also, the Record ID needs to be unique per module | <pre>object({<br>    create              = optional(bool, true)<br>    set_id              = optional(string, "fso1")<br>    lb_failover_primary = optional(bool, true)<br>    record_name         = optional(string)<br>  })</pre> | `{}` | no |
| <a name="input_route53_zone_name"></a> [route53\_zone\_name](#input\_route53\_zone\_name) | Route 53 public zone name | `string` | `""` | no |
| <a name="input_s3_buckets"></a> [s3\_buckets](#input\_s3\_buckets) | Object Map that contains the configuration for the S3 logging and bootstrap bucket configuration. | <pre>object({<br>    bootstrap = optional(object({<br>      create                              = optional(bool, true)<br>      bucket_name                         = optional(string, "tfe-bootstrap-bucket")<br>      description                         = optional(string, "Bootstrap bucket for the TFE instances and install")<br>      versioning                          = optional(bool, true)<br>      force_destroy                       = optional(bool, false)<br>      replication                         = optional(bool)<br>      replication_destination_bucket_arn  = optional(string)<br>      replication_destination_kms_key_arn = optional(string)<br>      replication_destination_region      = optional(string)<br>      encrypt                             = optional(bool, true)<br>      bucket_key_enabled                  = optional(bool, true)<br>      kms_key_arn                         = optional(string)<br>      sse_s3_managed_key                  = optional(bool, false)<br>      is_secondary_region                 = optional(bool, false)<br>    }), {})<br>    tfe_app = optional(object({<br>      create                              = optional(bool, true)<br>      bucket_name                         = optional(string, "tfe-app-bucket")<br>      description                         = optional(string, "Object store for TFE")<br>      versioning                          = optional(bool, true)<br>      force_destroy                       = optional(bool, false)<br>      replication                         = optional(bool)<br>      replication_destination_bucket_arn  = optional(string)<br>      replication_destination_kms_key_arn = optional(string)<br>      replication_destination_region      = optional(string)<br>      encrypt                             = optional(bool, true)<br>      bucket_key_enabled                  = optional(bool, true)<br>      kms_key_arn                         = optional(string)<br>      sse_s3_managed_key                  = optional(bool, false)<br>      is_secondary_region                 = optional(bool, false)<br>    }), {})<br>    logging = optional(object({<br>      create                              = optional(bool, true)<br>      bucket_name                         = optional(string, "hashicorp-log-bucket")<br>      versioning                          = optional(bool, false)<br>      force_destroy                       = optional(bool, false)<br>      replication                         = optional(bool, false)<br>      replication_destination_bucket_arn  = optional(string)<br>      replication_destination_kms_key_arn = optional(string)<br>      replication_destination_region      = optional(string)<br>      encrypt                             = optional(bool, true)<br>      bucket_key_enabled                  = optional(bool, true)<br>      kms_key_arn                         = optional(string)<br>      sse_s3_managed_key                  = optional(bool, false)<br>      lifecycle_enabled                   = optional(bool, true)<br>      lifecycle_expiration_days           = optional(number, 7)<br>      is_secondary_region                 = optional(bool, false)<br>    }), {})<br>  })</pre> | `{}` | no |
| <a name="input_secretsmanager_secrets"></a> [secretsmanager\_secrets](#input\_secretsmanager\_secrets) | Object Map that contains various TFE secrets that will be created and stored in AWS Secrets Manager. | <pre>object({<br>    license = optional(object({<br>      name        = optional(string, "tfe-license")<br>      path        = optional(string, null)<br>      description = optional(string, "TFE license")<br>      data        = optional(string, null)<br>    }), {})<br>    tfe_console_password = optional(object({<br>      name        = optional(string, "console-password")<br>      description = optional(string, "Console password used in the TFE installation")<br>      data        = optional(string, null)<br>      generate    = optional(bool, false)<br>    }), {})<br>    tfe_enc_password = optional(object({<br>      name        = optional(string, "enc-password")<br>      description = optional(string, "Encryption password used in the TFE installation")<br>      data        = optional(string, null)<br>      generate    = optional(bool, false)<br>    }), {})<br>    ca_certificate_bundle = optional(object({<br>      name        = optional(string, null)<br>      path        = optional(string, null)<br>      description = optional(string, "TFE BYO CA certificate bundle")<br>      data        = optional(string, null)<br>    }))<br>    cert_pem_secret = optional(object({<br>      name        = optional(string, null)<br>      path        = optional(string, null)<br>      description = optional(string, "TFE BYO PEM-encoded TLS certificate")<br>      data        = optional(string, null)<br>    }))<br>    cert_pem_private_key_secret = optional(object({<br>      name        = optional(string, null)<br>      path        = optional(string, null)<br>      description = optional(string, "TFE BYO PEM-encoded TLS private key")<br>      data        = optional(string, null)<br>    }))<br>  })</pre> | `{}` | no |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | Public key material for TFE SSH Key Pair. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acm_certificate_arn"></a> [acm\_certificate\_arn](#output\_acm\_certificate\_arn) | The ARN of the certificate |
| <a name="output_acm_certificate_status"></a> [acm\_certificate\_status](#output\_acm\_certificate\_status) | Status of the certificate |
| <a name="output_acm_distinct_domain_names"></a> [acm\_distinct\_domain\_names](#output\_acm\_distinct\_domain\_names) | List of distinct domains names used for the validation |
| <a name="output_acm_validation_domains"></a> [acm\_validation\_domains](#output\_acm\_validation\_domains) | List of distinct domain validation options. This is useful if subject alternative names contain wildcards |
| <a name="output_acm_validation_route53_record_fqdns"></a> [acm\_validation\_route53\_record\_fqdns](#output\_acm\_validation\_route53\_record\_fqdns) | List of FQDNs built using the zone domain and name |
| <a name="output_asg_hook_value"></a> [asg\_hook\_value](#output\_asg\_hook\_value) | Value for the `asg-hook` tag that will be attatched to the TFE instance in the other module. Use this value to ensure the lifecycle hook is updated during deployment. |
| <a name="output_ca_certificate_bundle_secret_arn"></a> [ca\_certificate\_bundle\_secret\_arn](#output\_ca\_certificate\_bundle\_secret\_arn) | AWS Secrets Manager TFE BYO CA certificate secret ARN. |
| <a name="output_cert_pem_private_key_secret_arn"></a> [cert\_pem\_private\_key\_secret\_arn](#output\_cert\_pem\_private\_key\_secret\_arn) | AWS Secrets Manager TFE BYO CA certificate private key secret ARN. |
| <a name="output_cert_pem_secret_arn"></a> [cert\_pem\_secret\_arn](#output\_cert\_pem\_secret\_arn) | AWS Secrets Manager TFE BYO CA certificate private key secret ARN. |
| <a name="output_db_additional_cluster_endpoints"></a> [db\_additional\_cluster\_endpoints](#output\_db\_additional\_cluster\_endpoints) | A map of additional cluster endpoints and their attributes |
| <a name="output_db_cluster_arn"></a> [db\_cluster\_arn](#output\_db\_cluster\_arn) | Amazon Resource Name (ARN) of cluster |
| <a name="output_db_cluster_cloudwatch_log_groups"></a> [db\_cluster\_cloudwatch\_log\_groups](#output\_db\_cluster\_cloudwatch\_log\_groups) | Map of CloudWatch log groups created and their attributes |
| <a name="output_db_cluster_database_name"></a> [db\_cluster\_database\_name](#output\_db\_cluster\_database\_name) | Name for an automatically created database on cluster creation |
| <a name="output_db_cluster_endpoint"></a> [db\_cluster\_endpoint](#output\_db\_cluster\_endpoint) | Writer endpoint for the cluster |
| <a name="output_db_cluster_engine_version_actual"></a> [db\_cluster\_engine\_version\_actual](#output\_db\_cluster\_engine\_version\_actual) | The running version of the cluster database |
| <a name="output_db_cluster_id"></a> [db\_cluster\_id](#output\_db\_cluster\_id) | The RDS Cluster Identifier |
| <a name="output_db_cluster_instances"></a> [db\_cluster\_instances](#output\_db\_cluster\_instances) | A map of cluster instances and their attributes |
| <a name="output_db_cluster_members"></a> [db\_cluster\_members](#output\_db\_cluster\_members) | List of RDS Instances that are a part of this cluster |
| <a name="output_db_cluster_port"></a> [db\_cluster\_port](#output\_db\_cluster\_port) | The database port |
| <a name="output_db_cluster_reader_endpoint"></a> [db\_cluster\_reader\_endpoint](#output\_db\_cluster\_reader\_endpoint) | A read-only endpoint for the cluster, automatically load-balanced across replicas |
| <a name="output_db_cluster_resource_id"></a> [db\_cluster\_resource\_id](#output\_db\_cluster\_resource\_id) | The RDS Cluster Resource ID |
| <a name="output_db_cluster_role_associations"></a> [db\_cluster\_role\_associations](#output\_db\_cluster\_role\_associations) | A map of IAM roles associated with the cluster and their attributes |
| <a name="output_db_enhanced_monitoring_iam_role_arn"></a> [db\_enhanced\_monitoring\_iam\_role\_arn](#output\_db\_enhanced\_monitoring\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the enhanced monitoring role |
| <a name="output_db_enhanced_monitoring_iam_role_name"></a> [db\_enhanced\_monitoring\_iam\_role\_name](#output\_db\_enhanced\_monitoring\_iam\_role\_name) | The name of the enhanced monitoring role |
| <a name="output_db_enhanced_monitoring_iam_role_unique_id"></a> [db\_enhanced\_monitoring\_iam\_role\_unique\_id](#output\_db\_enhanced\_monitoring\_iam\_role\_unique\_id) | Stable and unique string identifying the enhanced monitoring role |
| <a name="output_db_global_cluster_id"></a> [db\_global\_cluster\_id](#output\_db\_global\_cluster\_id) | ID of the global cluster that has been created (if specified.) |
| <a name="output_db_password"></a> [db\_password](#output\_db\_password) | The database master password |
| <a name="output_db_security_group_id"></a> [db\_security\_group\_id](#output\_db\_security\_group\_id) | The security group ID of the cluster |
| <a name="output_db_subnet_arns"></a> [db\_subnet\_arns](#output\_db\_subnet\_arns) | List of ARNs of database subnets |
| <a name="output_db_subnet_group"></a> [db\_subnet\_group](#output\_db\_subnet\_group) | ID of database subnet group |
| <a name="output_db_subnet_group_name"></a> [db\_subnet\_group\_name](#output\_db\_subnet\_group\_name) | Name of database subnet group |
| <a name="output_db_subnet_ids"></a> [db\_subnet\_ids](#output\_db\_subnet\_ids) | List of IDs of database subnets |
| <a name="output_db_subnets_cidr_blocks"></a> [db\_subnets\_cidr\_blocks](#output\_db\_subnets\_cidr\_blocks) | List of cidr\_blocks of database subnets |
| <a name="output_db_subnets_ipv6_cidr_blocks"></a> [db\_subnets\_ipv6\_cidr\_blocks](#output\_db\_subnets\_ipv6\_cidr\_blocks) | List of IPv6 cidr\_blocks of database subnets in an IPv6 enabled VPC |
| <a name="output_db_username"></a> [db\_username](#output\_db\_username) | The database master username |
| <a name="output_default_security_group_id"></a> [default\_security\_group\_id](#output\_default\_security\_group\_id) | The ID of the security group created by default on VPC creation |
| <a name="output_iam_instance_profile"></a> [iam\_instance\_profile](#output\_iam\_instance\_profile) | ARN of IAM Instance Profile for TFE Instance Role |
| <a name="output_iam_managed_policy_arn"></a> [iam\_managed\_policy\_arn](#output\_iam\_managed\_policy\_arn) | ARN of IAM Managed Policy for TFE Instance Role |
| <a name="output_iam_managed_policy_name"></a> [iam\_managed\_policy\_name](#output\_iam\_managed\_policy\_name) | Name of IAM Managed Policy for TFE Instance Role |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | ARN of IAM Role in use by TFE Instances |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | Name of IAM Role in use by TFE Instances |
| <a name="output_kms_key_alias"></a> [kms\_key\_alias](#output\_kms\_key\_alias) | The KMS Key Alias |
| <a name="output_kms_key_alias_arn"></a> [kms\_key\_alias\_arn](#output\_kms\_key\_alias\_arn) | The KMS Key Alias arn |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | The KMS key used to encrypt data. |
| <a name="output_lb_arn"></a> [lb\_arn](#output\_lb\_arn) | The Resource Identifier of the LB |
| <a name="output_lb_dns_name"></a> [lb\_dns\_name](#output\_lb\_dns\_name) | The DNS name created with the LB |
| <a name="output_lb_internal"></a> [lb\_internal](#output\_lb\_internal) | Boolean value of the internal/external status of the LB.  Determines if the LB gets Elastic IPs assigned |
| <a name="output_lb_name"></a> [lb\_name](#output\_lb\_name) | Name of the LB |
| <a name="output_lb_security_group_ids"></a> [lb\_security\_group\_ids](#output\_lb\_security\_group\_ids) | List of security group IDs in use by the LB |
| <a name="output_lb_tg_arns"></a> [lb\_tg\_arns](#output\_lb\_tg\_arns) | List of target group ARNs for LB |
| <a name="output_lb_type"></a> [lb\_type](#output\_lb\_type) | Type of LB created (ALB or NLB) |
| <a name="output_lb_zone_id"></a> [lb\_zone\_id](#output\_lb\_zone\_id) | The Zone ID of the LB |
| <a name="output_license_secret_arn"></a> [license\_secret\_arn](#output\_license\_secret\_arn) | AWS Secrets Manager tfe\_license secret ARN. |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | AWS CloudWatch Log Group Name. |
| <a name="output_private_route_table_ids"></a> [private\_route\_table\_ids](#output\_private\_route\_table\_ids) | List of IDs of private route tables |
| <a name="output_private_subnet_arns"></a> [private\_subnet\_arns](#output\_private\_subnet\_arns) | List of ARNs of private subnets |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | List of IDs of private subnets |
| <a name="output_private_subnets_cidr_blocks"></a> [private\_subnets\_cidr\_blocks](#output\_private\_subnets\_cidr\_blocks) | List of cidr\_blocks of private subnets |
| <a name="output_private_subnets_ipv6_cidr_blocks"></a> [private\_subnets\_ipv6\_cidr\_blocks](#output\_private\_subnets\_ipv6\_cidr\_blocks) | List of IPv6 cidr\_blocks of private subnets in an IPv6 enabled VPC |
| <a name="output_public_route_table_ids"></a> [public\_route\_table\_ids](#output\_public\_route\_table\_ids) | List of IDs of public route tables |
| <a name="output_public_subnet_arns"></a> [public\_subnet\_arns](#output\_public\_subnet\_arns) | List of ARNs of public subnets |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | List of IDs of public subnets |
| <a name="output_public_subnets_cidr_blocks"></a> [public\_subnets\_cidr\_blocks](#output\_public\_subnets\_cidr\_blocks) | List of cidr\_blocks of public subnets |
| <a name="output_public_subnets_ipv6_cidr_blocks"></a> [public\_subnets\_ipv6\_cidr\_blocks](#output\_public\_subnets\_ipv6\_cidr\_blocks) | List of IPv6 cidr\_blocks of public subnets in an IPv6 enabled VPC |
| <a name="output_redis_password"></a> [redis\_password](#output\_redis\_password) | Auth token that is used to access the Redis replication group. |
| <a name="output_redis_port"></a> [redis\_port](#output\_redis\_port) | Port that the redis cluster is listening on. |
| <a name="output_redis_primary_endpoint"></a> [redis\_primary\_endpoint](#output\_redis\_primary\_endpoint) | Address of the endpoint of the primary node in the replication group. |
| <a name="output_redis_replication_group_arn"></a> [redis\_replication\_group\_arn](#output\_redis\_replication\_group\_arn) | ARN of the created Redis replication group. |
| <a name="output_redis_security_group_id"></a> [redis\_security\_group\_id](#output\_redis\_security\_group\_id) | ID of redis security group |
| <a name="output_redis_security_group_ids"></a> [redis\_security\_group\_ids](#output\_redis\_security\_group\_ids) | List of security groups that are associated with the Redis replication group. |
| <a name="output_redis_security_group_name"></a> [redis\_security\_group\_name](#output\_redis\_security\_group\_name) | Name of redis security group |
| <a name="output_redis_subnet_arns"></a> [redis\_subnet\_arns](#output\_redis\_subnet\_arns) | List of ARNs of redis subnets |
| <a name="output_redis_subnet_group"></a> [redis\_subnet\_group](#output\_redis\_subnet\_group) | ID of redis subnet group |
| <a name="output_redis_subnet_group_name"></a> [redis\_subnet\_group\_name](#output\_redis\_subnet\_group\_name) | Name of redis subnet group |
| <a name="output_redis_subnets"></a> [redis\_subnets](#output\_redis\_subnets) | List of IDs of redis subnets |
| <a name="output_redis_subnets_cidr_blocks"></a> [redis\_subnets\_cidr\_blocks](#output\_redis\_subnets\_cidr\_blocks) | List of cidr\_blocks of redis subnets |
| <a name="output_redis_subnets_ipv6_cidr_blocks"></a> [redis\_subnets\_ipv6\_cidr\_blocks](#output\_redis\_subnets\_ipv6\_cidr\_blocks) | List of IPv6 cidr\_blocks of redis subnets in an IPv6 enabled VPC |
| <a name="output_region"></a> [region](#output\_region) | The AWS region where the resources have been created |
| <a name="output_route53_failover_fqdn"></a> [route53\_failover\_fqdn](#output\_route53\_failover\_fqdn) | FQDN of failover LB Route53 record |
| <a name="output_route53_failover_record_name"></a> [route53\_failover\_record\_name](#output\_route53\_failover\_record\_name) | Name of the failover LB Route53 record name |
| <a name="output_route53_regional_fqdn"></a> [route53\_regional\_fqdn](#output\_route53\_regional\_fqdn) | FQDN of regional LB Route53 record |
| <a name="output_route53_regional_record_name"></a> [route53\_regional\_record\_name](#output\_route53\_regional\_record\_name) | Name of the regional LB Route53 record name |
| <a name="output_s3_bootstrap_bucket_arn"></a> [s3\_bootstrap\_bucket\_arn](#output\_s3\_bootstrap\_bucket\_arn) | ARN of S3 'bootstrap' bucket |
| <a name="output_s3_bootstrap_bucket_name"></a> [s3\_bootstrap\_bucket\_name](#output\_s3\_bootstrap\_bucket\_name) | Name of S3 'bootstrap' bucket. |
| <a name="output_s3_bootstrap_bucket_replication_policy"></a> [s3\_bootstrap\_bucket\_replication\_policy](#output\_s3\_bootstrap\_bucket\_replication\_policy) | Replication policy of the S3 'bootstrap' bucket. |
| <a name="output_s3_bucket_arn_list"></a> [s3\_bucket\_arn\_list](#output\_s3\_bucket\_arn\_list) | A list of the ARNs for the buckets that have been configured |
| <a name="output_s3_log_bucket_arn"></a> [s3\_log\_bucket\_arn](#output\_s3\_log\_bucket\_arn) | Name of S3 'logging' bucket. |
| <a name="output_s3_log_bucket_name"></a> [s3\_log\_bucket\_name](#output\_s3\_log\_bucket\_name) | Name of S3 'logging' bucket. |
| <a name="output_s3_log_bucket_replication_policy"></a> [s3\_log\_bucket\_replication\_policy](#output\_s3\_log\_bucket\_replication\_policy) | Replication policy of the S3 'logging' bucket. |
| <a name="output_s3_replication_iam_role_arn"></a> [s3\_replication\_iam\_role\_arn](#output\_s3\_replication\_iam\_role\_arn) | ARN of IAM Role for S3 replication. |
| <a name="output_s3_tfe_app_bucket_arn"></a> [s3\_tfe\_app\_bucket\_arn](#output\_s3\_tfe\_app\_bucket\_arn) | ARN of the S3 Terraform Enterprise Object Store bucket. |
| <a name="output_s3_tfe_app_bucket_name"></a> [s3\_tfe\_app\_bucket\_name](#output\_s3\_tfe\_app\_bucket\_name) | Name of S3 S3 Terraform Enterprise Object Store bucket. |
| <a name="output_s3_tfe_app_bucket_replication_policy"></a> [s3\_tfe\_app\_bucket\_replication\_policy](#output\_s3\_tfe\_app\_bucket\_replication\_policy) | Replication policy of the S3 Terraform Enterprise Object Store bucket. |
| <a name="output_secret_arn_list"></a> [secret\_arn\_list](#output\_secret\_arn\_list) | A list of AWS Secrets Manager Arns produced by the module |
| <a name="output_ssh_keypair_arn"></a> [ssh\_keypair\_arn](#output\_ssh\_keypair\_arn) | ARN of the keypair that was created (if specified). |
| <a name="output_ssh_keypair_fingerprint"></a> [ssh\_keypair\_fingerprint](#output\_ssh\_keypair\_fingerprint) | Fingerprint of TFE SSH Key Pair. |
| <a name="output_ssh_keypair_id"></a> [ssh\_keypair\_id](#output\_ssh\_keypair\_id) | ID of TFE SSH Key Pair. |
| <a name="output_ssh_keypair_name"></a> [ssh\_keypair\_name](#output\_ssh\_keypair\_name) | Name of the keypair that was created (if specified). |
| <a name="output_tfe_console_password_arn"></a> [tfe\_console\_password\_arn](#output\_tfe\_console\_password\_arn) | AWS Secrets Manager console\_password secret ARN. |
| <a name="output_tfe_enc_password_arn"></a> [tfe\_enc\_password\_arn](#output\_tfe\_enc\_password\_arn) | AWS Secrets Manager enc\_password secret ARN. |
| <a name="output_vpc_arn"></a> [vpc\_arn](#output\_vpc\_arn) | The ARN of the VPC |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | The CIDR block of the VPC |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
<!-- END_TF_DOCS -->
