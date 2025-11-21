locals {
  create = merge({
    default             = true
    helm_metrics_server = true
    },
    var.k8s_create
  )

  env = var.env

  name_prefix  = local.env.name
  account_id   = local.env.account_id
  region       = local.env.region
  region_short = local.env.region_short

  custom_namespace = "app"

  node_selector_key_escaped = replace(var.k8s_eks.node_selector_key, ".", "\\.")

  chart_versions = {
    metrics-server               = "3.13.0"
    cluster-autoscaler           = "9.52.1"
    aws-load-balancer-controller = "1.16.0"
  }
}
