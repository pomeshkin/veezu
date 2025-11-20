locals {
  // Create Route53 zone for internal endpoints
  route53_zone_name_private = "${local.name_prefix}.${local.region}.local"
}

resource "aws_route53_zone" "private" {
  count = local.create.route53 && local.create.vpc ? 1 : 0

  name = local.route53_zone_name_private
  vpc {
    vpc_id = module.vpc.vpc_id
  }
}

output "route53" {
  value = {
    zone_id_private   = local.route53_zone_id_private
    zone_name_private = local.route53_zone_name_private
    zone_id_public    = local.route53_zone_id_public
    zone_name_public  = local.route53_zone_name_public
  }
}
