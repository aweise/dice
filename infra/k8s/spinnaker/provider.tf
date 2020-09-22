
terraform {
    required_providers {
        helm = {
            source = "hashicorp/helm"
            version = "~> 1.3.0"
        }
        kubernetes = {
            source = "hashicorp/kubernetes"
            version = "~> 1.13.2"
        }
    }
}

provider "helm" {
    kubernetes {
        config_path = var.kubeconfig
    }
}

provider "kubernetes" {
    load_config_file = "true"
}
