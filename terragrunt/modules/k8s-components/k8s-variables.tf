variable "k8s_create" {
  type    = map(string)
  default = {}
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "env" {
  type = any
}

variable "k8s_eks" {
  type = any
}

variable "k8s_irsa" {
  type = any
}

variable "k8s_vpc" {
  type = any
}

variable "k8s_alb_ext" {
  type = any
}

variable "k8s_sg" {
  type = any
}

variable "terragrunt_dir" {
  type = string
}