# HVD Terraform Enterprise Flexible Deployment Option Example

This module is an example of utilizing the `terraform-aws-tfe` module as part of the HashiCorp Validated Design Solution Design Guide.  Users can use this to deploy TFE according to the Validated Design into AWS. 

## Description

This module showcases an example of utilizing the root module of this repository to build out the following high level components for a TFE FDO **active-active** deployment inside of AWS in a **specific region**:  

**Root Module**  
-  AWS Auto Scaling Group
-  AWS Auto Scaling Lifecycle hook
-  AWS Launch Template for ASG
-  AWS Security Group for EC2
-  AWS Security Group rules for EC2

## Getting Started

### Dependencies

* Terraform Community Edition or Terraform Cloud for seeding
* Access to Quay (pre-GA)

### Executing program

Modify the `terraform.auto.tfvars` file with parameters pertinent to your environment.  As part of the HVD, some settings are pre-selected or marked as recommended or required. 

Once this is updated, authenticate to AWS then run through the standard Terraform Workflow:  

``` hcl
terraform init
terraform plan
terraform apply
```
---

## Deployment of Prerequisite AWS Infrastructure  

Note that this module requires specific infrastructure to be available prior to launching.  This includes but is not limited too:

* AWS ECR Repository (if required)
* AWS Security Group for DB
* AWS Security Group rules for DB
* Load Balancer, Listeners, and Target Groups
* KMS Encryption Keys
* Log Groups for Terraform Enterprise
* Redis DB
* PostgreSQL DB cluster
* DNS Record for TFE
* S3 buckets
* Secrets Manager Secrets (for License, TLS Certificate and Private Key, and Credentials)
* SSH KeyPair for Terraform Enterprise (if not using SSM)
* VPC Endpoints (if using Private Networking)
* VPC with internet access 
* EC2 Instance Profile with access to:  
  * TFE S3 Bucket  
  * Secrets Manager TFE secrets  
  * TFE KMS Keys  
  * TFE Log Group  


 If you require building any or all of this infrastructure, we provide guidance as outlined in the Solution Design Guide to do so within the `terraform-aws-tfe-prerequisite` module.  This module is designed to create the necessary pre-requisite infrastructure within AWS to prepare for the deployment of TFE on EC2.  

