#------------------------------------------------------------------------------
# Common
#------------------------------------------------------------------------------
variable "friendly_name_prefix" {
  type        = string
  description = "String value for friendly name prefix for AWS resource names."
}

variable "common_tags" {
  type        = map(string)
  description = "Map of common tags for taggable AWS resources."
  default     = {}
}

variable "cloud" {
  type        = string
  description = "Name of the cloud we are provisioning on. This is used for templating functions and is default to AWS for this module."
  default     = "aws"
}

#------------------------------------------------------------------------------
# TFE Installation Settings
#------------------------------------------------------------------------------
variable "license_secret_arn" {
  type        = string
  description = "ARN of the TFE license that is stored within secrets manager."
}

variable "permit_all_egress" {
  type        = bool
  description = "Whether broad (0.0.0.0/0) egress should be permitted on cluster nodes. If disabled, additional rules must be added to permit HTTP(S) and other necessary network access."
}

variable "tfe_hostname" {
  type        = string
  description = "Hostname/FQDN of TFE instance. This name should resolve to the load balancer DNS name and will be how users and systems access TFE."
}

variable "tfe_config_directory" {
  type        = string
  description = "Directory on the EC2 instance where the configuration for TFE will be stored."
  default     = "/etc/tfe"
}

variable "replicated_bundle_path" {
  type        = string
  description = "Path to Replicated tarball (`replicated.tar.gz`) stored in `tfe_bootstrap_bucket`. Path should start with `s3://`. Only specify if `airgap_install` is `true`."
  default     = ""

  validation {
    condition     = length(var.replicated_bundle_path) > 5 && substr(var.replicated_bundle_path, 0, 5) == "s3://" || var.replicated_bundle_path == ""
    error_message = "Value must start with \"s3://\"."
  }
}

variable "tfe_fdo_release_sequence" {
  type        = any
  description = "TFE release sequence to use during deployment. This specifies which TFE version to install."
  default     = "v202309-1"
}

variable "tfe_release_sequence" {
  type        = any
  description = "TFE release sequence number within Replicated. This specifies which TFE version to install for an `online` install. Ignored if `airgap_install` is `true`."
  default     = "733"
}

variable "tls_bootstrap_type" {
  type        = string
  description = "Defines where to terminate TLS/SSL. Set to `self-signed` to terminate at the load balancer, or `server-path` to terminate at the instance-level."
  default     = "self-signed"

  validation {
    condition     = contains(["self-signed", "server-path"], var.tls_bootstrap_type)
    error_message = "Supported values are `self-signed` or `server-path`."
  }
}

variable "remove_import_settings_from" {
  type        = bool
  description = "Replicated setting to automatically remove the `/etc/tfe-settings.json` file (referred to as `ImportSettingsFrom` by Replicated) after installation."
  default     = false
}

variable "install_docker_before" {
  type        = bool
  description = "Boolean to install docker before TFE install script is called."
  default     = false
}

variable "docker_version" {
  type        = string
  description = "Version of docker to install as a part of the pre-reqs"
  default     = "24.0.4"
}


variable "capacity_concurrency" {
  type        = string
  description = "Total concurrent Terraform Runs (Plans/Applies) allowed within TFE."
  default     = "10"
}

variable "capacity_memory" {
  type        = string
  description = "Maxium amount of memory (MB) that a Terraform Run (Plan/Apply) can consume within TFE."
  default     = "512"
}

variable "lifecycle_hook_timeout" {
  type        = number
  default     = 600
  description = "Duration in seconds that the lifecycle hook will wait for a timeout."
}

#------------------------------------------------------------------------------
# TFE AirGap Settings
#------------------------------------------------------------------------------
variable "airgap_install" {
  type        = bool
  description = "Boolean for TFE installation method to be airgap."
  default     = false
}

variable "pkg_repos_reachable_with_airgap" {
  type        = bool
  description = "Boolean to install prereq software dependencies if airgapped. Only valid when `airgap_install` is `true`."
  default     = false
}

