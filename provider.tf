terraform {
 required_providers {
   aws = {
     source  = "hashicorp/aws"
   }
 }
 cloud {
    organization = "hashsicorp"

    workspaces {
      name = "terraform-aws"
    }
  }
}
 
/*provider "aws" {
  profile = "admin"
  region  ="us-east-2"
}
*/

/*provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    #exec {
    #    api_version = "client.authentication.k8s.io/v1beta1"
    #    command     = "aws"
    #    args        = ["eks","get-token","--cluster-name",aws_eks_cluster.eks_cluster.name,"--role",aws_iam_role.root_account_role.arn]
    #    env         = {
    #        "AWS_PROFILE" = "admin"
    #    }
    #}
  }
 }
*/

provider "kubernetes" {
  host                   = aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
}