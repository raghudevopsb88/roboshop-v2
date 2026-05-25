resource "null_resource" "kubeconfig" {
  depends_on = [aws_eks_node_group.main]

  triggers = {
    cluster = aws_eks_cluster.main.name
  }

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${aws_eks_cluster.main.name} --region ${data.aws_region.current.name}"
  }
}

data "aws_region" "current" {}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

locals {
  traefik_values = var.acm_certificate_arn != "" ? templatefile("${path.module}/traefik.yml.tpl", {
    acm_certificate_arn = var.acm_certificate_arn
  }) : file("${path.module}/traefik-minimal.yml")
  argocd_domain     = var.dns_domain != "" ? "argocd-${var.env}.${trim(var.dns_domain, ".")}" : "argocd-${var.env}.local"
  prometheus_domain = var.dns_domain != "" ? "prometheus-${var.env}.${trim(var.dns_domain, ".")}" : "prometheus-${var.env}.local"

  cluster_autoscaler_sets = [
    { name = "autoDiscovery.clusterName", value = aws_eks_cluster.main.name },
    { name = "awsRegion", value = data.aws_region.current.name },
    { name = "rbac.serviceAccount.name", value = "cluster-autoscaler" },
    { name = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn", value = aws_iam_role.cluster_autoscaler.arn },
    { name = "extraArgs.balance-similar-node-groups", value = "true" },
    { name = "extraArgs.skip-nodes-with-system-pods", value = "false" },
  ]

  external_dns_sets = concat([
    { name = "serviceAccount.name", value = "external-dns" },
    { name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn", value = aws_iam_role.external_dns.arn },
    { name = "provider", value = "aws" },
    { name = "policy", value = "sync" },
    { name = "txtOwnerId", value = var.env },
  ], var.dns_domain != "" ? [{ name = "domainFilters[0]", value = trim(var.dns_domain, ".") }] : [])

  argocd_sets = [
    { name = "server.ingress.enabled", value = "true" },
    { name = "server.ingress.ingressClassName", value = "traefik" },
    { name = "configs.params.server\\.insecure", value = "true" },
    { name = "global.domain", value = local.argocd_domain },
  ]

  prometheus_sets = [
    { name = "prometheus.ingress.enabled", value = "true" },
    { name = "prometheus.ingress.ingressClassName", value = "traefik" },
    { name = "prometheus.prometheusSpec.retention", value = "15d" },
    { name = "grafana.enabled", value = "true" },
  ]

  app_charts = {
    frontend = {
      image   = { repository = "dummy/roboshop-frontend", tag = "latest" }
      service = { port = 80, targetPort = 80 }
      ingress = { enabled = true, host = "frontend" }
    }
    user = {
      image   = { repository = "dummy/roboshop-user", tag = "latest" }
      service = { port = 8001, targetPort = 8001 }
      ingress = { enabled = true, host = "user" }
    }
    catalogue = {
      image   = { repository = "dummy/roboshop-catalogue", tag = "latest" }
      service = { port = 8002, targetPort = 8002 }
      ingress = { enabled = true, host = "catalogue" }
    }
    cart = {
      image   = { repository = "dummy/roboshop-cart", tag = "latest" }
      service = { port = 8003, targetPort = 8003 }
      ingress = { enabled = true, host = "cart" }
    }
    shipping = {
      image   = { repository = "dummy/roboshop-shipping", tag = "latest" }
      service = { port = 8004, targetPort = 8004 }
      ingress = { enabled = true, host = "shipping" }
    }
    payment = {
      image   = { repository = "dummy/roboshop-payment", tag = "latest" }
      service = { port = 8005, targetPort = 8005 }
      ingress = { enabled = true, host = "payment" }
    }
    ratings = {
      image   = { repository = "dummy/roboshop-ratings", tag = "latest" }
      service = { port = 8006, targetPort = 8006 }
      ingress = { enabled = true, host = "ratings" }
    }
    orders = {
      image   = { repository = "dummy/roboshop-orders", tag = "latest" }
      service = { port = 8007, targetPort = 8007 }
      ingress = { enabled = true, host = "orders" }
    }
    notification = {
      image   = { repository = "dummy/roboshop-notification", tag = "latest" }
      service = { port = 8008, targetPort = 8008 }
      ingress = { enabled = true, host = "notification" }
    }
  }
}

resource "helm_release" "metrics_server" {
  depends_on = [null_resource.kubeconfig]

  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"

  set {
    name  = "apiService.create"
    value = "true"
  }
}

resource "helm_release" "traefik" {
  depends_on = [null_resource.kubeconfig]

  name             = "traefik"
  repository       = "https://traefik.github.io/charts"
  chart            = "traefik"
  namespace        = "traefik"
  create_namespace = true
  values           = [local.traefik_values]
}

resource "helm_release" "cluster_autoscaler" {
  depends_on = [
    null_resource.kubeconfig,
    aws_eks_pod_identity_association.cluster_autoscaler,
    helm_release.metrics_server,
  ]

  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"

  dynamic "set" {
    for_each = local.cluster_autoscaler_sets
    content {
      name  = set.value.name
      value = set.value.value
    }
  }
}

resource "helm_release" "external_dns" {
  depends_on = [
    null_resource.kubeconfig,
    aws_eks_pod_identity_association.external_dns,
    helm_release.traefik,
  ]

  name             = "external-dns"
  repository       = "https://kubernetes-sigs.github.io/external-dns"
  chart            = "external-dns"
  namespace        = "external-dns"
  create_namespace = true

  dynamic "set" {
    for_each = local.external_dns_sets
    content {
      name  = set.value.name
      value = set.value.value
    }
  }
}

resource "helm_release" "argocd" {
  depends_on = [helm_release.traefik]

  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true

  dynamic "set" {
    for_each = local.argocd_sets
    content {
      name  = set.value.name
      value = set.value.value
    }
  }
}

resource "helm_release" "prometheus_stack" {
  depends_on = [helm_release.traefik]

  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true

  dynamic "set" {
    for_each = local.prometheus_sets
    content {
      name  = set.value.name
      value = set.value.value
    }
  }

  set_list {
    name  = "prometheus.ingress.hosts"
    value = [local.prometheus_domain]
  }
}

resource "helm_release" "roboshop_apps" {
  for_each = local.app_charts

  depends_on = [helm_release.traefik, aws_eks_node_group.main]

  name             = each.key
  chart            = "${path.module}/../../../helm/charts/${each.key}"
  namespace        = "roboshop"
  create_namespace = true
  timeout          = 600

  values = [
    yamlencode(merge(each.value, {
      global = {
        env             = var.env
        dbHosts         = var.db_service_hosts
        ingressClass    = "traefik"
        imagePullPolicy = "IfNotPresent"
      }
    }))
  ]
}
