# Amazon S3 Module  

# Overview  
This module will be used to establish S3 buckets to be used for the HashiCorp product deployment.  The module utilizes various inputs to control settings that customers may want to customize for their particular environment.  For example, the module allows the user to specify if they want Cross Region Replication, Encryption with a KMS CMK, a logging bucket configuration, etc.  The inputs to create s3 buckets is based on an object map.  Here is a snippet of the map for purposes of demonstration:  

``` hcl
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
      encrypt                             = optional(bool, true)
      bucket_key_enabled                  = optional(bool, true)
      kms_key_arn                         = optional(string)
      is_secondary_region                 = optional(bool, false)
    }), {})
    tfe_app = optional(object({
      create                              = optional(bool, true)
      bucket_name                         = optional(string, "tfe-app-bucket")
      description                         = optional(string, "Object store for TFE")
    ...{output omitted}...
})
 
```  
See the object map definition in `variables.tf` for a full list of supported inputs under each unique key.  To provide your own values, override the object map, or ensure that the `create` parameter is set to false to skip that specific bucket creation.

## Note
This module defaults to an empty map for the `s3_buckets` variable. This is because it is being used for our Vault, Consul, and Terraform Enterprise installers currently. The defaults are being controlled by their designated wrapper modules. An example of this is when doing to the TFE prereqs deployment, the module that calls this one has `bootstrap`,`tfe_app`,and `logging` maps defaulted and the user provides overrides to those. When someone is doing the Vault prereqs, only `vault_snapshots` will be defaulted as a populated map.

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
| [aws_iam_policy.s3_replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_attachment.s3_replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_role.s3_replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_s3_bucket.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_public_access_block.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_replication_configuration.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_replication_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_iam_policy_document.s3_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_friendly_name_prefix"></a> [friendly\_name\_prefix](#input\_friendly\_name\_prefix) | Friendly name prefix used for tagging and naming AWS resources. | `string` | n/a | yes |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Map of common tags for all taggable AWS resources. | `map(string)` | `{}` | no |
| <a name="input_s3_buckets"></a> [s3\_buckets](#input\_s3\_buckets) | Object Map that contains the configuration for the S3 logging and bootstrap bucket configuration. | <pre>object({<br>    bootstrap = optional(object({<br>      create                              = optional(bool, true)<br>      bucket_name                         = optional(string, "tfe-bootstrap-bucket")<br>      description                         = optional(string, "Bootstrap bucket for the TFE instances and install")<br>      versioning                          = optional(bool, true)<br>      force_destroy                       = optional(bool, false)<br>      replication                         = optional(bool)<br>      replication_destination_bucket_arn  = optional(string)<br>      replication_destination_kms_key_arn = optional(string)<br>      replication_destination_region      = optional(string)<br>      encrypt                             = optional(bool, true)<br>      bucket_key_enabled                  = optional(bool, true)<br>      kms_key_arn                         = optional(string)<br>      sse_s3_managed_key                  = optional(bool, false)<br>      is_secondary_region                 = optional(bool, false)<br>    }))<br>    tfe_app = optional(object({<br>      create                              = optional(bool, true)<br>      bucket_name                         = optional(string, "tfe-app-bucket")<br>      description                         = optional(string, "Object store for TFE")<br>      versioning                          = optional(bool, true)<br>      force_destroy                       = optional(bool, false)<br>      replication                         = optional(bool)<br>      replication_destination_bucket_arn  = optional(string)<br>      replication_destination_kms_key_arn = optional(string)<br>      replication_destination_region      = optional(string)<br>      encrypt                             = optional(bool, true)<br>      bucket_key_enabled                  = optional(bool, true)<br>      kms_key_arn                         = optional(string)<br>      sse_s3_managed_key                  = optional(bool, false)<br>      is_secondary_region                 = optional(bool, false)<br>    }))<br>    logging = optional(object({<br>      create                              = optional(bool, true)<br>      bucket_name                         = optional(string, "hashicorp-log-bucket")<br>      versioning                          = optional(bool, false)<br>      force_destroy                       = optional(bool, false)<br>      replication                         = optional(bool, false)<br>      replication_destination_bucket_arn  = optional(string)<br>      replication_destination_kms_key_arn = optional(string)<br>      replication_destination_region      = optional(string)<br>      encrypt                             = optional(bool, true)<br>      bucket_key_enabled                  = optional(bool, true)<br>      kms_key_arn                         = optional(string)<br>      sse_s3_managed_key                  = optional(bool, false)<br>      lifecycle_enabled                   = optional(bool, true)<br>      lifecycle_expiration_days           = optional(number, 7)<br>      is_secondary_region                 = optional(bool, false)<br>    }))<br>    snapshot = optional(object({<br>      create                              = optional(bool, true)<br>      bucket_name                         = optional(string, "snapshot-bucket")<br>      description                         = optional(string, "Storage location for HashiCorp snapshots that will be exported")<br>      versioning                          = optional(bool, true)<br>      force_destroy                       = optional(bool, false)<br>      replication                         = optional(bool, false)<br>      replication_destination_bucket_arn  = optional(string)<br>      replication_destination_kms_key_arn = optional(string)<br>      replication_destination_region      = optional(string)<br>      encrypt                             = optional(bool, true)<br>      bucket_key_enabled                  = optional(bool, true)<br>      kms_key_arn                         = optional(string)<br>      sse_s3_managed_key                  = optional(bool, false)<br>    }))<br>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_s3_bootstrap_bucket_arn"></a> [s3\_bootstrap\_bucket\_arn](#output\_s3\_bootstrap\_bucket\_arn) | ARN of S3 'bootstrap' bucket |
| <a name="output_s3_bootstrap_bucket_name"></a> [s3\_bootstrap\_bucket\_name](#output\_s3\_bootstrap\_bucket\_name) | Name of S3 'bootstrap' bucket. |
| <a name="output_s3_bucket_arn_list"></a> [s3\_bucket\_arn\_list](#output\_s3\_bucket\_arn\_list) | A list of the ARNs for the buckets that have been configured |
| <a name="output_s3_log_bucket_arn"></a> [s3\_log\_bucket\_arn](#output\_s3\_log\_bucket\_arn) | Name of S3 'logging' bucket. |
| <a name="output_s3_log_bucket_name"></a> [s3\_log\_bucket\_name](#output\_s3\_log\_bucket\_name) | Name of S3 'logging' bucket. |
| <a name="output_s3_replication_iam_role_arn"></a> [s3\_replication\_iam\_role\_arn](#output\_s3\_replication\_iam\_role\_arn) | ARN of IAM Role for S3 replication. |
| <a name="output_s3_replication_policy"></a> [s3\_replication\_policy](#output\_s3\_replication\_policy) | Replication policy of the S3 'bootstrap' bucket. |
| <a name="output_s3_snapshot_bucket_arn"></a> [s3\_snapshot\_bucket\_arn](#output\_s3\_snapshot\_bucket\_arn) | ARN of S3 HashiCorp Enterprise Object Store bucket for Snapshots. |
| <a name="output_s3_snapshot_bucket_name"></a> [s3\_snapshot\_bucket\_name](#output\_s3\_snapshot\_bucket\_name) | Name of S3 HashiCorp Enterprise Object Store bucket for Snapshots. |
| <a name="output_s3_tfe_app_bucket_arn"></a> [s3\_tfe\_app\_bucket\_arn](#output\_s3\_tfe\_app\_bucket\_arn) | ARN of S3 Terraform Enterprise Object Store bucket. |
| <a name="output_s3_tfe_app_bucket_name"></a> [s3\_tfe\_app\_bucket\_name](#output\_s3\_tfe\_app\_bucket\_name) | Name of S3 Terraform Enterprise Object Store bucket. |
<!-- END_TF_DOCS -->
