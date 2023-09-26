variable "region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-2"
}

variable "friendly_name_prefix" {
  type        = string
  description = "Friendly name prefix used for tagging and naming AWS resources."
}

variable "common_tags" {
  type        = map(string)
  description = "Map of common tags for all taggable AWS resources."
  default     = {}
}
#------------------------------------------------------------------------------
# Networking
#------------------------------------------------------------------------------
variable "vpc_id" {
  type        = string
  description = "VPC ID that TFE will be deployed into."
}

variable "ec2_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to use for the EC2 instance. Private subnets is the best practice."
}

#------------------------------------------------------------------------------
# Loadbalancing
#------------------------------------------------------------------------------
variable "lb_type" {
  type        = string
  description = "String indicating whether the load balancer deployed is an Application Load Balancer (alb) or Network Load Balancer (nlb)."
}

variable "lb_tg_arns" {
  type        = list(any)
  description = "List of Target Group ARNs associated with the TFE Load Balancer"
}

variable "lb_security_group_id" {
  type        = string
  description = "Security Group ID for the Load Balancer"
}


#------------------------------------------------------------------------------
# Secret Manager
#------------------------------------------------------------------------------

variable "tfe_cert_secret_arn" {
  type        = string
  description = "ARN of AWS Secrets Manager secret for TFE server certificate in PEM format. Required if `tls_bootstrap_type` is `server-path`; otherwise ignored."
}

variable "ca_bundle_secret_arn" {
  type        = string
  description = "ARN of AWS Secrets Manager secret for private/custom CA bundles. New lines must be replaced by `\n` character prior to storing as a plaintext secret."
}


variable "tfe_privkey_secret_arn" {
  type        = string
  description = "ARN of AWS Secrets Manager secret for TFE private key in PEM format and base64 encoded. Required if `tls_bootstrap_type` is `server-path`; otherwise ignored."
}

variable "license_secret_arn" {
  type        = string
  description = "ARN of the TFE license that is stored within secrets manager."
}

variable "tfe_console_password_arn" {
  type        = string
  description = "Password to unlock TFE Admin Console accessible via port 8800."
}

variable "tfe_enc_password_arn" {
  type        = string
  description = "Password to protect unseal key and root token of TFE embedded Vault."
}


#------------------------------------------------------------------------------
# Database
#------------------------------------------------------------------------------
variable "db_database_name" {
  type        = string
  description = "Name of database that will be created (if specified) or consumed by TFE."
}

variable "db_username" {
  type        = string
  description = "Username for the DB user."
}

variable "db_password" {
  type        = string
  description = "Password for the DB user."
}

variable "db_cluster_endpoint" {
  description = "Writer endpoint for the database cluster."
  type        = string
}

#------------------------------------------------------------------------------
# Redis
#------------------------------------------------------------------------------
variable "redis_password" {
  type        = string
  description = "Password for the redis instance."
}

variable "redis_host" {
  type        = string
  description = "Endpoint url for the Redis replication group that TFE should connect to."
}

variable "redis_security_group_id" {
  type        = string
  description = "Existing security group ID that is attatched to the redis cluster. This will be used when adding rules to access the cluster from the TFE instances."
}

#------------------------------------------------------------------------------
# TFE Configuration
#------------------------------------------------------------------------------
variable "tfe_active_active" {
  description = "Boolean that determines if the pre-requisites for an active active deployment of TFE will be deployed."
  type        = bool
}

variable "tfe_fdo_release_sequence" {
  type        = string
  description = "TFE release sequence number to deploy. This is used to retrieve the correct container"
}

variable "tfe_hostname" {
  type        = string
  description = "FQDN of the TFE deployment."
}

variable "ssh_keypair_name" {
  type        = string
  description = "Name of the SSH public key to associate with the TFE instances."
  default     = null
}

variable "asg_hook_value" {
  type        = string
  description = "Value for the tag that is associated with the launch template. This is used for the lifecycle hook checkin."
}

#------------------------------------------------------------------------------
# KMS
#------------------------------------------------------------------------------

variable "kms_key_arn" {
  type        = string
  description = "ARN of KMS key to encrypt TFE RDS, S3, EBS, and Redis resources."
}

#------------------------------------------------------------------------------
# IAM
#------------------------------------------------------------------------------

variable "iam_profile_name" {
  type        = string
  description = "Name of AWS IAM Instance Profile for TFE EC2 Instance"
}

#------------------------------------------------------------------------------
# S3
#------------------------------------------------------------------------------

variable "s3_app_bucket_name" {
  type        = string
  description = "Name of S3 S3 Terraform Enterprise Object Store bucket."
  default     = ""
}

variable "s3_log_bucket_name" {
  type        = string
  description = "Name of bucket to configure as log forwarding destination. `log_forwarding_enabled` must also be `true`."
  default     = ""
}

#------------------------------------------------------------------------------
# Logging
#------------------------------------------------------------------------------

variable "log_group_name" {
  type        = string
  description = "Name of CloudWatch Log Group to configure as log forwarding destination. `log_forwarding_enabled` must also be `true`."
  default     = ""
}
