terraform {
  required_version = ">=1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.4"
    }
    acme = {
      source  = "vancluever/acme"
      version = ">= 2.13.1"
    }
    local = {
      source  = "hashicorp/local"
      version = ">=2.4.0"
    }
  }
}