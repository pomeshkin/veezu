dependency "basement" {
  config_path = "../basement"

  skip_outputs                            = tobool(get_env("TG_SKIP_OUTPUTS", "false"))
  mock_outputs_allowed_terraform_commands = ["init", "validate"]
  mock_outputs = {
    iam = {}
  }
}

dependency "network" {
  config_path = "../network"

  skip_outputs                            = tobool(get_env("TG_SKIP_OUTPUTS", "false"))
  mock_outputs_allowed_terraform_commands = ["init", "validate"]
  mock_outputs = {
    vpc = {}
    sg  = {}
  }
}

dependency "cloud-components" {
  config_path = "../cloud-components"

  skip_outputs                            = tobool(get_env("TG_SKIP_OUTPUTS", "false"))
  mock_outputs_allowed_terraform_commands = ["init", "validate"]
  mock_outputs = {
    eks  = {}
    irsa = {}
  }
}

inputs = {
  k8s_eks     = dependency.cloud-components.outputs.eks
  k8s_irsa    = dependency.cloud-components.outputs.irsa
  k8s_vpc     = dependency.network.outputs.vpc
  k8s_alb_ext = dependency.network.outputs.alb_ext
  k8s_sg      = dependency.network.outputs.sg
}
