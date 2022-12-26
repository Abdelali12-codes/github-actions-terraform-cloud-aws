/*resource "helm_release" "prometheus" {
  name       = "prometheus-release"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.prometheusns.metadata[0].name
  
  depends_on = [
     aws_eks_cluster.eks_cluster,
     aws_eks_node_group.eks_worker_nodes
  ]
  
}

# install the ebs csi
resource "helm_release" "ebscsideriver" {
  name       = "aws-ebs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  namespace  = "kube-system"
  
  set {
    name  = "enableVolumeResizing"
    value = "true"
  }
  
  set {
    name  = "enableVolumeSnapshot"
    value = "true"
  }
  
  set {
    name  = "controller.serviceAccount.create"
    value = "false"
  }
  
  set {
    name  = "controller.serviceAccount.name"
    value = kubernetes_service_account.ebscsisa.metadata[0].name
  }
  
  depends_on = [
     aws_eks_cluster.eks_cluster,
     aws_eks_node_group.eks_worker_nodes
  ]
  
}

# install the elb
resource "helm_release" "elbcontroller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  
  set {
    name  = "clusterName"
    value = var.clustername
  }
  
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  
  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.elbcontrollersa.metadata[0].name
  }
  
  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.us-east-2.amazonaws.com/amazon/aws-load-balancer-controller"
  }
  
  depends_on = [
     aws_eks_cluster.eks_cluster,
     aws_eks_node_group.eks_worker_nodes
  ]
  
}

# install the awx operator

resource "helm_release" "awxoperator" {
  name       = "awx-operator"
  repository = "https://ansible.github.io/awx-operator/"
  chart      = "awx-operator"
  namespace  = "awx"
  
  set {
    name  = "admin_user"
    value = "admin"
  }
  
  set {
    name  = "admin_email"
    value = "abdelali.jadelmoula1607@gmail.com"
  }
  
  set {
    name  = "admin_password_secret"
    value = kubernetes_secret.awxadminpassword.metadata[0].name
  }
  
  set {
    name  = "secret_key_secret"
    value = kubernetes_secret.customawxsecretkey.metadata[0].name
  }
  
  depends_on = [
     aws_eks_cluster.eks_cluster,
     aws_eks_node_group.eks_worker_nodes
  ]
  
}
*/