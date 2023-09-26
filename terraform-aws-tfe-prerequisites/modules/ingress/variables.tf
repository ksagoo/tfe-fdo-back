# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "friendly_name_prefix" {
  type        = string
  description = "Friendly name prefix used for tagging and naming AWS resources."
}

variable "common_tags" {
  type        = map(string)
  description = "Map of common tags for all taggable AWS resources."
  default     = {}
}

variable "route53_zone_name" {
  type        = string
  description = "Route 53 public zone name"
  default     = ""
}

variable "route53_private_zone" {
  type        = bool
  description = "Boolean that when true, designates the data lookup to use a private Route 53 zone name"
  default     = false
}

variable "route53_record_health_check_enabled" {
  type        = bool
  description = "Enabled evaluation of target health for direct LB record"
  default     = false
}

variable "route53_failover_record" {
  type = object({
    create              = optional(bool, true)
    set_id              = optional(string)
    lb_failover_primary = optional(bool, true)
    record_name         = optional(string)
  })
  default     = {}
  description = "If set, creates a Route53 failover record.  Ensure that the record name is the same between both modules.  Also, the Record ID needs to be unique per module"
}

variable "create_lb_certificate" {
  type        = bool
  default     = true
  description = "Boolean that when true will create the SSL certificate for the ALB to use."
}

variable "create_lb_security_groups" {
  type        = bool
  default     = true
  description = "Boolean that when true will create the required security groups for the load balancers to use."
}

variable "lb_name" {
  type        = string
  default     = "lb"
  description = "Name of the Load Balancer to be deployed"
}

variable "lb_security_group_ids" {
  type        = list(string)
  default     = []
  description = "Optional list of security group IDs to be used if providing security groups created outside of this module"
}

variable "lb_internal" {
  type        = bool
  default     = false
  description = "Boolean to determine if the Load Balancer will be internal or internet facing"
}

variable "lb_subnet_ids" {
  type        = list(string)
  description = "List of Subnet IDs to deploy Load Balancer into"
}

variable "lb_certificate_arn" {
  type        = string
  default     = null
  description = "Bring your own certificate ARN"
}

variable "lb_type" {
  type        = string
  default     = "application"
  description = "Type of load balancer that will be provisioned as a part of the module execution (if specified)."
}

variable "lb_connection_termination" {
  type        = bool
  default     = true
  description = "Whether to terminate connections at the end of the deregistration timeout on Network Load Balancers"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC that the load balancers will use."
}

variable "lb_listener_details" {
  type = object({
    tfe_api = optional(object({
      create      = optional(bool, true)
      port        = optional(number, 443)
      ssl_policy  = optional(string, "ELBSecurityPolicy-2016-08")
      action_type = optional(string, "forward")
    }))
    tfe_console = optional(object({
      create      = optional(bool, true)
      port        = optional(number, 8800)
      ssl_policy  = optional(string, "ELBSecurityPolicy-2016-08")
      action_type = optional(string, "forward")
    }))
    vault_api = optional(object({
      create      = optional(bool, true)
      port        = optional(number, 8200)
      ssl_policy  = optional(string, "ELBSecurityPolicy-TLS-1-2-2017-01")
      action_type = optional(string, "forward")
    }))
    vault_cluster = optional(object({
      create      = optional(bool, true)
      port        = optional(number, 8201)
      ssl_policy  = optional(string, "ELBSecurityPolicy-TLS-1-2-2017-01")
      action_type = optional(string, "forward")
    }))
    consul_dns = optional(object({
      create      = optional(bool, true)
      port        = optional(number, 53)
      ssl_policy  = optional(string, "")
      action_type = optional(string, "forward")
    }))
    consul_mesh_gateway = optional(object({
      create      = optional(bool, true)
      port        = optional(number, 443)
      ssl_policy  = optional(string, "")
      action_type = optional(string, "forward")
    }))
    consul_api = optional(object({
      create      = optional(bool, false)
      port        = optional(number, 8500)
      ssl_policy  = optional(string, "ELBSecurityPolicy-TLS-1-2-2017-01")
      action_type = optional(string, "forward")
    }))
    consul_api_tls = optional(object({
      create      = optional(bool, true)
      port        = optional(number, 8501)
      ssl_policy  = optional(string, "ELBSecurityPolicy-TLS-1-2-2017-01")
      action_type = optional(string, "forward")
    }))
    consul_ingress_gateway = optional(object({
      create      = optional(bool, true)
      port        = optional(number, 8080)
      ssl_policy  = optional(string, "")
      action_type = optional(string, "forward")
    }))
    consul_grpc_tls = optional(object({
      create      = optional(bool, true)
      port        = optional(number, 8502)
      ssl_policy  = optional(string, "")
      action_type = optional(string, "forward")
    }))
    boundary_controller = optional(object({
      create      = optional(bool, true)
      port        = optional(number, 9200)
      ssl_policy  = optional(string, "")
      action_type = optional(string, "forward")
    }))
    boundary_controller_session = optional(object({
      create      = optional(bool, true)
      port        = optional(number, 9201)
      ssl_policy  = optional(string, "")
      action_type = optional(string, "forward")
    }))
  })
  description = "Configures the LB Listeners for various HashiCorp Products"
  default     = {}
}

