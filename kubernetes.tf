/*resource "kubernetes_deployment" "nginx_deployment" {
  metadata {
    name = "nginx-deployment"
    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          image = "nginx"
          name  = "nginx"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80

              http_header {
                name  = "X-Custom-Header"
                value = "Awesome"
              }
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
  
  depends_on = [
     aws_eks_cluster.eks_cluster,
     aws_eks_node_group.eks_worker_nodes
  ]
}


# ebs csi
resource "kubernetes_service_account" "ebscsisa" {
  metadata {
    name        = "ebs-csi-controller-sa"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.ebscsirole.arn
    }
    namespace   = "kube-system"
  }
  
  depends_on = [
     aws_eks_cluster.eks_cluster,
     aws_eks_node_group.eks_worker_nodes
  ]

}

# elb controller
resource "kubernetes_service_account" "elbcontrollersa" {
  metadata {
    name        = "aws-load-balancer-controller"
    labels      = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name" = "aws-load-balancer-controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.elbcontrollerrole.arn
    }
    namespace   = "kube-system"
  }
  
  depends_on = [
     aws_eks_cluster.eks_cluster,
     aws_eks_node_group.eks_worker_nodes
  ]
}

# external dns
resource "kubernetes_service_account" "externaldnssa" {
  metadata {
    name        = "external-dns"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.externaldnsrole.arn
    }
    namespace   = "default"
  }
  
  depends_on = [
     aws_eks_cluster.eks_cluster,
     aws_eks_node_group.eks_worker_nodes
  ]
}

resource "kubernetes_cluster_role" "externaldnsclusterrole" {
  metadata {
    name = "external-dns"
  }

  rule {
    api_groups = [""]
    resources  = ["services","endpoints","pods"]
    verbs      = ["get","watch","list"]
  }
  
  rule {
    api_groups = ["extensions","networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get","watch","list"]
  }
  
  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["list","watch"]
  }
  
  depends_on = [
     aws_eks_cluster.eks_cluster,
     aws_eks_node_group.eks_worker_nodes
  ]
}

resource "kubernetes_cluster_role_binding" "externaldnsclusterrolebinding" {
  metadata {
    name = "external-dns-viewer"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.externaldnsclusterrole.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.externaldnssa.metadata[0].name
    namespace = "default"
  }
  
  depends_on = [
     aws_eks_cluster.eks_cluster,
     aws_eks_node_group.eks_worker_nodes
  ]
}


# awx
resource "kubernetes_namespace" "awxns" {
  metadata {
    name = "awx"
  }
  depends_on = [
     aws_eks_cluster.eks_cluster,
     aws_eks_node_group.eks_worker_nodes
  ]
}

resource "kubernetes_namespace" "prometheusns" {
  metadata {
    name = "prometheus"
  }
  depends_on = [
     aws_eks_cluster.eks_cluster,
     aws_eks_node_group.eks_worker_nodes
  ]
}


resource "kubernetes_secret" "awxadminpassword" {
  metadata {
    name      = "awx-admin-password"
    namespace = kubernetes_namespace.awxns.metadata[0].name
  }
  data = {
    password = "abdelali"
  }
 
  depends_on = [
     aws_eks_cluster.eks_cluster,
     aws_eks_node_group.eks_worker_nodes
  ]
}

resource "kubernetes_secret" "customawxsecretkey" {
  metadata {
    name      = "custom-awx-secret-key"
    namespace = kubernetes_namespace.awxns.metadata[0].name
  }
  data = {
    secret_key = "supersecuresecretkey"
  }
  
  depends_on = [
     aws_eks_cluster.eks_cluster,
     aws_eks_node_group.eks_worker_nodes
  ]
}


resource "kubernetes_manifest" "awxinstance" {
  manifest = {
    "apiVersion" = "awx.ansible.com/v1beta1"
    "kind"       = "AWX"
    "metadata" = {
      "name"      = "awx-demo"
      "namespace" = "awx"
    }
    "spec" = {
       admin_password_secret = kubernetes_secret.awxadminpassword.metadata[0].name 
       secret_key_secret     = kubernetes_secret.customawxsecretkey.metadata[0].name
       service_type          = "ClusterIP"
       service_annotations   = {
          "environment" =  "testing"
       }
       service_labels        = {
          "environment" = "testing"
       }
    }
    depends_on = [
     aws_eks_cluster.eks_cluster,
     aws_eks_node_group.eks_worker_nodes,
     helm_release.awxoperator,
     helm_release.ebscsideriver
    ]
  }
  
  
}
*/
