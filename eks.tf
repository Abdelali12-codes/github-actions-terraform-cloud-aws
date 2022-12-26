resource "aws_eks_cluster" "eks_cluster" {
  name     = "eks-cluster"
  role_arn = aws_iam_role.aws_eks_cluster.arn

  vpc_config {
    subnet_ids             = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
    #endpoint_public_access = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
    aws_nat_gateway.natgateway
  ]
  
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${var.clustername} --region ${var.region}"
    #command  = "echo $HOME/environment/abdelalihh.txt"
  }
}

resource "aws_eks_node_group" "eks_worker_nodes" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "aws_eks_node_group"
  node_role_arn   = aws_iam_role.worker_node_role.arn
  subnet_ids      = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]

  instance_types  = [
      "t3.medium"
  ]
  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }
  
  remote_access {
    ec2_ssh_key                = data.aws_key_pair.ec2-ssh-keypair.key_name
    source_security_group_ids  = [aws_security_group.instance_sg.id]
  }
  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonSSMManagedInstanceCore,
    aws_nat_gateway.natgateway
  ]
}



data "aws_eks_cluster_auth" "cluster_auth" {
  name = aws_eks_cluster.eks_cluster.name
}


resource "kubernetes_config_map_v1_data" "aws_auth_configmap" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
 data = {
    mapRoles = <<EOF
- rolearn: ${aws_iam_role.worker_node_role.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
- rolearn: ${aws_iam_role.root_account_role.arn}
  username: kubectl-access-user
  groups:
    - system:masters
EOF
  }
  
  force = true
  
  depends_on = [
     aws_eks_cluster.eks_cluster,
     aws_eks_node_group.eks_worker_nodes
  ]
}

data "tls_certificate" "thumbprint" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_oidc" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
      data.tls_certificate.thumbprint.certificates[0].sha1_fingerprint
  ]
  
  depends_on = [
     aws_eks_cluster.eks_cluster,
     aws_eks_node_group.eks_worker_nodes
  ]
}


