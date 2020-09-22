#FROM ubuntu:focal
FROM fedora:32
ENV tfver 0.13.3
#RUN yum update -y &&
RUN yum install -y curl unzip jq awscli

RUN curl https://releases.hashicorp.com/terraform/${tfver}/terraform_${tfver}_linux_amd64.zip -o tf.zip && unzip tf.zip && rm tf.zip && mv terraform /usr/local/bin

