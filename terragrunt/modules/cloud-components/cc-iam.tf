data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_nodes" {
  count = local.create.eks ? 1 : 0

  name               = "${local.cluster_name}-eks-nodes"
  description        = "EKS ${local.cluster_name} cluster nodes role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "eks_nodes" {
  for_each = toset(local.create.eks ? [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ] : [])

  role       = aws_iam_role.eks_nodes[0].name
  policy_arn = each.key
}

resource "aws_iam_instance_profile" "eks_nodes" {
  count = local.create.eks ? 1 : 0

  name = aws_iam_role.eks_nodes[0].name
  role = aws_iam_role.eks_nodes[0].name
}

locals {
  iam_roles_for_service_accounts = {
    vpc-cni = {
      attach_vpc_cni_policy = true
      vpc_cni_enable_ipv4   = true
      service_account       = "aws-node"
      policies = {
        AmazonEKSVPCResourceController = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
      }
    }

    cluster-autoscaler = {
      attach_cluster_autoscaler_policy = true
      cluster_autoscaler_cluster_names = [local.cluster_name]
    }

    aws-load-balancer-controller = {
      attach_load_balancer_controller_policy                          = true
      attach_load_balancer_controller_targetgroup_binding_only_policy = false
    }
  }
}

module "irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "6.2.3"

  for_each = local.iam_roles_for_service_accounts

  create = local.create.eks

  name            = "${local.cluster_name}-irsa-${each.key}"
  policy_name     = "${local.cluster_name}-irsa-${each.key}"
  use_name_prefix = false

  attach_vpc_cni_policy = try(each.value.attach_vpc_cni_policy, false)
  vpc_cni_enable_ipv4   = try(each.value.vpc_cni_enable_ipv4, false)

  attach_cluster_autoscaler_policy = try(each.value.attach_cluster_autoscaler_policy, false)
  cluster_autoscaler_cluster_names = try(each.value.cluster_autoscaler_cluster_names, [])

  attach_load_balancer_controller_policy                          = try(each.value.attach_load_balancer_controller_policy, false)
  attach_load_balancer_controller_targetgroup_binding_only_policy = try(each.value.attach_load_balancer_controller_targetgroup_binding_only_policy, false)

  policies = lookup(each.value, "policies", {})

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${try(each.value.namespace, "kube-system")}:${try(each.value.service_account, each.key)}"]
    }
  }
}
