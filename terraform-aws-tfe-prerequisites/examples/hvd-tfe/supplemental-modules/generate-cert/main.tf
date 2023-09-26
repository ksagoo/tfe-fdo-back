data "aws_route53_zone" "r53" {
  name = var.r53_domain_name
}

resource "tls_private_key" "acme_reg" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.acme_reg.private_key_pem
  email_address   = var.email_address
}

resource "acme_certificate" "certificate" {
  account_key_pem = acme_registration.reg.account_key_pem
  common_name     = var.cert_fqdn
  pre_check_delay = var.pre_check_delay

  dns_challenge {
    provider = "route53"

    config = {
      AWS_DEFAULT_REGION = var.region
      AWS_HOSTED_ZONE_ID = data.aws_route53_zone.r53.zone_id
    }
  }
}

resource "local_file" "pub_key_chain" {
  content  = "${acme_certificate.certificate.certificate_pem}${acme_certificate.certificate.issuer_pem}"
  filename = "${path.module}/tfe.pub"
}

resource "local_file" "private_key" {
  content  = nonsensitive(acme_certificate.certificate.private_key_pem)
  filename = "${path.module}/tfe.key"
}

resource "local_file" "pub_key_no_root" {
  content  = acme_certificate.certificate.certificate_pem
  filename = "${path.module}/tfe-no-root.pub"
}

