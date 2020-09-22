# Terraform outputs (stored in state file)

output "kops_admin_aws_access_key_id" {
    value = aws_iam_access_key.kops_admin.id
}

output "kops_admin_aws_secret_access_key" {
    value = aws_iam_access_key.kops_admin.secret
}
