FROM fedora:32
ENV tfver 0.13.3

# Base utils
RUN yum install -y curl unzip jq awscli

# Terraform
RUN curl https://releases.hashicorp.com/terraform/${tfver}/terraform_${tfver}_linux_amd64.zip -o tf.zip && unzip tf.zip && rm tf.zip && mv terraform /usr/local/bin

# kops
RUN curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64 && chmod +x kops-linux-amd64 && mv kops-linux-amd64 /usr/local/bin/kops

