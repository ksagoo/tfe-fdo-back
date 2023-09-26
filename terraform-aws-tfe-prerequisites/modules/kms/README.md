# AWS Key Management Service  

## Purpose
These modules are currently for [hyper-specialized tier partners](https://www.hashicorp.com/partners/find-a-partner?category=systems-integrators), internal use, and HashiCorp Implementation Services. Please reach out in #team-ent-deployment-modules if you want to use this with your customers.

## Overview  
This module will create a KMS key and alias in the region that it is called.  It provides various input variables to control aspects of the KMS key policy, such as whether or not the **Key Default Policy** is enabled by default, if specific **IAM Users or Roles** should be allowed to use the key for Cryptographic operations, or whether or not **AWS AutoScaling** should have access to use the key as well.  


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=4.55.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=4.55.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_kms_alias.alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_friendly_name_prefix"></a> [friendly\_name\_prefix](#input\_friendly\_name\_prefix) | Friendly name prefix used for tagging and naming AWS resources. | `string` | n/a | yes |
| <a name="input_product"></a> [product](#input\_product) | Name of the HashiCorp product that will consume this service (tfe, tfefdo, vault, consul, nomad, boundary) | `string` | n/a | yes |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Map of common tags for all taggable AWS resources. | `map(string)` | `{}` | no |
| <a name="input_create_multi_region_key"></a> [create\_multi\_region\_key](#input\_create\_multi\_region\_key) | Boolean to enable a multi-region key pair | `bool` | `false` | no |
| <a name="input_kms_allow_asg_to_cmk"></a> [kms\_allow\_asg\_to\_cmk](#input\_kms\_allow\_asg\_to\_cmk) | Boolen to create a KMS CMK Key policy that grants the Service Linked Role AWSServiceRoleForAutoScaling permissions to the CMK. | `bool` | `true` | no |
| <a name="input_kms_asg_role_arn"></a> [kms\_asg\_role\_arn](#input\_kms\_asg\_role\_arn) | ARN of AWS Service Linked role for AWS Autoscaling. | `string` | `""` | no |
| <a name="input_kms_default_policy_enabled"></a> [kms\_default\_policy\_enabled](#input\_kms\_default\_policy\_enabled) | Enables a default policy that allows KMS operations to be defined by IAM | `string` | `true` | no |
| <a name="input_kms_key_deletion_window"></a> [kms\_key\_deletion\_window](#input\_kms\_key\_deletion\_window) | Duration in days to destroy the key after it is deleted. Must be between 7 and 30 days. | `number` | `7` | no |
| <a name="input_kms_key_description"></a> [kms\_key\_description](#input\_kms\_key\_description) | Description that will be attached to the KMS key (if created) | `string` | `"AWS KMS Customer-managed key to encrypt RDS, S3, EBS, etc."` | no |
| <a name="input_kms_key_name"></a> [kms\_key\_name](#input\_kms\_key\_name) | Name that will be added to the KMS key via tags | `string` | `"kms-key"` | no |
| <a name="input_kms_key_usage"></a> [kms\_key\_usage](#input\_kms\_key\_usage) | Intended use of the KMS key that will be created. | `string` | `"ENCRYPT_DECRYPT"` | no |
| <a name="input_kms_key_users_or_roles"></a> [kms\_key\_users\_or\_roles](#input\_kms\_key\_users\_or\_roles) | List of arns for users or roles that should have access to perform Cryptographic Operations with KMS Key | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kms_key_alias"></a> [kms\_key\_alias](#output\_kms\_key\_alias) | The KMS Key Alias |
| <a name="output_kms_key_alias_arn"></a> [kms\_key\_alias\_arn](#output\_kms\_key\_alias\_arn) | The KMS Key Alias arn |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | The KMS key used to encrypt data. |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | The KMS Key ID |
<!-- END_TF_DOCS -->
