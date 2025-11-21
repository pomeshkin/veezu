resource "kubernetes_namespace" "custom" {
  count = local.create.default ? 1 : 0

  metadata {
    name = local.custom_namespace

    labels = {
      "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled"
    }
  }
}

