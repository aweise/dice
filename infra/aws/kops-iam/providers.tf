# Provider configuration

terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 3.7.0"
        }
    }
}

provider "aws" {
    region = var.region
    profile = var.dice_profile
}