variable "lb_target_groups" {
  type = object({
    tfe_api = optional(object({
      create               = optional(bool, true)
      description          = optional(string, "Target Group for TLS API/Web application traffic")
      name                 = optional(string, "tfe-tls-tg")
      deregistration_delay = optional(number, 60)
      port                 = optional(number, 443)
      protocol             = optional(string, "HTTPS")
      health_check = optional(object({
        enabled             = optional(bool, true)
        port                = optional(number, 443)
        healthy_threshold   = optional(number, 2)
        unhealthy_threshold = optional(number, 7)
        timeout             = optional(number, 5)
        interval            = optional(number, 30)
        matcher             = optional(string, "200")
        path                = optional(string, "/_health_check")
        protocol            = optional(string, "HTTPS")
      }))
    }))
    tfe_console = optional(object({
      create               = optional(bool, true)
      name                 = optional(string, "tfe-console-tg")
      description          = optional(string, "Target Group for TFE/Replicated web admin console traffic")
      deregistration_delay = optional(number, 60)
      port                 = optional(number, 8800)
      protocol             = optional(string, "HTTPS")
      health_check = optional(object({
        enabled             = optional(bool, true)
        port                = optional(number, 8800)
        healthy_threshold   = optional(number, 2)
        unhealthy_threshold = optional(number, 7)
        timeout             = optional(number, 5)
        interval            = optional(number, 30)
        matcher             = optional(string, "200-299")
        path                = optional(string, "/ping")
        protocol            = optional(string, "HTTPS")
      }))
    }))
    vault_api = optional(object({
      create               = optional(bool, true)
      name                 = optional(string, "vault-console-tg")
      description          = optional(string, "Target Group for Vault web console traffic")
      deregistration_delay = optional(number, 15)
      port                 = optional(number, 8200)
      protocol             = optional(string, "TCP")
      health_check = optional(object({
        enabled             = optional(bool, true)
        port                = optional(string, "8200")
        healthy_threshold   = optional(number, 2)
        unhealthy_threshold = optional(number, 7)
        timeout             = optional(number, 5)
        interval            = optional(number, 30)
        matcher             = optional(string, "200-299")
        path                = optional(string, "/v1/sys/health?standbyok=true&perfstandbyok=true&activecode=200&standbycode=429&drsecondarycode=472&performancestandbycode=473&sealedcode=503&uninitcode=501")
        protocol            = optional(string, "HTTPS")
      }))
    }))
    vault_cluster = optional(object({
      create               = optional(bool, true)
      name                 = optional(string, "vault-cluster-tg")
      description          = optional(string, "Target Group for Vault cluster traffic")
      deregistration_delay = optional(number, 15)
      port                 = optional(number, 8201)
      protocol             = optional(string, "TCP")
      health_check = optional(object({
        enabled             = optional(bool, true)
        port                = optional(string, "8200")
        healthy_threshold   = optional(number, 2)
        unhealthy_threshold = optional(number, 7)
        timeout             = optional(number, 5)
        interval            = optional(number, 30)
        matcher             = optional(string, "200-299")
        path                = optional(string, "/v1/sys/health")
        protocol            = optional(string, "HTTPS")
      }))
    }))
    consul_dns = optional(object({
      create               = optional(bool, true)
      name                 = optional(string, "consul-dns-tg")
      description          = optional(string, "Target Group for Consul DNS traffic")
      deregistration_delay = optional(number, 15)
      port                 = optional(number, 53)
      protocol             = optional(string, "TCP_UDP")
      health_check = optional(object({
        enabled             = optional(bool, true)
        port                = optional(string, "8600")
        healthy_threshold   = optional(number, 2)
        unhealthy_threshold = optional(number, 2)
        timeout             = optional(number, 5)
        interval            = optional(number, 10)
        matcher             = optional(string, "200-299")
        path                = optional(string, "")
        protocol            = optional(string, "TCP")
      }))
    }))
    consul_mesh_gateway = optional(object({
      create               = optional(bool, true)
      name                 = optional(string, "mesh-gw-tg")
      description          = optional(string, "Target Group for Consul Mesh Gateway traffic")
      deregistration_delay = optional(number, 15)
      port                 = optional(number, 8443)
      protocol             = optional(string, "TCP")
      health_check = optional(object({
        enabled             = optional(bool, true)
        port                = optional(string, "8443")
        healthy_threshold   = optional(number, 2)
        unhealthy_threshold = optional(number, 2)
        timeout             = optional(number, 5)
        interval            = optional(number, 10)
        matcher             = optional(string, "200-299")
        path                = optional(string, "")
        protocol            = optional(string, "TCP")
      }))
    }))
    consul_api = optional(object({
      create               = optional(bool, true)
      name                 = optional(string, "consul-api-tg")
      description          = optional(string, "Target Group for Consul api traffic")
      deregistration_delay = optional(number, 15)
      port                 = optional(number, 8500)
      protocol             = optional(string, "TCP")
      health_check = optional(object({
        enabled             = optional(bool, true)
        port                = optional(string, "8500")
        healthy_threshold   = optional(number, 2)
        unhealthy_threshold = optional(number, 2)
        timeout             = optional(number, 5)
        interval            = optional(number, 10)
        matcher             = optional(string, "200-299")
        path                = optional(string, "/health")
        protocol            = optional(string, "HTTPS")
      }))
    }))
    consul_api_tls = optional(object({
      create               = optional(bool, true)
      name                 = optional(string, "consul-api-tls-tg")
      description          = optional(string, "Target Group for Consul api traffic")
      deregistration_delay = optional(number, 15)
      port                 = optional(number, 8501)
      protocol             = optional(string, "TCP")
      health_check = optional(object({
        enabled             = optional(bool, true)
        port                = optional(string, "8501")
        healthy_threshold   = optional(number, 2)
        unhealthy_threshold = optional(number, 2)
        timeout             = optional(number, 5)
        interval            = optional(number, 10)
        matcher             = optional(string, "200-299")
        path                = optional(string, "/health")
        protocol            = optional(string, "HTTPS")
      }))
    }))
    consul_grpc_tls = optional(object({
      create               = optional(bool, true)
      name                 = optional(string, "grpc-tls-tg")
      description          = optional(string, "Target Group for Consul GRPC traffic")
      deregistration_delay = optional(number, 15)
      port                 = optional(number, 8502)
      protocol             = optional(string, "TCP")
      health_check = optional(object({
        enabled             = optional(bool, true)
        port                = optional(string, "8502")
        healthy_threshold   = optional(number, 2)
        unhealthy_threshold = optional(number, 2)
        timeout             = optional(number, 5)
        interval            = optional(number, 10)
        matcher             = optional(string, "200-299")
        path                = optional(string, "")
        protocol            = optional(string, "TCP")
      }))
    }))
    consul_ingress_gateway = optional(object({
      create               = optional(bool, true)
      name                 = optional(string, "consul-ing-gw")
      description          = optional(string, "Target Group for Consul Ingress Gateway traffic")
      deregistration_delay = optional(number, 15)
      port                 = optional(number, 8080)
      protocol             = optional(string, "TCP")
      health_check = optional(object({
        enabled             = optional(bool, true)
        port                = optional(string, "8080")
        healthy_threshold   = optional(number, 2)
        unhealthy_threshold = optional(number, 2)
        timeout             = optional(number, 5)
        interval            = optional(number, 10)
        matcher             = optional(string, "200-299")
        path                = optional(string, "/health")
        protocol            = optional(string, "TCP")
      }))
    }))
    boundary_controller = optional(object({
      create               = optional(bool, true)
      name                 = optional(string, "boundary-controller")
      description          = optional(string, "Target Group for Boundary Controller traffic")
      deregistration_delay = optional(number, 15)
      port                 = optional(number, 9200)
      protocol             = optional(string, "TCP")
      health_check = optional(object({
        enabled             = optional(bool, true)
        port                = optional(string, "9200")
        healthy_threshold   = optional(number, 2)
        unhealthy_threshold = optional(number, 2)
        timeout             = optional(number, 5)
        interval            = optional(number, 10)
        matcher             = optional(string, "200-299")
        path                = optional(string, "")
        protocol            = optional(string, "TCP")
      }))
    }))
    boundary_controller_session = optional(object({
      create               = optional(bool, true)
      name                 = optional(string, "boundary-session")
      description          = optional(string, "Target Group for Boundary Controller session traffic")
      deregistration_delay = optional(number, 15)
      port                 = optional(number, 9201)
      protocol             = optional(string, "TCP")
      health_check = optional(object({
        enabled             = optional(bool, true)
        port                = optional(string, "9201")
        healthy_threshold   = optional(number, 2)
        unhealthy_threshold = optional(number, 2)
        timeout             = optional(number, 5)
        interval            = optional(number, 10)
        matcher             = optional(string, "200-299")
        path                = optional(string, "")
        protocol            = optional(string, "TCP")
      }))
    }))
  })
  description = "Object map for the Load Balancer Target Group configuration"
  default     = {}
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
    }))
    tfe_console_ingress = optional(object({
      type        = optional(string, "ingress")
      create      = optional(bool, true)
      from_port   = optional(string, "8800")
      to_port     = optional(string, "8800")
      protocol    = optional(string, "tcp")
      cidr_blocks = optional(list(string), [])
      description = optional(string, "Allow 8800 traffic inbound for TFE")
    }))
    vault_console_ingress = optional(object({
      type        = optional(string, "ingress")
      create      = optional(bool, true)
      from_port   = optional(string, "8201")
      to_port     = optional(string, "8201")
      protocol    = optional(string, "tcp")
      cidr_blocks = optional(list(string), [])
      description = optional(string, "Allow 8201 traffic inbound for Vault")
    }))
    vault_api_ingress = optional(object({
      type        = optional(string, "ingress")
      create      = optional(bool, true)
      from_port   = optional(string, "8200")
      to_port     = optional(string, "8200")
      protocol    = optional(string, "tcp")
      cidr_blocks = optional(list(string), [])
      description = optional(string, "Allow 8200 traffic inbound for Vault")
    }))
    consul_api_ingress = optional(object({
      type        = optional(string, "ingress")
      create      = optional(bool, true)
      from_port   = optional(string, "8500")
      to_port     = optional(string, "8500")
      protocol    = optional(string, "tcp")
      cidr_blocks = optional(list(string), [])
      description = optional(string, "Allow 8500 traffic inbound for Consul")
    }))
    consul_api_tls_ingress = optional(object({
      type        = optional(string, "ingress")
      create      = optional(bool, true)
      from_port   = optional(string, "8500")
      to_port     = optional(string, "8500")
      protocol    = optional(string, "tcp")
      cidr_blocks = optional(list(string), [])
      description = optional(string, "Allow 8500 traffic inbound for Consul")
    }))
    boundary_api_ingress = optional(object({
      type        = optional(string, "ingress")
      create      = optional(bool, true)
      from_port   = optional(string, "9200")
      to_port     = optional(string, "9200")
      protocol    = optional(string, "tcp")
      cidr_blocks = optional(list(string), [])
      description = optional(string, "Allow 9200 traffic inbound for Boundary API access")
    }))
    boundary_worker_ingress = optional(object({
      type        = optional(string, "ingress")
      create      = optional(bool, true)
      from_port   = optional(string, "9201")
      to_port     = optional(string, "9201")
      protocol    = optional(string, "tcp")
      cidr_blocks = optional(list(string), [])
      description = optional(string, "Allow 9201 traffic inbound for Boundary Workers")
    }))
    egress = optional(object({
      type        = optional(string, "egress")
      create      = optional(bool, true)
      from_port   = optional(string, "0")
      to_port     = optional(string, "0")
      protocol    = optional(string, "-1")
      cidr_blocks = optional(list(string), ["0.0.0.0/0"])
      description = optional(string, "Allow traffic outbound")
    }))
  })
  description = "Object map for various Security Group Rules as pertains to the Load Balancer for the installation. Note that these only apply if the load balancer type is `application`"
  default     = {}
}