variable "tfe_airgap_bundle_path" {
  type        = string
  description = "Path to TFE airgap bundle stored in `tfe_bootstrap_bucket`. Path should start with `s3://`. Only specify if `airgap_install` is `true`."
  default     = ""

  validation {
    condition     = length(var.tfe_airgap_bundle_path) > 5 && substr(var.tfe_airgap_bundle_path, 0, 5) == "s3://" || var.tfe_airgap_bundle_path == ""
    error_message = "Value must start with \"s3://\"."
  }
}


#------------------------------------------------------------------------------
# TFE Secrets
#------------------------------------------------------------------------------
variable "tfe_cert_secret_arn" {
  type        = string
  description = "ARN of AWS Secrets Manager secret for TFE server certificate in PEM format. Required if `tls_bootstrap_type` is `server-path`; otherwise ignored."
  default     = ""
}

variable "tfe_privkey_secret_arn" {
  type        = string
  description = "ARN of AWS Secrets Manager secret for TFE private key in PEM format and base64 encoded. Required if `tls_bootstrap_type` is `server-path`; otherwise ignored."
  default     = ""
}

variable "ca_bundle_secret_arn" {
  type        = string
  description = "ARN of AWS Secrets Manager secret for private/custom CA bundles. New lines must be replaced by `\n` character prior to storing as a plaintext secret."
  default     = ""
}

variable "console_password_arn" {
  type        = string
  description = "Password to unlock TFE Admin Console accessible via port 8800. Specify `aws_secretsmanager` to retrieve from AWS Secrets Manager via `tfe_install_secrets_arn` input."
  default     = "aws_secretsmanager"
}

variable "enc_password_arn" {
  type        = string
  description = "Password to protect unseal key and root token of TFE embedded Vault. Specify `aws_secretsmanager` to retrieve from AWS Secrets Manager via `tfe_install_secrets_arn` input."
  default     = "aws_secretsmanager"
}

variable "tfe_iact_settings" {
  type = object({
    iact_subnets         = optional(string, "")
    iact_trusted_proxies = optional(string, "")
    iact_time_limit      = optional(string, "60")
  })
  description = <<DESC
  "Object map for the TFE IACT Settings used with TFE FDO
  `iact_subnets` is a list of IPs in CIDR format eg. "10.0.0.0/24,10.1.1.1/24" that can request an initial admin token
  `iact_trusted_proxies` is a list of proxy IPs that allow for retrieval of the initial admin token
  `iact_time_limit` is the duration in which the retreival is allowed"
  DESC
  default     = {}
}




#------------------------------------------------------------------------------
# TFE Worker Image Settings
#------------------------------------------------------------------------------
variable "tbw_image" {
  type        = string
  description = "Terraform Build Worker container image to use. Set this to `custom_image` to use alternative container image."
  default     = "default_image"

  validation {
    condition     = contains(["default_image", "custom_image"], var.tbw_image)
    error_message = "Supported values are `default_image` or `custom_image`."
  }
}

variable "custom_tbw_ecr_repo" {
  type        = string
  description = "Name of AWS Elastic Container Registry (ECR) Repository where custom Terraform Build Worker (tbw) image exists. Only specify if `tbw_image` is set to `custom_image`."
  default     = ""
}

variable "custom_tbw_image_tag" {
  type        = string
  description = "Tag of custom Terraform Build Worker (tbw) image. Examples: `v1`, `latest`. Only specify if `tbw_image` is set to `custom_image`."
  default     = "latest"
}

#------------------------------------------------------------------------------
# TFE Metrics and Logging Settings
#------------------------------------------------------------------------------
variable "enable_metrics_collection" {
  type        = bool
  description = "Boolean to enable internal TFE metrics collection."
  default     = true
}

variable "metrics_endpoint_enabled" {
  type        = bool
  description = "Boolean to enable the TFE metrics endpoint."
  default     = false
}

