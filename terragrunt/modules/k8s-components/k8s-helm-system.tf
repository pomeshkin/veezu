resource "helm_release" "metrics_server" {
  count = local.create.default ? 1 : 0

  name       = "metrics-server"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = local.chart_versions.metrics-server

  max_history = 10

  values = []

  set = [{
    name  = "nodeSelector.${local.node_selector_key_escaped}"
    value = "system"
  }]
}

resource "kubernetes_service_account" "cluster_autoscaler" {
  count = local.create.default ? 1 : 0

  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = var.k8s_irsa.cluster-autoscaler
    }
  }
}

resource "helm_release" "cluster_autoscaler" {
  count = local.create.default ? 1 : 0

  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = local.chart_versions.cluster-autoscaler

  set = [
    {
      name  = "nodeSelector.${local.node_selector_key_escaped}"
      value = "system"
    },
    {
      name  = "autoDiscovery.clusterName"
      value = var.k8s_eks.cluster_name
    },
    {
      name  = "awsRegion"
      value = local.env.region
    },
    {
      name  = "rbac.serviceAccount.create"
      value = false
    },
    {
      name  = "rbac.serviceAccount.name"
      value = kubernetes_service_account.cluster_autoscaler[0].metadata[0].name
    },
    # Required for EKS-managed node groups
    {
      name  = "extraArgs.expander"
      value = "least-waste"
    },
    {
      name  = "extraArgs.skip-nodes-with-system-pods"
      value = "false"
    },
    {
      name  = "extraArgs.skip-nodes-with-local-storage"
      value = "false"
    },
    # Required for AWS
    {
      name  = "extraArgs.balance-similar-node-groups"
      value = "true"
    },
    {
      name  = "extraArgs.scale-down-utilization-threshold"
      value = "0.5"
    }
  ]
}

resource "kubernetes_service_account" "aws_load_balancer_controller" {
  count = local.create.default ? 1 : 0

  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = var.k8s_irsa.aws-load-balancer-controller
    }
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  count = local.create.default ? 1 : 0

  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = local.chart_versions.aws-load-balancer-controller

  set = [
    {
      name  = "clusterName"
      value = var.k8s_eks.cluster_name
    },
    {
      name  = "region"
      value = local.env.region
    },
    {
      name  = "vpcId"
      value = var.k8s_vpc.id
    },
    {
      name  = "serviceAccount.create"
      value = "false"
    },
    {
      name  = "serviceAccount.name"
      value = kubernetes_service_account.aws_load_balancer_controller[0].metadata[0].name
    },
    {
      name  = "replicaCount"
      value = 1
    },
  ]
}
