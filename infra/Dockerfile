FROM ubuntu:focal
ENV tfver 0.13.3
RUN apt update && apt install -y curl unzip jq

RUN curl https://releases.hashicorp.com/terraform/${tfver}/terraform_${tfver}_linux_amd64.zip -o tf.zip && unzip tf.zip && rm tf.zip && mv terraform /usr/local/bin

