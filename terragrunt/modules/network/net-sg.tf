# External Load Balancer

resource "aws_security_group" "alb_ext" {
  count = local.create.sg ? 1 : 0

  name        = "${local.name_prefix}-alb-ext"
  description = "ALB external"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "Managed by Terraform: HTTP from internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Managed by Terraform: HTTPs from internet"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description = "Managed by Terraform: All traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { "Name" : "${local.name_prefix}-alb-ext" }
}

# Application pod
resource "aws_security_group" "eks_pod_app" {
  count = local.create.sg ? 1 : 0

  name        = "${local.name_prefix}-eks-pod-app"
  description = "EKS application pod"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Managed by Terraform: HTTP from internet"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = aws_security_group.alb_ext.*.id
  }

  egress {
    description = "Managed by Terraform: All traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { "Name" : "${local.name_prefix}-eks-pod-app" }
}

# EKS node

resource "aws_security_group" "eks_node" {
  count = local.create.sg ? 1 : 0

  name        = "${local.name_prefix}-eks-node"
  description = "Security group for EKS nodes"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-eks-node"
  }
}
