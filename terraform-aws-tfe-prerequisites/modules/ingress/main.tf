# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  lb_listeners = {
    for listener, values in var.lb_listener_details : listener => values
    if try(values.create, false)
  }

  target_groups = {
    for tg, values in var.lb_target_groups : tg => values
    if try(values.create, false)
  }

  sg_rules_to_create       = { for sg, values in var.lb_sg_rules_details : sg => values if try(values.cidr_blocks, [""]) != [""] && try(values.create, false) }
  lb_regional_route53_name = "${var.lb_name}-${data.aws_region.current.name}.${var.route53_zone_name}"
  acm_domain_name          = try(var.route53_failover_record.create, false) ? "${var.route53_failover_record.record_name}.${var.route53_zone_name}" : local.lb_regional_route53_name
}

resource "terraform_data" "sg_rule_validation" {
  count = var.create_lb_security_groups && var.lb_type == "application" ? 1 : 0
  input = local.sg_rules_to_create
  lifecycle {
    precondition {
      condition     = length({ for sg, value in local.sg_rules_to_create : sg => value.cidr_blocks if value != null && try(length(value.cidr_blocks), 0) == 0 }) == 0
      error_message = "Please provide a value for cidr_blocks for each security group under the variable lb_sg_rules_details when setting lb_create_security_groups to true"
    }
  }
}

resource "aws_lb" "lb" {
  name                             = "${var.friendly_name_prefix}${var.lb_name}"
  internal                         = var.lb_internal
  load_balancer_type               = var.lb_type
  subnets                          = var.lb_subnet_ids
  drop_invalid_header_fields       = var.lb_type == "application" ? true : null
  enable_cross_zone_load_balancing = true

  security_groups = var.create_lb_security_groups && var.lb_type == "application" ? [aws_security_group.alb_sg_allow[0].id] : (!var.create_lb_security_groups && var.lb_type == "application" && length(var.lb_security_group_ids) != 0 ? var.lb_security_group_ids : null)
  tags            = var.common_tags
}

resource "aws_lb_listener" "alb_listeners" {
  for_each          = local.lb_listeners
  load_balancer_arn = aws_lb.lb.arn
  port              = each.value.port
  protocol          = lookup(local.target_groups, each.key).protocol
  ssl_policy        = var.lb_type == "application" ? try(each.value.ssl_policy, null) : null
  certificate_arn   = var.lb_type == "application" && var.create_lb_certificate ? module.acm[0].acm_certificate_arn : (var.lb_type == "network" ? null : var.lb_certificate_arn)

  default_action {
    type             = each.value.action_type
    target_group_arn = aws_lb_target_group.lb_tgs[each.key].arn
  }
  tags = var.common_tags
}

resource "aws_lb_target_group" "lb_tgs" {
  for_each               = local.target_groups
  name                   = "${var.friendly_name_prefix}-${each.value.name}"
  port                   = each.value.port
  deregistration_delay   = each.value.deregistration_delay
  connection_termination = var.lb_type == "network" && each.value.protocol != "HTTPS" ? var.lb_connection_termination : null
  protocol               = each.value.protocol
  vpc_id                 = var.vpc_id

  dynamic "health_check" {
    for_each = try(local.target_groups[each.key].health_check.protocol == "HTTPS" ? [local.target_groups[each.key].health_check] : [], [])
    content {
      enabled             = health_check.value.enabled
      protocol            = health_check.value.protocol
      healthy_threshold   = health_check.value.healthy_threshold
      unhealthy_threshold = health_check.value.unhealthy_threshold
      timeout             = health_check.value.timeout
      interval            = health_check.value.interval
      path                = health_check.value.path
      matcher             = health_check.value.matcher
      port                = health_check.value.port
    }
  }

  dynamic "health_check" {
    for_each = try(local.target_groups[each.key].health_check.protocol == "TCP" ? [local.target_groups[each.key].health_check] : [], [])
    content {
      enabled             = health_check.value.enabled
      protocol            = health_check.value.protocol
      healthy_threshold   = health_check.value.healthy_threshold
      unhealthy_threshold = health_check.value.unhealthy_threshold
      timeout             = health_check.value.timeout
      interval            = health_check.value.interval
      port                = health_check.value.port
    }
  }

  tags = merge(
    { "Description" = each.value.description },
    var.common_tags
  )
}


#------------------------------------------------------------------------------
# Security Groups
#------------------------------------------------------------------------------
resource "aws_security_group" "alb_sg_allow" {
  count = var.lb_type == "application" && var.create_lb_security_groups ? 1 : 0

  name   = "${var.friendly_name_prefix}${var.lb_name}-sg"
  vpc_id = var.vpc_id
  tags   = var.common_tags
}

resource "aws_security_group_rule" "alb_sg_ingress_allow" {
  for_each = { for k, v in local.sg_rules_to_create : k => v if var.create_lb_security_groups && var.lb_type == "application" }

  type        = each.value.type
  from_port   = each.value.from_port
  to_port     = each.value.to_port
  protocol    = each.value.protocol
  cidr_blocks = each.value.cidr_blocks
  description = each.value.description

  security_group_id = aws_security_group.alb_sg_allow[0].id
}

#------------------------------------------------------------------------------
# Route53 Domain Name Generation
#------------------------------------------------------------------------------
data "aws_route53_zone" "this" {
  name         = var.route53_zone_name
  private_zone = var.route53_private_zone
}

data "aws_region" "current" {}

resource "aws_route53_record" "r53_record" {
  zone_id = data.aws_route53_zone.this.id
  name    = "${var.lb_name}-${data.aws_region.current.name}"
  type    = "A"

  alias {
    name                   = aws_lb.lb.dns_name
    zone_id                = aws_lb.lb.zone_id
    evaluate_target_health = var.route53_record_health_check_enabled
  }
}

resource "aws_route53_record" "failover" {
  count   = var.route53_failover_record.create ? 1 : 0
  zone_id = data.aws_route53_zone.this.id
  name    = var.route53_failover_record.record_name
  type    = "A"

  failover_routing_policy {
    type = var.route53_failover_record.lb_failover_primary ? "PRIMARY" : "SECONDARY"
  }

  alias {
    name                   = aws_lb.lb.dns_name
    zone_id                = aws_lb.lb.zone_id
    evaluate_target_health = true
  }

  set_identifier = var.route53_failover_record.set_id
}

#------------------------------------------------------------------------------
# Certificate Generation
#------------------------------------------------------------------------------
module "acm" {
  count  = var.create_lb_certificate && var.lb_type == "application" ? 1 : 0
  source = "./modules/acm"

  domain_name               = local.acm_domain_name
  subject_alternative_names = try(var.route53_failover_record.create, false) ? [local.lb_regional_route53_name] : []
  zone_id                   = data.aws_route53_zone.this.id
}

