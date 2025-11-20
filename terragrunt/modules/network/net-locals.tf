locals {
  create = merge({
    default    = true
    acm        = true
    elb        = true
    route53    = true
    sg         = true
    vpc        = true
    vpc_nat_gw = true
    },
    var.network_create
  )

  env = var.env

  name_prefix  = local.env.name
  account_id   = local.env.account_id
  region       = local.env.region
  region_short = local.env.region_short

  route53                  = var.network_route53
  route53_zone_id_public   = local.route53.zone_id_public
  route53_zone_name_public = local.route53.zone_name_public
  route53_zone_id_private  = concat(aws_route53_zone.private.*.id, [""])[0]
}
