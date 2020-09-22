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
