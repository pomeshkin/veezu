variable "cc_vpc" {
  type = any
}

variable "cc_create" {
  type    = map(string)
  default = {}
}

variable "cc_sg" {
  type    = map(string)
  default = {}
}

variable "cc_iam" {
  type = any
}

variable "cc_eks_node_type" {
  type    = string
  default = "t3.small"
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "env" {
  type = any
}

variable "eks_version" {
  type    = string
  default = "1.34"
}
