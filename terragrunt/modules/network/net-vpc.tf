module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.1"

  create_vpc           = local.create.vpc
  name                 = local.name_prefix
  cidr                 = var.network_vpc_cidr
  azs                  = var.network_vpc_azs
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnets  = var.network_vpc_public_subnets
  private_subnets = var.network_vpc_private_subnets

  map_public_ip_on_launch = true

  enable_nat_gateway     = local.create.vpc_nat_gw
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
}

output "vpc" {
  value = {
    id                      = module.vpc.vpc_id
    cidr                    = module.vpc.vpc_cidr_block
    azs                     = module.vpc.azs
    public_subnets          = module.vpc.public_subnets
    private_subnets         = module.vpc.private_subnets
    private_route_table_ids = module.vpc.private_route_table_ids
    public_route_table_ids  = module.vpc.public_route_table_ids
  }
}
