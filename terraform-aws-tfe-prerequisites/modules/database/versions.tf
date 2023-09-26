# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_version = ">= 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "<6.0.0,>=5.0.0 "
    }
    time = {
      source  = "hashicorp/time"
      version = ">=0.9.1"
    }
  }
}
