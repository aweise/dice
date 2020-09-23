resource "helm_release" "istio-init" {
    name = var.istio_init_release_name
    repository = var.istio_repo
    chart = "istio-init"
    namespace = var.istio_namespace
    wait = true
    timeout = 600
    count = 0 
}

resource "helm_release" "istio" {
    name = var.istio_release_name
    repository = var.istio_repo
    chart = "istio"
    namespace = var.istio_namespace
    count = 0

    set {
        name = "global.configValidation"
        value = "false"
    }

    set {
        name = "global.mtls.enabled"
        value = "true"
    }

    set {
        name = "gateways.istio-ingressgateway.sds.enabled"
        value = "false"
    }

    set {
        name = "gateways.istio-egressgateway.enabled"
        value = "true"
    }

    depends_on = [helm_release.istio-init]
}
