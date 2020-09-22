#!/bin/bash

# Install kubernetes dashboar to the cluster (per: https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md)
# This should not be run directly. Instead, use "make dashboard" to run this in Docker.
. /config

here=$(dirname $(readlink -f "$0"))

echo Optional: Install dashboard.
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata: 
  name: admin-user
  namespace: kubernetes-dashboard
EOF
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata: 
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

echo Access token:
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')

echo Go ahead and open this link in your web browser:
echo    "http://localhost:9898/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/."

echo kubectl proxy -p 9898
