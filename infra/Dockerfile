# dice-toolbox image with required tools for deploying dice

FROM fedora:32
ENV tfver 0.13.3
ENV helmver 2.16.12
ENV helmrepo https://kubernetes-charts.storage.googleapis.com/
ENV ISTIO_VERSION=1.7.2

# k8s yum repo
COPY kubernetes.repo /etc/yum.repos.d/

# Base utils
RUN yum install -y curl unzip jq awscli kubectl

# Terraform
RUN curl https://releases.hashicorp.com/terraform/${tfver}/terraform_${tfver}_linux_amd64.zip -o tf.zip && \
    unzip tf.zip && \
    rm tf.zip && \
    mv terraform /usr/local/bin

# kops
RUN curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64 && \
    chmod +x kops-linux-amd64 && \
    mv kops-linux-amd64 /usr/local/bin/kops

# helm
RUN curl https://get.helm.sh/helm-v${helmver}-linux-amd64.tar.gz -o helm.tar.gz && \
    tar xzvf helm.tar.gz && \
    mv linux-amd64/helm linux-amd64/tiller /usr/local/bin && \
    chmod +x /usr/local/bin/helm && \
    rm -rf helm.tar.gz linux-amd64/

RUN curl -L https://istio.io/downloadIstio | sh - && \
    chmod +x istio-${ISTIO_VERSION}/bin/istioctl && \
    mv istio-${ISTIO_VERSION}/bin/istioctl /usr/local/bin/
