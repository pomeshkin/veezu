terraform {
  required_version = "~> 1.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.1.1"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.19.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.2"
    }
  }
}

provider "aws" {
  profile             = local.env.account_name
  region              = local.env.region
  allowed_account_ids = [local.env.account_id]

  default_tags {
    tags = var.default_tags
  }
}

provider "helm" {
  kubernetes = {
    host                   = var.k8s_eks.cluster_endpoint
    cluster_ca_certificate = base64decode(var.k8s_eks.cluster_certificate_authority_data)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["--profile", local.env.account_name, "eks", "get-token", "--cluster-name", var.k8s_eks.cluster_name, "--region", local.env.region]
    }
  }
}

provider "kubernetes" {
  host                   = var.k8s_eks.cluster_endpoint
  cluster_ca_certificate = base64decode(var.k8s_eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["--profile", local.env.account_name, "eks", "get-token", "--cluster-name", var.k8s_eks.cluster_name, "--region", local.env.region]
  }
}

provider "kubectl" {
  host                   = var.k8s_eks.cluster_endpoint
  cluster_ca_certificate = base64decode(var.k8s_eks.cluster_certificate_authority_data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["--profile", local.env.account_name, "eks", "get-token", "--cluster-name", var.k8s_eks.cluster_name, "--region", local.env.region]
  }
}
