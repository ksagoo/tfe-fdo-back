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

variable "vpc_enable_ssm" {
  type        = bool
  description = "Boolean that when true will create a security group allowing port 443 to the private_subnets within the VPC (if create_vpc is true)"
}

variable "iam_resources" {
  type = object({
    bucket_arns             = optional(list(string), [])
    kms_key_arns            = optional(list(string), [])
    secret_manager_arns     = optional(list(string), [])
    log_group_arn           = optional(string, "")
    log_forwarding_enabled  = optional(bool, true)
    role_name               = optional(string, "deployment-role")
    policy_name             = optional(string, "deployment-policy")
    ssm_enable              = optional(bool, false)
    custom_tbw_ecr_repo_arn = optional(string, "")
  })
  description = "A list of objects for to be referenced in an IAM policy for the instance.  Each is a list of strings that reference infra related to the install"
}

variable "db_database_name" {
  type        = string
  description = "Name of database that will be created (if specified) or consumed by TFE."
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

variable "ssh_public_key" {
  type        = string
  description = "Public key material for TFE SSH Key Pair."
  default     = null
}

variable "create_ssh_keypair" {
  type        = bool
  description = "Boolean to deploy TFE SSH key pair. This does not create the private key, it only creates the key pair with a provided public key."
  default     = false
}

variable "create_redis_replication_group" {
  description = "Boolean that determines if the pre-requisites for an active active deployment of TFE will be deployed."
  type        = bool
}

variable "tfe_active_active" {
  description = "Boolean that determines if the pre-requisites for an active active deployment of TFE will be deployed."
  type        = bool
}

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
      generate    = optional(bool, false)
    }), {})
    tfe_enc_password = optional(object({
      name        = optional(string, "enc-password")
      description = optional(string, "Encryption password used in the TFE installation")
      data        = optional(string, null)
      generate    = optional(bool, false)
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

variable "route53_zone_name" {
  type        = string
  description = "Route 53 public zone name"
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

variable "redis_password" {
  type        = string
  description = "Password for the redis instance."
  default     = null
}