variable "metrics_endpoint_port_http" {
  type        = number
  description = "Defines the TCP port on which HTTP metrics requests will be handled."
  default     = 9090
}

variable "metrics_endpoint_port_https" {
  type        = number
  description = "Defines the TCP port on which HTTPS metrics requests will be handled."
  default     = 9091
}

variable "metrics_endpoint_allow_cidr" {
  description = "The CIDR to allow access to the TFE metrics endpoint."
  type        = list(string)
  default     = null
}

variable "metrics_endpoint_allow_sg" {
  description = "The Security Groups to allow access to the TFE metrics endpoint."
  type        = string
  default     = null
}

variable "log_forwarding_enabled" {
  type        = bool
  description = "Boolean to enable TFE log forwarding at the application level."
  default     = false
}

variable "log_forwarding_type" {
  type        = string
  description = "Which type of log forwarding to configure. For any of these,`var.log_forwarding_enabled` must be set to `true`. For  S3, specify `s3` and supply a value for `var.s3_log_bucket_name`, for Cloudwatch specify `cloudwatch` and `var.cloudwatch_log_group_name`, for custom, specify `custom` and supply a valid fluentbit config in `var.custom_fluent_bit_config`."
  default     = "s3"

  validation {
    condition     = contains(["s3", "cloudwatch", "custom"], var.log_forwarding_type)
    error_message = "Supported values are `s3`, `cloudwatch` or `custom`."
  }
}

variable "custom_fluent_bit_config" {
  type        = string
  description = "A custom FluentBit config for TFE logging."
  default     = null
}

#------------------------------------------------------------------------------
# TFE Security Settings
#------------------------------------------------------------------------------
variable "force_tls" {
  type        = bool
  description = "Boolean to require all internal TFE application traffic to use HTTPS by sending a 'Strict-Transport-Security' header value in responses, and marking cookies as secure. Only enable if `tls_bootstrap_type` is `server-path`."
  default     = false
}

variable "restrict_worker_metadata_access" {
  type        = bool
  description = "Boolean to block Terraform build worker containers from being able to access the EC2 instance metadata endpoint."
  default     = false
}

#------------------------------------------------------------------------------
# TFE Proxy Settings
#------------------------------------------------------------------------------
variable "http_proxy" {
  type        = string
  description = "Proxy address to configure for TFE to use for outbound connections/requests."
  default     = ""
}

variable "extra_no_proxy" {
  type        = string
  description = "A comma-separated string of hostnames or IP addresses to add to the TFE no_proxy list. Only specify if a value for `http_proxy` is also specified."
  default     = ""
}

variable "hairpin_addressing" {
  type        = bool
  description = "Boolean to enable TFE services to direct requests to the servers' internal IP address rather than the TFE hostname/FQDN. Only enable if `tls_bootstrap_type` is `server-path`."
  default     = false
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
# Network
#------------------------------------------------------------------------------
variable "vpc_id" {
  type        = string
  description = "VPC ID that TFE will be deployed into."
}

variable "ec2_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to use for the EC2 instance. Private subnets is the best practice."
}

variable "lb_type" {
  type        = string
  description = "String indicating whether the load balancer deployed is an Application Load Balancer (alb) or Network Load Balancer (nlb)."
  default     = "application"
}

variable "lb_scheme" {
  type        = string
  description = "Load balancer exposure. Specify `external` if load balancer is to be public/external-facing, or `internal` if load balancer is to be private/internal-facing."
  default     = "external"

  validation {
    condition     = var.lb_scheme == "external" || var.lb_scheme == "internal"
    error_message = "Supported values are `external` or `internal`."
  }
}

variable "lb_security_group_id" {
  type        = string
  description = "Security Group ID for the Load Balancer"
  default     = ""
}

variable "lb_tg_arns" {
  type        = list(any)
  default     = []
  description = "List of Target Group ARNs associated with the TFE Load Balancer"
}