An example of creating the required prerequisite infrastructure for TFE on AWS following the HVD Solution Design Guide can be found within the [terraform-aws-tfe-prerequisites](https://github.com/hashicorp-modules/terraform-aws-tfe-prerequisites/tree/46-refactor/) module under `/examples/hvd-tfe`.  

---

## 📝 Note
Contained below is a table that outlines the input for the module and the corresponding output from the `terraform-aws-tfe-prerequisite` module.

| Deployment Module Input | Prerequisite Module Output |
| ------- | ----------- |
|  `friendly_name_prefix` | `N/A`
| `ssh_key_pair` | `ssh_keypair_name` |
| `vpc_id` | `vpc_id` |
| `tfe_hostname` | `route53_failover_fqdn` |
| `iam_instance_profile` | `iam_profile_name` |
| `kms_key_arn` | `kms_key_alias_arn` |
| `ec2_subnet_ids` | `private_subnet_ids` |
| `lb_tg_arns` | `lb_tg_arns` |
| `lb_type` | `lb_type` |
| `lb_security_group_id` | `lb_security_group_ids` |
| `s3_app_bucket_name` | `s3_tfe_app_bucket_name` |
| `s3_log_bucket_name` | `s3_log_bucket_name` |
| `cloudwatch_log_group_name` | `log_group_name` |
| `license_secret_arn` | `license_secret_arn` |
| `enc_password_arn` | `tfe_enc_password_arn` |
| `console_password_arn` | `tfe_console_password_arn` |
| `tfe_cert_secret_arn` | `cert_pem_secret_arn` |
| `tfe_privkey_secret_arn` | `cert_pem_private_key_secret_arn` |
| `ca_bundle_secret_arn` | `ca_bundle_secret_arn` |
| `db_username` | `db_username` |
| `db_password` | `db_password` |
| `db_database_name` | `db_cluster_database_name` |
| `db_cluster_endpoint` | `db_cluster_endpoint` |
| `asg_hook_value` | `asg_hook_value` |
| `redis_host` | `redis_primary_endpoint` |
| `redis_port` | `redis_port` |
| `redis_password` | `redis_password` |
| `redis_security_group_id` | `redis_security_group_ids` |
| `product` | `N/A` |
| `asg_max_size` | `N/A` |
| `asg_instance_count` | `N/A` |
| `common_tags` | `N/A` |

## Authors

* Kalen Arndt 
* Sean Doyle  

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
| <a name="module_tfe"></a> [tfe](#module\_tfe) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_asg_hook_value"></a> [asg\_hook\_value](#input\_asg\_hook\_value) | Value for the tag that is associated with the launch template. This is used for the lifecycle hook checkin. | `string` | n/a | yes |
| <a name="input_ca_bundle_secret_arn"></a> [ca\_bundle\_secret\_arn](#input\_ca\_bundle\_secret\_arn) | ARN of AWS Secrets Manager secret for private/custom CA bundles. New lines must be replaced by `<br>` character prior to storing as a plaintext secret. | `string` | n/a | yes |
| <a name="input_db_cluster_endpoint"></a> [db\_cluster\_endpoint](#input\_db\_cluster\_endpoint) | Writer endpoint for the database cluster. | `string` | n/a | yes |
| <a name="input_db_database_name"></a> [db\_database\_name](#input\_db\_database\_name) | Name of database that will be created (if specified) or consumed by TFE. | `string` | n/a | yes |
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | Password for the DB user. | `string` | n/a | yes |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | Username for the DB user. | `string` | n/a | yes |
| <a name="input_ec2_subnet_ids"></a> [ec2\_subnet\_ids](#input\_ec2\_subnet\_ids) | List of subnet IDs to use for the EC2 instance. Private subnets is the best practice. | `list(string)` | n/a | yes |
| <a name="input_friendly_name_prefix"></a> [friendly\_name\_prefix](#input\_friendly\_name\_prefix) | Friendly name prefix used for tagging and naming AWS resources. | `string` | n/a | yes |
| <a name="input_iam_profile_name"></a> [iam\_profile\_name](#input\_iam\_profile\_name) | Name of AWS IAM Instance Profile for TFE EC2 Instance | `string` | n/a | yes |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of KMS key to encrypt TFE RDS, S3, EBS, and Redis resources. | `string` | n/a | yes |
| <a name="input_lb_security_group_id"></a> [lb\_security\_group\_id](#input\_lb\_security\_group\_id) | Security Group ID for the Load Balancer | `string` | n/a | yes |
| <a name="input_lb_tg_arns"></a> [lb\_tg\_arns](#input\_lb\_tg\_arns) | List of Target Group ARNs associated with the TFE Load Balancer | `list(any)` | n/a | yes |
| <a name="input_lb_type"></a> [lb\_type](#input\_lb\_type) | String indicating whether the load balancer deployed is an Application Load Balancer (alb) or Network Load Balancer (nlb). | `string` | n/a | yes |
| <a name="input_license_secret_arn"></a> [license\_secret\_arn](#input\_license\_secret\_arn) | ARN of the TFE license that is stored within secrets manager. | `string` | n/a | yes |
| <a name="input_redis_host"></a> [redis\_host](#input\_redis\_host) | Endpoint url for the Redis replication group that TFE should connect to. | `string` | n/a | yes |
| <a name="input_redis_password"></a> [redis\_password](#input\_redis\_password) | Password for the redis instance. | `string` | n/a | yes |
| <a name="input_redis_security_group_id"></a> [redis\_security\_group\_id](#input\_redis\_security\_group\_id) | Existing security group ID that is attatched to the redis cluster. This will be used when adding rules to access the cluster from the TFE instances. | `string` | n/a | yes |
| <a name="input_tfe_active_active"></a> [tfe\_active\_active](#input\_tfe\_active\_active) | Boolean that determines if the pre-requisites for an active active deployment of TFE will be deployed. | `bool` | n/a | yes |
| <a name="input_tfe_cert_secret_arn"></a> [tfe\_cert\_secret\_arn](#input\_tfe\_cert\_secret\_arn) | ARN of AWS Secrets Manager secret for TFE server certificate in PEM format. Required if `tls_bootstrap_type` is `server-path`; otherwise ignored. | `string` | n/a | yes |
| <a name="input_tfe_console_password_arn"></a> [tfe\_console\_password\_arn](#input\_tfe\_console\_password\_arn) | Password to unlock TFE Admin Console accessible via port 8800. | `string` | n/a | yes |
| <a name="input_tfe_enc_password_arn"></a> [tfe\_enc\_password\_arn](#input\_tfe\_enc\_password\_arn) | Password to protect unseal key and root token of TFE embedded Vault. | `string` | n/a | yes |
| <a name="input_tfe_fdo_release_sequence"></a> [tfe\_fdo\_release\_sequence](#input\_tfe\_fdo\_release\_sequence) | TFE release sequence number to deploy. This is used to retrieve the correct container | `string` | n/a | yes |
| <a name="input_tfe_hostname"></a> [tfe\_hostname](#input\_tfe\_hostname) | FQDN of the TFE deployment. | `string` | n/a | yes |
| <a name="input_tfe_privkey_secret_arn"></a> [tfe\_privkey\_secret\_arn](#input\_tfe\_privkey\_secret\_arn) | ARN of AWS Secrets Manager secret for TFE private key in PEM format and base64 encoded. Required if `tls_bootstrap_type` is `server-path`; otherwise ignored. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID that TFE will be deployed into. | `string` | n/a | yes |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Map of common tags for all taggable AWS resources. | `map(string)` | `{}` | no |
| <a name="input_log_group_name"></a> [log\_group\_name](#input\_log\_group\_name) | Name of CloudWatch Log Group to configure as log forwarding destination. `log_forwarding_enabled` must also be `true`. | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | `"us-east-2"` | no |
| <a name="input_s3_app_bucket_name"></a> [s3\_app\_bucket\_name](#input\_s3\_app\_bucket\_name) | Name of S3 S3 Terraform Enterprise Object Store bucket. | `string` | `""` | no |
| <a name="input_s3_log_bucket_name"></a> [s3\_log\_bucket\_name](#input\_s3\_log\_bucket\_name) | Name of bucket to configure as log forwarding destination. `log_forwarding_enabled` must also be `true`. | `string` | `""` | no |
| <a name="input_ssh_keypair_name"></a> [ssh\_keypair\_name](#input\_ssh\_keypair\_name) | Name of the SSH public key to associate with the TFE instances. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_asg_healthcheck_type"></a> [asg\_healthcheck\_type](#output\_asg\_healthcheck\_type) | Type of health check that is associated with the AWS autoscaling group. |
| <a name="output_asg_name"></a> [asg\_name](#output\_asg\_name) | Name of the AWS autoscaling group that was created during the run. |
| <a name="output_asg_target_group_arns"></a> [asg\_target\_group\_arns](#output\_asg\_target\_group\_arns) | List of the target group ARNs that are used for the AWS autoscaling group |
| <a name="output_launch_template_name"></a> [launch\_template\_name](#output\_launch\_template\_name) | Name of the AWS launch template that was created during the run |
| <a name="output_security_group_ids"></a> [security\_group\_ids](#output\_security\_group\_ids) | List of security groups that have been created during the run. |
| <a name="output_tfe_admin_console_url"></a> [tfe\_admin\_console\_url](#output\_tfe\_admin\_console\_url) | URL of TFE (Replicated) Admin Console based on `route53_failover_fqdn` input. |
| <a name="output_tfe_url"></a> [tfe\_url](#output\_tfe\_url) | URL of TFE application based on `route53_failover_fqdn` input. |
| <a name="output_user_data_script"></a> [user\_data\_script](#output\_user\_data\_script) | base64 decoded user data script that is attached to the launch template |
<!-- END_TF_DOCS -->
  