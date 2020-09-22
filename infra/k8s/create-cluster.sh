#!/bin/bash

# Provision a kubernetes cluster with kops.
# This should not be run directly. Instead, use "make k8s-cluster" to run this in Docker.
. /config

here=$(dirname $(readlink -f "$0"))

echo Switch to kops IAM user
cd "${here}/../aws/kops-iam"
export AWS_ACCESS_KEY_ID=$(terraform output kops_admin_aws_access_key_id)
export AWS_SECRET_ACCESS_KEY=$(terraform output kops_admin_aws_secret_access_key)

aws sts get-caller-identity

echo Create cluster configuration
kops create cluster \
    --zones=${AZS} \
    --state=s3://${KOPS_STATE_STORE} \
    --node-count=${NODE_COUNT} \
    --node-size=${INSTANCE_TYPE} \
    ${CLUSTER}

echo Create SSH public key secret
kops create secret \
    --name ${CLUSTER} \
    --state=s3://${KOPS_STATE_STORE} \
    sshpublickey ${SSH_KEY_NAME} \
    -i "${SSH_KEY_PATH}.pub"

echo Build kubernetes cluster
kops update cluster --yes

echo Waiting for cluster to become available
kops validate cluster --wait ${KOPS_VALIDATION_TIMEOUT:-10m}

