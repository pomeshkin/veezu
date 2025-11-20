output "sg" {
  value = {
    alb_ext = try(aws_security_group.alb_ext[0].id, "")
  }
}
