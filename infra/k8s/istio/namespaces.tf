resource "kubernetes_namespace" "istio-system" {
    metadata {
        name = var.istio_namespace
    }
}
