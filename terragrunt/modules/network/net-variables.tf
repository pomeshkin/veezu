variable "env" {
  type = any
}

variable "network_create" {
  type    = map(string)
  default = {}
}

variable "network_vpc_cidr" {
  type = string
}

variable "network_vpc_azs" {
  type = list(string)
}

variable "network_vpc_public_subnets" {
  type = list(string)
}

variable "network_vpc_private_subnets" {
  type = list(string)
}

variable "network_route53" {
  type = any
}

variable "default_tags" {
  type    = map(string)
  default = {}
}
