locals {
  create = merge({
    default = true
    eks     = true
    },
    var.cc_create
  )

  env = var.env

  name_prefix  = local.env.name
  account_id   = local.env.account_id
  region       = local.env.region
  region_short = local.env.region_short

  cluster_name = "${local.name_prefix}-${local.region}"

  eks_version = var.eks_version

  node_selector_key = "node.kubernetes.io/instance-group"

  cluster_addons = {
    coredns = {
      configuration_values = jsonencode({
        replicaCount = 1 # for testing purposes. Should be > 1 for prod
        nodeSelector = {
          (local.node_selector_key) = local.system_asg_config.kubelet_label
        }
      })
    }

    kube-proxy = {}
    // eks-pod-identity-agent = {}
    vpc-cni = {
      before_compute              = true
      service_account_role_arn    = module.irsa["vpc-cni"].arn
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"

      configuration_values = jsonencode({
        enableNetworkPolicy = "true"
        env = {
          ENABLE_POD_ENI                    = "true"
          POD_SECURITY_GROUP_ENFORCING_MODE = "standard",
          WARM_IP_TARGET                    = "2" // https://docs.aws.amazon.com/eks/latest/best-practices/vpc-cni.html
        }
        nodeAgent = {
          enablePolicyEventLogs = "true",
        },
      })
    }
  }

  asg_metrics_list = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

  eks_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler",
  ]

  eks_access_entries = merge(
    {
      node = {
        principal_arn = try(aws_iam_role.eks_nodes[0].arn, "")
        type          = "EC2_LINUX"
      },
    },
    {
      root = {
        kubernetes_groups = []
        principal_arn     = "arn:aws:iam::533267016219:root" // just for POC

        policy_associations = {
          cluster_admin = {
            policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
            access_scope = {
              type = "cluster"
            }
          }
        }
      }
    },
  )

  autoscaling_group_tags = {
    "k8s.io/cluster-autoscaler/enabled"               = true,
    "k8s.io/cluster-autoscaler/${local.cluster_name}" = "owned",
  }
}
