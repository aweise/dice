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

echo Delete SSH public key secret
kops delete secret \
    --name ${CLUSTER} \
    --state=s3://${KOPS_STATE_STORE} \
    sshpublickey ${SSH_KEY_NAME} \

echo Destroy k8s cluster

kops delete cluster \
    --state=s3://${KOPS_STATE_STORE} \
    --name ${CLUSTER} \
    --yes
