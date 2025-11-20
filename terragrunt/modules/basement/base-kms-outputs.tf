output "kms" {
  value = {
    keys = {
      ebs = {
        target_key_arn = concat(aws_kms_alias.ebs.*.target_key_arn, [""])[0]
        alias_arn      = concat(aws_kms_alias.ebs.*.arn, [""])[0]
      }
    }
  }
}
