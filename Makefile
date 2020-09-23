CONFIG?=$$(pwd)/infra/config.env

.PHONY: help toolbox kops-admin k8s-cluster charts istio spinnaker dashboard build-webapp-stable build-webapp-canary build-webapp deploy-webapp verify-webapp


help: ## Print a list of available make targets
	@echo -e "\\x1b[37;1mMake targets:\\x1b[m\n\n$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[32m\1\\x1b[m:\2/' | column -c2 -t -s :)\n"

toolbox: $(shell find infra/)  ## Bake a docker image with all required tools in matching versions.
	(cd infra && docker build -t dice-toolbox:latest .)

kops-admin: toolbox $(shell find infra/aws) ## Use terraform in a dice-toolbox container to create an IAM user for kops.
	docker run \
	    -v $$(pwd)/infra/aws/:/infra \
	    -v $(HOME)/.aws:/root/.aws \
	    -v $(CONFIG):/config \
	    -ti dice-toolbox bash -c \
	    "cd /infra && chmod +x create-kops-user.sh && ./create-kops-user.sh"

k8s-cluster: toolbox  ## Use kops in a dice-toolbox container to provision a k8s cluster.
	mkdir -p ~/.kube
	docker run \
	    -v $$(pwd)/infra/:/infra \
	    -v $(HOME)/.aws:/root/.aws \
	    -v $(HOME)/.ssh:/root/.ssh \
	    -v $(HOME)/.kube:/root/.kube \
	    -v $(CONFIG):/config \
	    -ti dice-toolbox bash -c \
	    "cd /infra/k8s && chmod +x create-cluster.sh && ./create-cluster.sh"

charts: spinnaker istio ## Use terraform in a dice-toolbox container to deploy the helm charts

spinnaker:  toolbox  ## Use terraform with the helm provider to deploy spinnaker
	mkdir -p ~/.helm
	docker run \
	    -v $$(pwd)/infra/:/infra \
	    -v $(HOME)/.kube:/root/.kube \
	    -v $(HOME)/.helm:/root/.helm \
	    -v $(CONFIG):/config \
	    -ti dice-toolbox bash -c \
	    "cd /infra/k8s && chmod +x install-spinnaker.sh && ./install-spinnaker.sh"

istio:  toolbox  ## Use terraform with the helm provider to deploy spinnaker
	mkdir -p ~/.helm
	docker run \
	    -v $$(pwd)/infra/:/infra \
	    -v $(HOME)/.kube:/root/.kube \
	    -v $(HOME)/.helm:/root/.helm \
	    -v $(CONFIG):/config \
	    -ti dice-toolbox bash -c \
	    "cd /infra/k8s && chmod +x install-istio.sh && ./install-istio.sh"

destroy-cluster: toolbox  ## Destroy the k8s cluster with all contents
	docker run \
	    -v $$(pwd)/infra/:/infra \
	    -v $(HOME)/.aws:/root/.aws \
	    -v $(HOME)/.ssh:/root/.ssh \
	    -v $(HOME)/.kube:/root/.kube \
	    -v $(CONFIG):/config \
	    -ti dice-toolbox bash -c \
	    "cd /infra/k8s && chmod +x destroy-cluster.sh && ./destroy-cluster.sh"

dashboard: toolbox  ## Optional - deploy kubernetes dashboard
	docker run \
	    -v $$(pwd)/infra/:/infra \
	    -v $(HOME)/.aws:/root/.aws \
	    -v $(HOME)/.ssh:/root/.ssh \
	    -v $(HOME)/.kube:/root/.kube \
	    -v $(CONFIG):/config \
	    -p 9898:9898 \
	    -ti dice-toolbox bash -c \
	    "cd /infra/k8s && chmod +x install-dashboard.sh && ./install-dashboard.sh"

build-webapp-stable: build-webapp.sh $(shell find app/)  ## Build and push the stable version of the web app to ECR
	./build-webapp.sh stable 1 6

build-webapp-canary: build-webapp.sh $(shell find app/)  ## Build and push the canary version of the web app to ECR
	./build-webapp.sh canary 10 20

build-webapp: build-webapp-stable build-webapp-canary

deploy-webapp: toolbox $(shell find app/)  ## Deploy the app to the cluster
	docker run \
	    -v $$(pwd)/infra/:/infra \
	    -v $$(pwd)/app/:/app \
	    -v $(HOME)/.aws:/root/.aws \
	    -v $(HOME)/.ssh:/root/.ssh \
	    -v $(HOME)/.kube:/root/.kube \
	    -v $(CONFIG):/config \
	    -ti dice-toolbox bash -c \
	    "cd /app && chmod +x deploy-app.sh && ./deploy-app.sh"

verify-webapp: # toolbox  ## Get some output from the demo app
	docker run \
	    -v $$(pwd)/infra/:/infra \
	    -v $$(pwd)/app/:/app \
	    -v $(HOME)/.aws:/root/.aws \
	    -v $(HOME)/.ssh:/root/.ssh \
	    -v $(HOME)/.kube:/root/.kube \
	    -v $(CONFIG):/config \
	    -ti dice-toolbox bash -c \
	    "(kubectl port-forward deployment/dice-app-stable 80:80 >/dev/null &); \
	    (kubectl port-forward deployment/dice-app-canary 81:80 >/dev/null &); \
	    (kubectl port-forward service/dice-app 82:80 >/dev/null &); \
	    sleep 2; \
	    curl --no-progress-meter http://localhost:80/ | jq '.result'; \
	    curl --no-progress-meter http://localhost:81/ | jq '.result'; \
	    curl --no-progress-meter http://localhost:82/ | jq '.result'"