variable "cloudwatch_log_group_name" {
  type        = string
  description = "Name of CloudWatch Log Group to configure as log forwarding destination. `log_forwarding_enabled` must also be `true`."
  default     = ""
}

#------------------------------------------------------------------------------
# Security
#------------------------------------------------------------------------------
variable "ingress_cidr_443_allow" {
  type        = list(string)
  description = "List of CIDR ranges to allow ingress traffic on port 443 to TFE server or load balancer."
  default     = ["0.0.0.0/0"]
}

variable "ingress_cidr_8800_allow" {
  type        = list(string)
  description = "List of CIDR ranges to allow TFE Replicated admin console (port 8800) traffic ingress to TFE server or load balancer."
  default     = null
}

variable "ingress_cidr_22_allow" {
  type        = list(string)
  description = "List of CIDR ranges to allow SSH ingress to TFE EC2 instance (i.e. bastion host IP, workstation IP, etc.)."
  default     = []
}

variable "kms_key_arn" {
  type        = string
  description = "ARN of KMS key to encrypt TFE RDS, S3, EBS, and Redis resources."
  default     = ""
}

variable "ssh_key_pair" {
  type        = string
  description = "Name of existing SSH key pair to attach to TFE EC2 instance."
  default     = ""
}

variable "iam_instance_profile" {
  type        = string
  default     = ""
  description = "Name of AWS IAM Instance Profile for TFE EC2 Instance"
}

variable "launch_template_sg_ids" {
  type        = list(string)
  default     = []
  description = "List of additional Security Group IDs to associate with the AWS Launch Template"
}

#------------------------------------------------------------------------------
# Compute
#------------------------------------------------------------------------------
variable "os_distro" {
  type        = string
  description = "Linux OS distribution for TFE EC2 instance. Choose from `ubuntu`, `rhel`, `centos`."
  default     = "ubuntu"

  validation {
    condition     = contains(["ubuntu", "rhel", "centos"], var.os_distro)
    error_message = "Supported values are `ubuntu`, `rhel` or `centos`."
  }
}

variable "asg_instance_count" {
  type        = number
  description = "Desired number of EC2 instances to run in Autoscaling Group. Leave at `1` unless Active/Active is enabled."
  default     = 1
}

variable "asg_max_size" {
  type        = number
  description = "Max number of EC2 instances to run in Autoscaling Group. Increase after Active/Active is enabled."
  default     = 1
}

variable "asg_min_size" {
  type        = number
  description = "Min number of EC2 instances to run in Autoscaling Group. Increase after Active/Active is enabled."
  default     = 1
}

variable "asg_health_check_grace_period" {
  type        = number
  description = "The amount of time to wait for a new TFE instance to be healthy. If this threshold is breached, the ASG will terminate the instance and launch a new one."
  default     = 900
}

variable "asg_capacity_timeout" {
  type        = string
  description = "Maximum duration that Terraform should wait for ASG instances to be healthy before timing out"
  default     = "10m"
}

variable "asg_custom_role_arn" {
  type        = string
  description = "Custom role ARN that will be assigned to the autoscaling group (if specified). Defaults to the AWS native role."
  default     = null
}

variable "asg_hook_value" {
  type        = string
  description = "Value for the tag that is associated with the launch template. This is used for the lifecycle hook checkin."
}

variable "asg_health_check_type" {
  type        = string
  description = "Health check type for the ASG to use when determining if an endpoint is healthy"
  default     = "ELB"
  validation {
    condition     = contains(["ELB", "EC2"], var.asg_health_check_type)
    error_message = "Value must be \"ELB\" or \"EC2\"."
  }
}

variable "ami_id" {
  type        = string
  description = "Custom AMI ID for TFE EC2 Launch Template. If specified, value of `os_distro` must coincide with this custom AMI OS distro."
  default     = null

  validation {
    condition     = try((length(var.ami_id) > 4 && substr(var.ami_id, 0, 4) == "ami-"), var.ami_id == null)
    error_message = "The ami_id value must start with \"ami-\"."
  }
}

