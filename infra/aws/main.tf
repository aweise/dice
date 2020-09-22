#variable "aws_account_id" {
#    description = "ID of the AWS account for the deployment"
#    type = string
#}

variable "region" {
    description = "AWS region (default: eu-west-1)"
    default = "eu-west-1"
    type = string
}

variable "dice_profile" {
    description = "Name of the AWS profile for the Terraform AWS provider. Must have IAM admin rights."
    default = "dice"
    type = string
}

variable "admin_group_name" {
    description = "Name of the IAM group to create, which can manage k8s clusters"
    default = "dice-cluster-admin"
    type = string
}

variable "kops_user_name" {
    description = "Name of the administrative IAM user for kops"
    default = "dice-kops"
    type = string
}

terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 3.7.0"
        }
    }
}

provider "aws" {
#    allowed_account_ids = [ var.aws_account_id ]
    region = var.region
    profile = var.dice_profile
}

resource "aws_iam_group" "cluster_admin" {
    name = var.admin_group_name
}

resource "aws_iam_group_policy_attachment" "admin_ec2" {
    group = aws_iam_group.cluster_admin.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}


resource "aws_iam_group_policy_attachment" "admin_vpc" {
    group = aws_iam_group.cluster_admin.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

resource "aws_iam_group_policy_attachment" "admin_r53" {
    group = aws_iam_group.cluster_admin.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

resource "aws_iam_group_policy_attachment" "admin_s3" {
    group = aws_iam_group.cluster_admin.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_group_policy_attachment" "admin_iam" {
    group = aws_iam_group.cluster_admin.name
    policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_iam_user" "kops_user" {
    name = var.kops_user_name
}

resource "aws_iam_user_group_membership" "kops_admin" {
    user = aws_iam_user.kops_user.name
    groups = [ aws_iam_group.cluster_admin.name ]
}

resource "aws_iam_access_key" "kops_admin" {
    user = aws_iam_user.kops_user.name
}

output "kops_admin_aws_access_key_id" {
    value = aws_iam_access_key.kops_admin.id
}

output "kops_admin_aws_secret_access_key" {
    value = aws_iam_access_key.kops_admin.secret
}
