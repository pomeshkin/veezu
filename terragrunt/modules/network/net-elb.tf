module "alb_ext" {
  source  = "terraform-aws-modules/alb/aws"
  version = "10.2.0"

  create                = local.create.elb && local.create.sg
  create_security_group = false

  idle_timeout    = 60
  internal        = false
  ip_address_type = "ipv4"

  name    = "${local.name_prefix}-ext"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  security_groups = aws_security_group.alb_ext.*.id

  listeners = {
    ex-http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    ex-https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = local.acm_certificate_arn

      forward = {
        target_group_key = "ex-app"
      }
    }
  }

  target_groups = {
    ex-app = {
      name                 = "${local.name_prefix}-app"
      protocol             = "HTTP"
      port                 = 3000
      deregistration_delay = 0
      target_type          = "ip"
      vpc_id = module.vpc.vpc_id
      create_attachment = false
      health_check = {
        enabled             = true
        interval            = 5
        path                = "/probe/data"
        port                = "traffic-port"
        healthy_threshold   = 5
        unhealthy_threshold = 2
        timeout             = 3
        protocol            = "HTTP"
        matcher             = "200-399"
      }
    }
  }

  tags = {}
}

resource "aws_route53_record" "alb_ext" {
  count = local.create.elb ? 1 : 0

  zone_id = local.route53_zone_id_public
  name    = local.route53_zone_name_public
  type    = "A"

  alias {
    name                   = module.alb_ext.dns_name
    zone_id                = module.alb_ext.zone_id
    evaluate_target_health = true
  }
}