variable "instance_size" {
  type        = string
  description = "EC2 instance type for TFE Launch Template."
  default     = "m5.xlarge"
}

variable "ebs_is_encrypted" {
  type        = bool
  description = "Boolean for encrypting the root block device of the TFE EC2 instance(s)."
  default     = true
}

# For now only allowing gp3 which is cheaper and faster. There is an issue with the AWS provider switching between gp2 and gp3
# as the iops and throughput are not being set to null when they are not needed for gp2 when switching between them.
variable "ebs_volume_type" {
  type        = string
  description = "The volume type. Choose from `gp3`."
  default     = "gp3"

  validation {
    condition     = contains(["gp3", ], var.ebs_volume_type)
    error_message = "Supported values are `gp3`."
  }
}

variable "ebs_volume_size" {
  type        = number
  description = "The size of the boot volume for TFE type. Must be at least `50` GB."
  default     = 50

  validation {
    condition = (
      var.ebs_volume_size >= 50 &&
      var.ebs_volume_size <= 16000
    )
    error_message = "The ebs volume must be greater `50` GB and lower than `16000` GB (16TB)."
  }
}

variable "ebs_throughput" {
  type        = number
  description = "The throughput to provision for a `gp3` volume in MB/s. Must be at least `125` MB/s."
  default     = 125

  validation {
    condition = (
      var.ebs_throughput >= 125 &&
      var.ebs_throughput <= 1000
    )
    error_message = "The throughput must be at least `125` MB/s and lower than `1000` MB/s."
  }
}

variable "ebs_iops" {
  type        = number
  description = "The amount of IOPS to provision for a `gp3` volume. Must be at least `3000`."
  default     = 3000

  validation {
    condition = (
      var.ebs_iops >= 3000 &&
      var.ebs_iops <= 16000
    )
    error_message = "The IOPS must be at least `3000` GB and lower than `16000` (16TB)."
  }
}

#------------------------------------------------------------------------------
# External Services - RDS
#------------------------------------------------------------------------------
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

variable "db_database_name" {
  type        = string
  description = "Name of database that will be created (if specified) or consumed by TFE."
  default     = "tfe"
}

variable "db_port" {
  type        = string
  description = "Port that the Postgres instance is listening on."
  default     = "5432"
}

variable "db_cluster_endpoint" {
  description = "Writer endpoint for the cluster"
  type        = string
  default     = ""
}

#------------------------------------------------------------------------------
# Active/Active - Redis
#------------------------------------------------------------------------------
variable "enable_active_active" {
  type        = bool
  description = "Boolean to enable TFE Active/Active and in turn deploy Redis cluster."
  default     = false
}

variable "redis_port" {
  type        = number
  description = "Port number the Redis nodes will accept connections on."
  default     = 6379
}

variable "redis_password" {
  type        = string
  description = "Password (auth token) used to enable transit encryption (TLS) with Redis."
  default     = ""
}

variable "redis_host" {
  type        = string
  description = "Redis of the primary node for the Redis configuration "
  default     = ""
}

variable "redis_security_group_id" {
  type        = string
  description = "Existing security group ID that is attatched to the redis cluster. This will be used when adding rules to access the cluster from the TFE instances."
  default     = ""
}

#------------------------------------------------------------------------------
# Generic Init Script Variables
#------------------------------------------------------------------------------

variable "product" {
  type        = string
  description = "Name of the HashiCorp product that will be installed (tfe, tfefdo, vault, consul)"
  validation {
    condition     = contains(["tfe", "tfefdo", "vault", "consul"], var.product)
    error_message = "`var.product` must be \"tfe\", \"tfefdo\", \"vault\", or \"consul\"."
  }
  default = "tfe"
}

variable "log_path" {
  type        = string
  description = "Log path glob pattern to capture log files with logging agent"
  default     = "/var/log/*"
}

variable "cloudwatch_retention_in_days" {
  type        = number
  description = "Days to retain CloudWatch logs"
  default     = 14
}