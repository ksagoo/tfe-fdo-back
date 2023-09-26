# Amazon ElastiCache  


## Purpose
These modules are currently for [hyper-specialized tier partners](https://www.hashicorp.com/partners/find-a-partner?category=systems-integrators), internal use, and HashiCorp Implementation Services. Please reach out in #team-ent-deployment-modules if you want to use this with your customers.


## Overview  
This module will be used to deploy Amazon ElastiCache if a redis cluster is required.  

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
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
| [aws_elasticache_replication_group.replication_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_replication_group) | resource |
| [aws_elasticache_subnet_group.redis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_subnet_group) | resource |
| [aws_security_group.redis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_friendly_name_prefix"></a> [friendly\_name\_prefix](#input\_friendly\_name\_prefix) | Friendly name prefix used for tagging and naming AWS resources. | `string` | n/a | yes |
| <a name="input_product"></a> [product](#input\_product) | Name of the HashiCorp product that will consume this service (tfe, tfefdo, vault, consul, nomad, boundary) | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID that will be used by the workloads. | `string` | n/a | yes |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Map of common tags for all taggable AWS resources. | `map(string)` | `{}` | no |
| <a name="input_redis_enable_encryption_at_rest"></a> [redis\_enable\_encryption\_at\_rest](#input\_redis\_enable\_encryption\_at\_rest) | Boolean to enable encryption at rest on Redis replication group. A `kms_key_arn` is required when set to `true`. | `bool` | `false` | no |
| <a name="input_redis_enable_multi_az"></a> [redis\_enable\_multi\_az](#input\_redis\_enable\_multi\_az) | Boolean for deploying Redis nodes in multiple Availability Zones and enabling automatic failover. | `bool` | `true` | no |
| <a name="input_redis_enable_transit_encryption"></a> [redis\_enable\_transit\_encryption](#input\_redis\_enable\_transit\_encryption) | Boolean to enable transit encryption on the Redis replication group. | `bool` | `true` | no |
| <a name="input_redis_engine"></a> [redis\_engine](#input\_redis\_engine) | Engine that will be provisioned for the elasticache replication group | `string` | `"redis"` | no |
| <a name="input_redis_engine_version"></a> [redis\_engine\_version](#input\_redis\_engine\_version) | Redis version number. | `string` | `"6.2"` | no |
| <a name="input_redis_kms_key_arn"></a> [redis\_kms\_key\_arn](#input\_redis\_kms\_key\_arn) | ARN of KMS key that will be used to encrypt the storage for the database instances. | `string` | `""` | no |
| <a name="input_redis_log_group_name"></a> [redis\_log\_group\_name](#input\_redis\_log\_group\_name) | Name of the Cloud Watch Log Group to be used for Redis Logs. | `string` | `""` | no |
| <a name="input_redis_node_type"></a> [redis\_node\_type](#input\_redis\_node\_type) | Type of Redis node from a compute, memory, and network throughput standpoint. | `string` | `"cache.m5.large"` | no |
| <a name="input_redis_parameter_group_name"></a> [redis\_parameter\_group\_name](#input\_redis\_parameter\_group\_name) | Name of parameter group to associate with the Redis replication group. | `string` | `"default.redis6.x"` | no |
| <a name="input_redis_password"></a> [redis\_password](#input\_redis\_password) | Password (auth token) used to enable transit encryption (TLS) with Redis. | `string` | `""` | no |
| <a name="input_redis_port"></a> [redis\_port](#input\_redis\_port) | Port number the Redis nodes will accept connections on. | `number` | `6379` | no |
| <a name="input_redis_replication_group_description"></a> [redis\_replication\_group\_description](#input\_redis\_replication\_group\_description) | Description that will be associated with the Redis replication group | `string` | `"External Redis Replication Group for TFE Active/Active"` | no |
| <a name="input_redis_security_group_ids"></a> [redis\_security\_group\_ids](#input\_redis\_security\_group\_ids) | List of existing security groups to associate with the Redis replication group. If Active/Active is true and this is default, the one created in the VPC module will be used. | `list(string)` | `[]` | no |
| <a name="input_redis_subnet_group_name"></a> [redis\_subnet\_group\_name](#input\_redis\_subnet\_group\_name) | Name of the existing subnet group for the Redis replication group to use. | `string` | `null` | no |
| <a name="input_redis_subnet_ids"></a> [redis\_subnet\_ids](#input\_redis\_subnet\_ids) | List of subnet IDs to use for Redis replication group subnet group. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_redis_password"></a> [redis\_password](#output\_redis\_password) | Auth token that is used to access the Redis replication group. |
| <a name="output_redis_port"></a> [redis\_port](#output\_redis\_port) | Port that the Redis cluster is listening on. |
| <a name="output_redis_primary_endpoint"></a> [redis\_primary\_endpoint](#output\_redis\_primary\_endpoint) | Address of the endpoint of the primary node in the replication group. |
| <a name="output_redis_replication_group_arn"></a> [redis\_replication\_group\_arn](#output\_redis\_replication\_group\_arn) | ARN of the created Redis replication group. |
| <a name="output_redis_security_group_id"></a> [redis\_security\_group\_id](#output\_redis\_security\_group\_id) | List of security groups that are associated with the Redis replication group. |
| <a name="output_redis_security_group_ids"></a> [redis\_security\_group\_ids](#output\_redis\_security\_group\_ids) | List of security groups that are associated with the Redis replication group. |
| <a name="output_redis_security_group_name"></a> [redis\_security\_group\_name](#output\_redis\_security\_group\_name) | List of security groups that are associated with the Redis replication group. |
| <a name="output_redis_subnet_group_id"></a> [redis\_subnet\_group\_id](#output\_redis\_subnet\_group\_id) | Redis subnet group ID that was created (if one wasn't specified). |
| <a name="output_redis_subnet_group_name"></a> [redis\_subnet\_group\_name](#output\_redis\_subnet\_group\_name) | Redis subnet group that was created (if one wasn't specified). |
<!-- END_TF_DOCS -->
