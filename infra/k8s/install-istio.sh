#!/bin/bash

# Install helm charts to the cluster.
# This should not be run directly. Instead, use "make charts" or "make istio" to run this in Docker.
. /config

here=$(dirname $(readlink -f "$0"))

echo Setup helm.
helm init
(helm repo list | grep stable) || helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update

cd "${here}/istio"
echo Deploy Istio.
terraform init

TF_OPTS=
DELAY=60
counter=0

if ! terraform apply; then
    echo Terraform failed on the first try.
    echo This may happen when istio-init has not finished in time.
    echo Retrying ...
    terraform apply -auto-approve
fi
istioctl install --set profile=demo
kubectl label namespace default istio-injection=enabled

# optional: install kiali
kubectl apply -f /istio-*/samples/addons || true
echo "Done. (You can ignore any errors regarding the v1alpha1 dashboard. We don't need it)"

