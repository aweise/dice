#ubuntu!/bin/bash

# Provision an IAM user for kops.
# This should not be run directly. Instead, use "make kops-admin" to run this in Docker.
. /config

here=$(dirname $(readlink -f "$0"))

cd "${here}/kops-iam"
echo Create an IAM user for kops with appropriate access permissions.
terraform init
terraform apply # Optional: pass -auto-approve for non-interactive installation

echo Create a state store for kops on S3
export AWS_ACCESS_KEY_ID=$(terraform output kops_admin_aws_access_key_id)
export AWS_SECRET_ACCESS_KEY=$(terraform output kops_admin_aws_secret_access_key)

aws sts get-caller-identity

aws s3api create-bucket \
    --bucket ${KOPS_STATE_STORE} \
    --region ${REGION:-eu-west-1} \
    --create-bucket-configuration LocationConstraint=${REGION:-eu-west-1}
aws s3api put-bucket-versioning \
    --bucket ${KOPS_STATE_STORE} \
    --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption \
    --bucket ${KOPS_STATE_STORE} \
    --server-side-encryption-configuration \
        '{
            "Rules": [{
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }]
        }'

