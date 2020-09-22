# dice
Demo of k8s setup on AWS with Istio and Spinnaker

## Prerequisites

### Docker
The installation instructions assume that you have a working installation of Docker. If you want to run without Docker, you will have to make sure to use compatible versions of any required third-party tools, including:

* kubectl
* kops
* helm
* jq
* halyard
* istioctl

Verify your Docker installation:

	$ docker run alpine /bin/echo 'Good to go!'
	Good to go!

### AWS
You will also need an AWS account with a user who can create and manage policies, roles and other users. IAMFullAccess should be sufficient, but more restrictive policies may work as well.

We need to configure a profile named `dice` for this user in AWS CLI:

	$ aws configure --profile dice
	# enter your credentials and region, then verify like this:

	$ aws --profile dice sts get-caller-identity
	{
		"UserId": "AIDA...",
		"Account": "...",
		"Arn": "arn:aws:iam::...:user/..."
	}

Your account should have a Hosted Zone in Route 53 for the domain in which you want to host the k8s cluster. E.g. if your cluster is to be called `dice.example.com`, you should have a Route 53 Hosted Zone for `example.com`. Verify your DNS setup:

	$ aws route53 list-hosted-zones | jq '.HostedZones[] | select(.Name == "example.com.") | .Id'  # note the extra dot at the end of the domain name
	"/hostedzone/..."

	$ dig +short NS example.com
	ns-1.awsdns-1.org.
	ns-2.awsdns-2.net.
	ns-3.awsdns-3.com.
	ns-4.awsdns-4.co.uk.

### SSH Keypair
`kops` needs to use an SSH keypair to manage the EC2 instances of the kubernetes cluster. You can either configure dice to use an existing RSA keypair in [config.env](config.env), or create a new one like this:

	$ ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_kops

## Installation

### Toolbox docker image
Adjust the values in [config.env](config.env) to your environment and run 

	$ make toolbox

to build the `dice-toolbox` Docker image. This contains all required tools for the rest of the deployment. Note: Building the toolbox explicitly is technically optional, as it will be pulled in automatically by the following make targets.

### Provision IAM user and state bucket

Next, run

	$ make kops-admin

to prepare an IAM user and a state bucket for `kops`. This step uses [Terraform](https://www.terraform.io/) for reproducible provisioning. Note that the generated credentials are shown on the terminal and stored in the terraform state file (we need those later). In a production setup you would want to hide them and store them in a safe place instead, e.g. in an S3 object with appropriate permissions.

### Kubernetes cluster

While [kops](https://https://kops.sigs.k8s.io/) is a popular and convenient cluster management tool, it does not play too nicely in a pure infrastructure-as-code environment. A major concern in such a setup is that kops uses an action-based CLI model. This contrasts with the more state-description model that is typical for many IaC tools (Terraform, Ansible, CloudFormation, etc). For simplicity, we will resort to a set of simple shell scripts, which are run within a toolbox container to orchestrate kops. Given enough time, fancier options would include
* a custom Terraform provider,
* improved state detection and error handling in the provided shell scripts, or
* cloud-based installation, e.g. using CloudFormation or the Code* family of AWS services.

tl/dr; Create the kubernetes cluster by running

	$ make k8s-cluster

and be aware that this is not strictly idempotent.
