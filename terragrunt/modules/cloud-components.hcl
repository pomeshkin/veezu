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

inputs = {
  cc_vpc = dependency.network.outputs.vpc
  cc_sg  = dependency.network.outputs.sg
  cc_iam = dependency.basement.outputs.iam
}
