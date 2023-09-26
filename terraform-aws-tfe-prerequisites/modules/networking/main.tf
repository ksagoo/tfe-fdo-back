data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "./modules/vpc"

  azs                            = data.aws_availability_zones.available.names
  cidr                           = var.vpc_cidr
  create_igw                     = var.vpc_option_flags.create_igw
  default_security_group_egress  = var.vpc_default_security_group_egress
  default_security_group_ingress = var.vpc_default_security_group_ingress
  enable_dns_hostnames           = var.vpc_option_flags.enable_dns_hostnames
  enable_dns_support             = var.vpc_option_flags.enable_dns_support
  enable_nat_gateway             = var.vpc_option_flags.create_igw ? var.vpc_option_flags.enable_nat_gateway : false
  manage_default_security_group  = var.vpc_option_flags.manage_default_security_group
  map_public_ip_on_launch        = var.vpc_option_flags.map_public_ip_on_launch
  name                           = "${var.friendly_name_prefix}-${var.vpc_name}"
  one_nat_gateway_per_az         = var.vpc_option_flags.one_nat_gateway_per_az
  private_subnets                = var.private_subnets
  public_subnets                 = var.public_subnets
  database_subnets               = var.database_subnets
  single_nat_gateway             = var.vpc_option_flags.single_nat_gateway
  tags                           = var.common_tags

  default_security_group_tags = {
    Name = "${var.friendly_name_prefix}-${var.product}-dsg"
  }
  igw_tags = {
    Name = "${var.friendly_name_prefix}-${var.product}-igw"
  }
  nat_eip_tags = {
    Name = "${var.friendly_name_prefix}-${var.product}-nat-eip"
  }
  nat_gateway_tags = {
    Name = "${var.friendly_name_prefix}-${var.product}-natgw"
  }
  private_route_table_tags = {
    Name = "${var.friendly_name_prefix}-${var.product}-rtb-private"
  }
  private_subnet_tags = {
    Name = "${var.friendly_name_prefix}-private"
  }
  public_route_table_tags = {
    Name = "${var.friendly_name_prefix}-${var.product}-rtb-public"
  }
  public_subnet_tags = {
    Name = "${var.friendly_name_prefix}-public"
  }
  vpc_tags = {
    Name = "${var.friendly_name_prefix}-${var.product}-vpc"
  }
}


module "vpc_endpoints" {
  source = "./modules/vpc_endpoints"
  vpc_id = module.vpc.vpc_id

  endpoints = {
    ec2 = {
      create              = var.vpc_endpoint_flags.create_ec2
      service             = "ec2"
      service_type        = "Interface"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = var.vpc_enable_ssm ? [aws_security_group.tls.id] : []
      tags = {
        Name = "${var.friendly_name_prefix}-${var.product}-ec2-vpc-endpoint"
      }
    }
    ec2messages = {
      create              = var.vpc_endpoint_flags.create_ec2messages
      private_dns_enabled = true
      service             = "ec2messages"
      service_type        = "Interface"
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = var.vpc_enable_ssm ? [aws_security_group.tls.id] : []
      tags = {
        Name = "${var.friendly_name_prefix}-${var.product}-ec2messages-vpc-endpoint"
      }
    }
    kms = {
      create              = var.vpc_endpoint_flags.create_kms
      service             = "kms"
      service_type        = "Interface"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.tls.id]
      tags = {
        Name = "${var.friendly_name_prefix}-${var.product}-kms-vpc-endpoint"
      }
    }
    s3 = {
      create          = var.vpc_endpoint_flags.create_s3
      route_table_ids = module.vpc.private_route_table_ids
      service         = "s3"
      service_type    = "Gateway"
      tags = {
        Name = "${var.friendly_name_prefix}-${var.product}-s3-vpc-endpoint"
      }
    }
    ssm = {
      create              = var.vpc_endpoint_flags.create_ssm
      private_dns_enabled = true
      service             = "ssm"
      service_type        = "Interface"
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = var.vpc_enable_ssm ? [aws_security_group.tls.id] : []
      tags = {
        Name = "${var.friendly_name_prefix}-${var.product}-ssm-vpc-endpoint"
      }
    }
    ssmmessages = {
      create              = var.vpc_endpoint_flags.create_ssmmessages
      private_dns_enabled = true
      service             = "ssmmessages"
      service_type        = "Interface"
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = var.vpc_enable_ssm ? [aws_security_group.tls.id] : []
      tags = {
        Name = "${var.friendly_name_prefix}-${var.product}-ssmmessages-vpc-endpoint"
      }
    }
  }
}

resource "aws_security_group" "tls" {
  name_prefix = "${var.friendly_name_prefix}-tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  tags = var.common_tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "tls" {
  security_group_id = aws_security_group.tls.id
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  type              = "ingress"

  cidr_blocks = module.vpc.private_subnets_cidr_blocks
}

resource "aws_security_group_rule" "tls_public_subnets" {
  count             = var.create_vpc_endpoint_access_public_subnets ? 1 : 0
  security_group_id = aws_security_group.tls.id
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  type              = "ingress"

  cidr_blocks = module.vpc.public_subnets_cidr_blocks
}
