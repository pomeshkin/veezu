locals {
  target_group_arn   = var.k8s_alb_ext.target_groups.ex-app.arn
  app_security_group = var.k8s_sg.eks_pod_app
  app_name           = "chaotic-backend"
}

resource "helm_release" "app_prerequirements" {
  count = local.create.default ? 1 : 0

  name      = "app-prerequirements"
  namespace = kubernetes_namespace.custom[0].metadata[0].name

  chart = "${var.terragrunt_dir}/helm/app-prerequirements"

  force_update = true
  replace      = true // do not use in prod

  values = [
    templatefile("${path.module}/templates/app-prerequirements-values.yaml.tmpl", {
      targetGroupArn  = local.target_group_arn
      securityGroupId = local.app_security_group
      appName         = local.app_name
    })
  ]
}

resource "helm_release" "app" {
  count = local.create.default ? 1 : 0

  name      = "app"
  namespace = kubernetes_namespace.custom[0].metadata[0].name

  chart = "${var.terragrunt_dir}/helm/app"

  force_update = true
  replace      = true // do not use in prod

  values = [
    templatefile("${path.module}/templates/app-values.yaml.tmpl", {
      appName  = local.app_name
      replicas = 3
    })
  ]

  depends_on = [helm_release.app_prerequirements]
}
