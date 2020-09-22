CONFIG?=$$(pwd)/infra/config.env

.PHONY: help toolbox kops-admin k8s-cluster charts istio spinnaker dashboard


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

dashboard: toolbox  ## Optional: deploy kubernetes dashboard
	docker run \
	    -v $$(pwd)/infra/:/infra \
	    -v $(HOME)/.aws:/root/.aws \
	    -v $(HOME)/.ssh:/root/.ssh \
	    -v $(HOME)/.kube:/root/.kube \
	    -v $(CONFIG):/config \
	    -p 9898:9898 \
	    -ti dice-toolbox bash -c \
	    "cd /infra/k8s && chmod +x install-dashboard.sh && ./install-dashboard.sh"

