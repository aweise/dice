. /config
cat dice-app.yaml | sed s/+REPO+/${ECR_REPOSITORY}/g | kubectl apply -f -
kubectl describe deployment dice-app-stable
kubectl describe deployment dice-app-canary
