output "eks" {
  value = {
    cluster_name                       = module.eks.cluster_name
    cluster_endpoint                   = module.eks.cluster_endpoint
    cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
    node_selector_key                  = local.node_selector_key
  }
}

output "irsa" {
  value = {
    cluster-autoscaler           = module.irsa["cluster-autoscaler"].arn
    aws-load-balancer-controller = module.irsa["aws-load-balancer-controller"].arn
  }
}
