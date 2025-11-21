output "sg" {
  value = {
    alb_ext     = try(aws_security_group.alb_ext[0].id, "")
    eks_pod_app = try(aws_security_group.eks_pod_app[0].id, "")
    eks_node    = try(aws_security_group.eks_node[0].id, "")
  }
}
