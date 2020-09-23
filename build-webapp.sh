#!/bin/bash
# Build and push an app image
app=dice-app
tag=${1:-latest}
min=${2:-1}
max=${3:-6}

source ${CONFIG}
echo Building and pushing ${app}:${tag} to repo ${ECR_REPOSITORY}
(cd app && \
    docker build \
        -t ${app}:${tag} .)
    aws --profile ${ECR_PROFILE} --region ${ECR_REGION}  \
   ecr get-login-password | \
   docker login -u AWS --password-stdin https://${ECR_REPOSITORY}
docker tag ${app}:${tag} ${ECR_REPOSITORY}/${app}:${tag}
docker push ${ECR_REPOSITORY}/${app}:${tag}
