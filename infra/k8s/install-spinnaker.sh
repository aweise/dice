#!/bin/bash

# Install helm charts to the cluster.
# This should not be run directly. Instead, use "make charts" or "make spinnaker" to run this in Docker.
. /config

here=$(dirname $(readlink -f "$0"))

echo Setup helm.
helm init
(helm repo list | grep stable) || helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update

cd "${here}/spinnaker"
echo Deploy Spinnaker.
terraform init
terraform apply
