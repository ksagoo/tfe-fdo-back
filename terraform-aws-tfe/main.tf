
data "aws_region" "current" {}


data "aws_ecr_repository" "custom_tbw_image" {
  count = var.custom_tbw_ecr_repo != "" ? 1 : 0

  name = var.custom_tbw_ecr_repo
}

#------------------------------------------------------------------------------
# AMI
#------------------------------------------------------------------------------
data "aws_ami" "ubuntu" {
  count = var.os_distro == "ubuntu" && var.ami_id == null ? 1 : 0

  owners      = ["099720109477", "513442679011"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_ami" "rhel" {
  count = var.os_distro == "rhel" && var.ami_id == null ? 1 : 0

  owners      = ["309956199498"]
  most_recent = true

  filter {
    name   = "name"
    values = ["RHEL-7.*_HVM-*-x86_64-0-Hourly2-GP2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_ami" "centos" {
  count = var.os_distro == "centos" && var.ami_id == null ? 1 : 0

  owners      = ["679593333241"]
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

#------------------------------------------------------------------------------
# Launch Template
#------------------------------------------------------------------------------
locals {
  image_id_list    = tolist([var.ami_id, join("", data.aws_ami.ubuntu[*].image_id), join("", data.aws_ami.rhel[*].image_id), join("", data.aws_ami.centos[*].image_id)])
  root_device_name = lookup({ "ubuntu" = "/dev/sda1", "rhel" = "/dev/sda1", "centos" = "/dev/sda1" }, var.os_distro, "/dev/sda1")

  custom_image_tag = var.custom_tbw_ecr_repo != "" ? "${data.aws_ecr_repository.custom_tbw_image[0].repository_url}:${var.custom_tbw_image_tag}" : "hashicorp/build-worker:now"
}

locals {
  fluent_bit_cloudwatch_args = {
    region               = data.aws_region.current.name
    cloudwatch_log_group = var.cloudwatch_log_group_name
  }
  fluent_bit_cloudwatch_config = var.log_forwarding_type == "cloudwatch" ? (templatefile("${path.module}/templates/fluent-bit-cloudwatch.conf.tpl", local.fluent_bit_cloudwatch_args)) : ""

  fluent_bit_s3_args = {
    region        = data.aws_region.current.name
    s3_log_bucket = var.s3_log_bucket_name
  }
  fluent_bit_s3_config = var.log_forwarding_type == "s3" ? (templatefile("${path.module}/templates/fluent-bit-s3.conf.tpl", local.fluent_bit_s3_args)) : ""

  fluent_bit_custom_config = var.log_forwarding_type == "custom" ? var.custom_fluent_bit_config : ""

  fluent_bit_config = join("", [local.fluent_bit_cloudwatch_config, local.fluent_bit_s3_config, local.fluent_bit_custom_config])
}

locals {
  user_data_args = var.product == "tfe" ? {
    airgap_install                  = var.airgap_install
    pkg_repos_reachable_with_airgap = var.pkg_repos_reachable_with_airgap
    install_docker_before           = var.install_docker_before
    replicated_bundle_path          = var.replicated_bundle_path
    tfe_airgap_bundle_path          = var.tfe_airgap_bundle_path
    license_secret_arn              = var.license_secret_arn
    tfe_release_sequence            = var.tfe_release_sequence
    tls_bootstrap_type              = var.tls_bootstrap_type
    cert_secret_arn                 = var.tfe_cert_secret_arn
    privkey_secret_arn              = var.tfe_privkey_secret_arn
    ca_bundle_secret_arn            = var.ca_bundle_secret_arn
    console_password_arn            = var.console_password_arn
    enc_password_arn                = var.enc_password_arn
    config_directory                = var.tfe_config_directory
    remove_import_settings_from     = var.remove_import_settings_from
    http_proxy                      = var.http_proxy
    extra_no_proxy                  = var.extra_no_proxy
    hairpin_addressing              = var.hairpin_addressing ? 1 : 0
    tfe_hostname                    = var.tfe_hostname
    tbw_image                       = var.tbw_image
    custom_tbw_ecr_repo_uri         = var.custom_tbw_ecr_repo != "" ? data.aws_ecr_repository.custom_tbw_image[0].repository_url : ""
    custom_image_tag                = local.custom_image_tag
    capacity_concurrency            = var.capacity_concurrency
    capacity_memory                 = var.capacity_memory
    enable_metrics_collection       = var.enable_metrics_collection ? 1 : 0
    metrics_endpoint_enabled        = var.metrics_endpoint_enabled ? 1 : 0
    metrics_endpoint_port_http      = var.metrics_endpoint_port_http
    metrics_endpoint_port_https     = var.metrics_endpoint_port_https
    force_tls                       = var.force_tls ? 1 : 0
    restrict_worker_metadata_access = var.restrict_worker_metadata_access ? 1 : 0
    kms_key_arn                     = var.kms_key_arn
    s3_app_bucket_name              = var.s3_app_bucket_name
    region                          = data.aws_region.current.name
    s3_app_bucket_region            = data.aws_region.current.name
    pg_netloc                       = var.db_cluster_endpoint
    pg_dbname                       = var.db_database_name
    pg_user                         = var.db_username
    pg_password                     = var.db_password
    enable_active_active            = var.enable_active_active ? 1 : 0
    redis_host                      = var.enable_active_active ? var.redis_host : ""
    redis_pass                      = var.enable_active_active ? var.redis_password : ""
    redis_port                      = var.enable_active_active ? var.redis_port : ""
    redis_use_password_auth         = var.enable_active_active && var.redis_password != "" ? 1 : 0
    redis_use_tls                   = var.enable_active_active && var.redis_password != "" ? 1 : 0
    log_forwarding_enabled          = var.log_forwarding_enabled ? 1 : 0
    log_forwarding_type             = var.log_forwarding_type
    fluent_bit_config               = local.fluent_bit_config
    generic_init_functions          = module.cloud_init_generic_functions.template_output
    product                         = var.product
  } : {}

  fdo_user_data_args = var.product == "tfefdo" ? {
    operational_mode                = var.enable_active_active ? "active-active" : "external"
    enable_active_active            = var.enable_active_active ? "active-active" : "external"
    tfe_hostname                    = var.tfe_hostname
    s3_bucket_encryption            = var.kms_key_arn != "" ? "aws:kms" : ""
    s3_app_bucket_name              = var.s3_app_bucket_name
    pg_netloc                       = var.db_cluster_endpoint
    pg_dbname                       = var.db_database_name
    pg_user                         = var.db_username
    pg_password                     = var.db_password
    pg_port                         = var.db_port
    redis_host                      = var.enable_active_active ? var.redis_host : ""
    redis_pass                      = var.enable_active_active ? var.redis_password : ""
    redis_port                      = var.enable_active_active ? var.redis_port : ""
    redis_use_password_auth         = var.enable_active_active && var.redis_password != "" ? 1 : 0
    redis_use_tls                   = var.enable_active_active && var.redis_password != "" ? 1 : 0
    kms_key_arn                     = var.kms_key_arn
    custom_tbw_ecr_repo_uri         = var.custom_tbw_ecr_repo != "" ? data.aws_ecr_repository.custom_tbw_image[0].repository_url : ""
    custom_image_tag                = local.custom_image_tag
    generic_init_functions          = module.cloud_init_generic_functions.template_output
    product                         = var.product
    install_docker_before           = var.install_docker_before
    config_directory                = var.tfe_config_directory
    tls_bootstrap_type              = var.tls_bootstrap_type
    cert_secret_arn                 = var.tfe_cert_secret_arn
    privkey_secret_arn              = var.tfe_privkey_secret_arn
    ca_bundle_secret_arn            = var.ca_bundle_secret_arn
    license_secret_arn              = var.license_secret_arn
    enc_password_arn                = var.enc_password_arn
    tfe_release_sequence            = var.tfe_fdo_release_sequence
    pkg_repos_reachable_with_airgap = var.pkg_repos_reachable_with_airgap
    capacity_concurrency            = var.capacity_concurrency
    capacity_memory                 = var.capacity_memory
    enable_metrics_collection       = var.enable_metrics_collection ? 1 : 0
    metrics_endpoint_enabled        = var.metrics_endpoint_enabled ? 1 : 0
    metrics_endpoint_port_http      = var.metrics_endpoint_port_http
    metrics_endpoint_port_https     = var.metrics_endpoint_port_https
    log_forwarding_enabled          = var.log_forwarding_enabled ? 1 : 0
    fluent_bit_config               = local.fluent_bit_config
    tfe_iact_subnets                = var.tfe_iact_settings.iact_subnets
    tfe_iact_time_limit             = var.tfe_iact_settings.iact_time_limit
    tfe_iact_trusted_proxies        = var.tfe_iact_settings.iact_trusted_proxies
  } : {}
}

module "cloud_init_generic_functions" {
  source = "./modules/cloud_init_generic_functions"
  install_docker_before           = var.install_docker_before
  airgap_install                  = var.airgap_install
  pkg_repos_reachable_with_airgap = var.pkg_repos_reachable_with_airgap
  log_path                        = var.log_path
  cloudwatch_log_group_name       = var.cloudwatch_log_group_name
  cloudwatch_retention_in_days    = var.cloudwatch_retention_in_days
  log_forwarding_enabled          = var.log_forwarding_enabled
  docker_version                  = var.docker_version
  product                         = var.product
  cloud                           = var.cloud
}

resource "aws_launch_template" "lt" {
  name          = "${var.friendly_name_prefix}-${var.product}-ec2-asg-lt"
  image_id      = coalesce(local.image_id_list...)
  instance_type = var.instance_size
  key_name      = var.ssh_key_pair
  user_data     = base64encode(templatefile("${path.module}/templates/${var.product}_user_data.sh.tpl", var.product == "tfe" ? local.user_data_args : local.fdo_user_data_args))

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  vpc_security_group_ids = concat(var.launch_template_sg_ids, [aws_security_group.ec2_sg.id], [])
  block_device_mappings {
    device_name = local.root_device_name

    ebs {
      volume_type = var.ebs_volume_type
      volume_size = var.ebs_volume_size
      throughput  = var.ebs_throughput
      iops        = var.ebs_iops
      encrypted   = var.ebs_is_encrypted
      kms_key_id  = var.ebs_is_encrypted && var.kms_key_arn != "" ? var.kms_key_arn : null
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      { "Name" = "${var.friendly_name_prefix}-${var.product}-ec2" },
      { "Type" = "autoscaling-group" },
      { "OS_Distro" = var.os_distro },
      { "asg-hook" = var.asg_hook_value },
      var.common_tags
    )
  }

  tags = merge({
    "Name"          = "${var.friendly_name_prefix}-${var.product}-ec2-launch-template"
    "Active-Active" = var.enable_active_active
    "asg-hook"      = var.asg_hook_value
    },
    var.common_tags
  )
}

#------------------------------------------------------------------------------
# Autoscaling Group
#------------------------------------------------------------------------------
resource "aws_autoscaling_group" "asg" {
  name                      = "${var.friendly_name_prefix}-${var.product}-asg"
  min_size                  = var.asg_min_size
  max_size                  = var.enable_active_active == false ? 1 : var.asg_max_size
  desired_capacity          = var.asg_instance_count
  vpc_zone_identifier       = var.ec2_subnet_ids
  health_check_grace_period = var.asg_health_check_grace_period
  health_check_type         = var.asg_health_check_type
  service_linked_role_arn   = var.asg_custom_role_arn
  wait_for_capacity_timeout = var.asg_capacity_timeout
  wait_for_elb_capacity     = var.asg_min_size
  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  initial_lifecycle_hook {
    name                 = var.asg_hook_value
    default_result       = "ABANDON"
    heartbeat_timeout    = var.airgap_install ? 1500 : var.lifecycle_hook_timeout
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
  }

  target_group_arns = var.lb_tg_arns

  tag {
    key                 = "Name"
    value               = "${var.friendly_name_prefix}-${var.product}-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "asg-hook"
    value               = var.asg_hook_value
    propagate_at_launch = true
  }

  tag {
    key                 = "Active-Active"
    value               = var.enable_active_active
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.common_tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}


#------------------------------------------------------------------------------
# Security Groups
#------------------------------------------------------------------------------
resource "aws_security_group" "ec2_sg" {
  name   = "${var.friendly_name_prefix}-${var.product}-ec2-ingress-allow"
  vpc_id = var.vpc_id
  tags   = merge({ "Name" = "${var.friendly_name_prefix}-${var.product}-ec2-ingress-allow" }, var.common_tags)
}

resource "aws_security_group_rule" "ec2_ingress_allow_https_from_lb" {
  count = var.lb_type == "application" ? 1 : 0

  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = var.lb_security_group_id
  description              = "Allow HTTPS (port 443) traffic inbound to TFE EC2 instance from TFE LB"

  security_group_id = aws_security_group.ec2_sg.id
}

resource "aws_security_group_rule" "ec2_ingress_allow_https" {
  count = var.lb_type == "network" ? 1 : 0

  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = var.ingress_cidr_443_allow
  description = "Allow HTTPS (port 443) traffic inbound to TFE EC2 instance"

  security_group_id = aws_security_group.ec2_sg.id
}

resource "aws_security_group_rule" "ec2_ingress_allow_console_from_lb" {
  count = var.lb_type == "application" && !var.enable_active_active && var.product != "tfefdo" ? 1 : 0

  type                     = "ingress"
  from_port                = 8800
  to_port                  = 8800
  protocol                 = "tcp"
  source_security_group_id = var.lb_security_group_id
  description              = "Allow admin console (port 8800) traffic inbound to TFE EC2 instance from TFE LB"

  security_group_id = aws_security_group.ec2_sg.id
}

resource "aws_security_group_rule" "ec2_ingress_allow_console" {
  count = var.lb_type == "network" && !var.enable_active_active && var.product != "tfefdo" ? 1 : 0

  type        = "ingress"
  from_port   = 8800
  to_port     = 8800
  protocol    = "tcp"
  cidr_blocks = var.ingress_cidr_8800_allow == null ? var.ingress_cidr_443_allow : var.ingress_cidr_8800_allow
  description = "Allow admin console (port 8800) traffic inbound to TFE LB for TFE Replicated admin console"

  security_group_id = aws_security_group.ec2_sg.id
}

resource "aws_security_group_rule" "ec2_ingress_allow_ssh" {
  count       = length(var.ingress_cidr_22_allow) > 0 ? 1 : 0
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = var.ingress_cidr_22_allow
  description = "Allow SSH inbound to TFE EC2 instance CIDR ranges listed"

  security_group_id = aws_security_group.ec2_sg.id
}

resource "aws_security_group_rule" "ec2_ingress_allow_vault" {
  count = var.enable_active_active ? 1 : 0

  type        = "ingress"
  from_port   = 8201
  to_port     = 8201
  protocol    = "tcp"
  self        = true
  description = "Allow embedded Vault instances to communicate with each other in HA mode"

  security_group_id = aws_security_group.ec2_sg.id
}

resource "aws_security_group_rule" "ec2_allow_all_outbound" {
  count       = var.permit_all_egress ? 1 : 0
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow all traffic egress from TFE"

  security_group_id = aws_security_group.ec2_sg.id
}

resource "aws_security_group_rule" "ec2_ingress_allow_metrics_http_cidr" {
  count = var.metrics_endpoint_enabled && var.metrics_endpoint_allow_cidr != null ? 1 : 0

  type        = "ingress"
  from_port   = var.metrics_endpoint_port_http
  to_port     = var.metrics_endpoint_port_http
  protocol    = "tcp"
  cidr_blocks = var.metrics_endpoint_allow_cidr
  description = "Allow external monitoring tools to gather TFE metrics."

  security_group_id = aws_security_group.ec2_sg.id
}

resource "aws_security_group_rule" "ec2_ingress_allow_metrics_https_cidr" {
  count = var.metrics_endpoint_enabled && var.metrics_endpoint_allow_cidr != null ? 1 : 0

  type        = "ingress"
  from_port   = var.metrics_endpoint_port_https
  to_port     = var.metrics_endpoint_port_https
  protocol    = "tcp"
  cidr_blocks = var.metrics_endpoint_allow_cidr
  description = "Allow external monitoring tools to gather TFE metrics."

  security_group_id = aws_security_group.ec2_sg.id
}

resource "aws_security_group_rule" "ec2_ingress_allow_metrics_http_sg" {
  count = var.metrics_endpoint_enabled && var.metrics_endpoint_allow_sg != null ? 1 : 0

  type                     = "ingress"
  from_port                = var.metrics_endpoint_port_http
  to_port                  = var.metrics_endpoint_port_http
  protocol                 = "tcp"
  source_security_group_id = var.metrics_endpoint_allow_sg
  description              = "Allow external monitoring tools to gather TFE metrics."

  security_group_id = aws_security_group.ec2_sg.id
}

resource "aws_security_group_rule" "ec2_ingress_allow_metrics_https_sg" {
  count = var.metrics_endpoint_enabled && var.metrics_endpoint_allow_sg != null ? 1 : 0

  type                     = "ingress"
  from_port                = var.metrics_endpoint_port_https
  to_port                  = var.metrics_endpoint_port_https
  protocol                 = "tcp"
  source_security_group_id = var.metrics_endpoint_allow_sg
  description              = "Allow external monitoring tools to gather TFE metrics."

  security_group_id = aws_security_group.ec2_sg.id
}

resource "aws_security_group_rule" "redis_ingress_allow_redis" {
  count = var.enable_active_active ? 1 : 0

  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2_sg.id
  description              = "Allow Redis traffic ingress from TFE servers"

  security_group_id = var.redis_security_group_id
}
