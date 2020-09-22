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

while ! terraform apply ${TF_OPTS};
do 
    counter=$((counter + 1))
    echo Terraform failed ${counter} times.
    echo This may be caused by an Istio race condition.
    if [[ "x${counter}" == "x2" ]]; then
        echo Giving up.
        exit 1;
    else
        echo Retrying in ${DELAY} seconds.
        sleep ${DELAY}
        TF_OPTS=-auto-approve
    fi;
done

