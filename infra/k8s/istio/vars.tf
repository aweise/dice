# Terraform variables. You should not need to change these.

variable "kubeconfig" {
    description = "Path to the kubernetes configuration file (default: ~/.kube/config)"
    default = "~/.kube/config"
    type = string
}

variable "istio_release_name" {
    description = "Helm release of Istio"
    default = "istio"
    type = string
}

variable "istio_init_release_name" {
    description = "Helm release of Istio-init"
    default = "istio-init"
    type = string
}

variable "istio_repo" {
    description = "Istio helm repository URL"
    default = "https://storage.googleapis.com/istio-release/releases/1.3.5/charts/"
    type = string
}

variable "istio_namespace" {
    description = "Namespace in which to deploy Istio"
    default = "istio-system"
    type = string
}
