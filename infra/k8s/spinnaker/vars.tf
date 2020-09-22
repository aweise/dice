# Terraform variables. You should not need to change these.

variable "kubeconfig" {
    description = "Path to the kubernetes configuration file (default: ~/.kube/config)"
    default = "~/.kube/config"
    type = string
}

variable "spinnaker_release_name" {
    description = "Helm release of Spinnaker"
    default = "spinnaker"
    type = string
}

variable "spinnaker_namespace" {
    description = "Namespace in which to deploy Spinnaker"
    default = "default"
    type = string
}

variable "spinnaker_repo" {
    description = "URL of the chart repository"
    default = "https://kubernetes-charts.storage.googleapis.com"
    type = string
}
