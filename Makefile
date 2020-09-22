.PHONY: toolbox kops-admin

# Bake a Docker image with all required tools in matching versions.
# This way we reduce dependencies on the environment where make is run.
toolbox: $(shell find infra/)
	(cd infra && docker build -t dice-toolbox:latest .)

# Use terraform in a dice-toolbox container to create an IAM user for kops.
kops-admin: toolbox $(shell find infra/aws/*.tf)
	docker run \
	    -v $$(pwd)/infra/:/infra \
	    -v $(HOME)/.aws:/root/.aws \
	    -ti dice-toolbox bash -c \
	    "cd /infra/aws && terraform init && terraform apply"
