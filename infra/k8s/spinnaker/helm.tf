resource "helm_release" "spinnaker" {
    name = var.spinnaker_release_name
    repository = var.spinnaker_repo
    chart = "spinnaker"
    namespace = var.spinnaker_namespace
    wait = true
    timeout = 600

#    set {
#        name = "key"
#        value = "true"
#    }

}
