data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.${local.aws_dns_suffix}"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  count = local.create.iam ? 1 : 0

  name               = "${local.name_prefix}-ec2-default-${local.region_short}"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

}


resource "aws_iam_role_policy_attachment" "ec2" {
  count = local.create.iam ? 1 : 0

  role       = aws_iam_role.ec2[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy"
}

resource "aws_iam_instance_profile" "ec2" {
  count = local.create.iam ? 1 : 0

  name = "${local.name_prefix}-ec2-default-${local.region_short}"
  role = aws_iam_role.ec2[0].name
}
