locals {
  system_asg_config = {
    asg_desired_capacity = "1"
    asg_max_size         = "2"
    asg_min_size         = "1"
    kubelet_label        = "system"
    instance_types       = ["t3.small"]
  }
  app_asg_config = {
    asg_desired_capacity = "2"
    asg_max_size         = "4"
    asg_min_size         = "2"
    kubelet_label        = "application"
    instance_types       = ["c5.large"]
  }

  addons = { for k, v in local.cluster_addons : k => merge(v, { most_recent = true }) }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.9.0"

  create = local.create.eks

  name               = local.cluster_name
  kubernetes_version = local.eks_version

  endpoint_public_access                   = true
  enable_cluster_creator_admin_permissions = true

  iam_role_additional_policies = {
    vpc-cni = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  }

  vpc_id     = var.cc_vpc.id
  subnet_ids = var.cc_vpc.private_subnets

  authentication_mode = "API"
  access_entries      = local.eks_access_entries

  addons = local.addons

  create_node_security_group = false
  node_security_group_id     = var.cc_sg.eks_node
  security_group_additional_rules = {
    fromVpc = {
      cidr_blocks = [var.cc_vpc.cidr]
      description = "Allow all traffic from VPC"
      from_port   = 0
      to_port     = 0
      protocol    = "all"
      type        = "ingress"
    }
  }

  enabled_log_types                      = local.eks_log_types
  cloudwatch_log_group_retention_in_days = 7

  create_kms_key = true

  eks_managed_node_groups = {
    system = {
      ami_type                       = "AL2023_x86_64_STANDARD"
      use_latest_ami_release_version = true
      instance_types                 = local.system_asg_config.instance_types
      labels = {
        instance-group            = local.system_asg_config.kubelet_label
        (local.node_selector_key) = local.system_asg_config.kubelet_label
      }
      iam_role_arn = try(aws_iam_role.eks_nodes[0].arn, "")

      min_size     = local.system_asg_config.asg_min_size
      max_size     = local.system_asg_config.asg_max_size
      desired_size = local.system_asg_config.asg_desired_capacity // ignored after creation
    }
    application = {
      ami_type                       = "AL2023_x86_64_STANDARD"
      use_latest_ami_release_version = true
      instance_types                 = local.app_asg_config.instance_types
      capacity_type                  = "SPOT"
      labels = {
        instance-group            = local.app_asg_config.kubelet_label
        (local.node_selector_key) = local.app_asg_config.kubelet_label
      }
      iam_role_arn = try(aws_iam_role.eks_nodes[0].arn, "")

      min_size     = local.app_asg_config.asg_min_size
      max_size     = local.app_asg_config.asg_max_size
      desired_size = local.app_asg_config.asg_desired_capacity // ignored after creation
    }
  }
}
