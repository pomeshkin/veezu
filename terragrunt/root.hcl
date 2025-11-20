inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
  {
    env = {
      name                     = local.env
      account_id               = local.account_id
      account_name             = local.account_name
      region                   = local.aws_region
      region_short             = local.aws_region_short
      route53_zone_name_public = local.route53_zone_name_public
      #
      layer = local.layer
      #
      is_prod = local.is_prod
    },
    #
    network_vpc_cidr            = local.network_vpc_cidr
    network_vpc_azs             = formatlist("${local.aws_region}%s", local.aws_regions[local.aws_region]["azs"])
    network_vpc_public_subnets  = local.network_vpc_public_subnets
    network_vpc_private_subnets = local.network_vpc_private_subnets
    #
    default_tags = local.default_tags
  },
)

terraform {
  source = "${path_relative_from_include("root")}/modules//${basename(get_terragrunt_dir())}///"

  after_hook "terraform_lock" {
    # removing auto-copied .terraform.lock.hcl file
    commands = ["init"]
    execute  = ["rm", "-f", "${get_terragrunt_dir()}/.terraform.lock.hcl"]
  }
}

remote_state {
  backend = "s3"

  config = {
    profile        = local.account_name
    encrypt        = true
    bucket         = "terraform-state-${local.account_id}"
    key            = "terragrunt/${local.source_path}.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }

  generate = {
    path      = "tg-backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

generate "backend" {
  path      = "tg-backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "s3" {
    bucket         = "terraform-state-${local.account_id}"
    key            = "terragrunt/${local.source_path}.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = true
  }
}
EOF
}

locals {
  layer      = basename(path_relative_to_include())                   # basement/network/etc.
  aws_region = basename(dirname(path_relative_to_include()))          # us-east-1/eu-central-1
  env        = basename(dirname(dirname(path_relative_to_include()))) # dev/test/demo/prod

  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  account_id       = local.account_vars.locals.account_id
  account_name     = local.account_vars.locals.account_name
  aws_region_short = local.aws_regions[local.aws_region]["name_short"]

  is_prod = try(local.account_vars.locals.is_prod, false)

  route53_zone_name_public = local.account_vars.locals.basement_route53_zone_name_public

  source_path = "envs/${local.env}/${local.aws_region}/${local.layer}"

  default_tags = {
    sourcePath = local.source_path
    env        = local.env
  }

  network_vpc_cidr              = local.aws_regions[local.aws_region]["vpc_cidr"] # 10.x.0.0/16
  network_vpc_private_block_all = cidrsubnet(local.network_vpc_cidr, 1, 0)        # 10.x.0.0/17
  network_vpc_public_block_all  = cidrsubnet(local.network_vpc_cidr, 1, 1)        # 10.x.128.0/17

  network_vpc_private_block = cidrsubnet(local.network_vpc_private_block_all, 1, 0) # 10.x.0-63.0/18
  network_vpc_public_block  = cidrsubnet(local.network_vpc_public_block_all, 3, 0)  # 10.x.128.0/17 > 10.x.128.0/20

  network_vpc_public_subnets = [
    cidrsubnet(local.network_vpc_public_block, 4, 0), # /24
    cidrsubnet(local.network_vpc_public_block, 4, 1),
    cidrsubnet(local.network_vpc_public_block, 4, 2),
  ]
  network_vpc_private_subnets = [
    cidrsubnet(local.network_vpc_private_block, 3, 0), # /21
    cidrsubnet(local.network_vpc_private_block, 3, 1),
    cidrsubnet(local.network_vpc_private_block, 3, 2),
  ]

  aws_regions = {
    #
    # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html#Concepts.RegionsAndAvailabilityZones.Regions
    #
    eu-central-1 = {
      vpc_cidr   = "10.0.0.0/16"
      location   = "Europe (Frankfurt)"
      name_short = "euc1"
      azs        = ["a", "b", "c"]
    }
    us-east-1 = {
      vpc_cidr   = "10.1.0.0/16"
      location   = "US East (N. Virginia)"
      name_short = "use1"
      azs        = ["a", "b", "c"]
    }
  }
}
