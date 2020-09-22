# Terraform variables

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
