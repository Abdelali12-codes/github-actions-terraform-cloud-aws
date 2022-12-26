variable "region" {
    type    = string
    default = "us-east-2"
}

variable "accountid" {
    type    = string
    default = "080266302756"
}

variable "clustername" {
    type    = string
    default = "eks-cluster"
}

variable "ecrrepouri" {
    type    = string
    default = "080266302756.dkr.ecr.us-east-2.amazonaws.com/springboot"
}

variable "route53publicdomain" {
    type    = string
    default = "abdelalitraining.com"
}

variable "instance" {
    type    = object({
        ami  = string
        type = string
        tags = map(string)
    })
    default ={
      "ami"  = "ami-0beaa649c482330f7"
      "type" = "t3.micro"
      "tags" = {
          "Name" = "bastion-instance"
      }
    }
}

variable "vpc" {
    type    = object({
        cidr_block = string 
        tags= map(string)
    })
    default = {
        "cidr_block" = "15.10.0.0/16"
        "tags"       = {
              "Name" = "eks_vpc"
        }
    }
}

variable "privatesubnet1" {
    type    = object({
        cidr_block        = string
        tags              = map(string)
        availability_zone = string
    })
    default = {
        "cidr_block" = "15.10.1.0/24"
        "tags"       = {
            "Name"                                    = "eks_privatesubnet1"
            "kubernetes.io/role/internal-elb"         = "1"
            "kubernetes.io/cluster/eks-cluster"       = "shared"
        }
        "availability_zone" = "us-east-2a"
    }
}

variable "privatesubnet2" {
    type = object({
        cidr_block        = string
        tags              = map(string)
        availability_zone = string
    })
    default = {
        "cidr_block" = "15.10.2.0/24"
        "tags"       = {
            "Name"                                                = "eks_privatesubnet2"
            "kubernetes.io/role/internal-elb"                     = "1"
            "kubernetes.io/cluster/eks-cluster"        = "shared"
        }
        "availability_zone" = "us-east-2b"
    }
}

variable "publicsubnet1" {
    type = object({
        cidr_block         = string
        tags               = map(string)
        availability_zone  = string
    }) 
    default = {
        "cidr_block" = "15.10.3.0/24"
        "tags"       = {
            "Name"                                     = "eks_publicsubnet1"
            "kubernetes.io/role/elb"                   = "1"
            "kubernetes.io/cluster/eks-cluster"        = "shared"
        }
        "availability_zone" = "us-east-2a"
    }
}

variable "publicsubnet2" {
    type         = object({
        cidr_block        = string
        tags              = map(string)
        availability_zone = string
    }) 
    default = {
        "cidr_block" = "15.10.4.0/24"
        "tags"       = {
            "Name"                                    = "eks_publicsubnet2"
            "kubernetes.io/cluster/eks-cluster"       = "shared"
            "kubernetes.io/role/elb"                  = "1"
        }
        "availability_zone" = "us-east-2b"
    }
}

variable "publicroutetable" {
    type        = object({
        tags = map(string)
    })
    default     = {
        "tags"  = {
            "Name" = "eks_publicroutetable"
        }
    }
}

variable "privateroutetable" {
    type        = object({
        tags = map(string)
    })
    default     = {
        "tags"  = {
            "Name" = "eks_privateroutetable"
        }
    }
}

variable "gw" {
    type    = object({
        tags  = map(string)
    })
    default = {
        "tags" = {
            "Name" = "eks_internet_gateway"
        }
    }
}

variable "natgateway" {
    type        = object({
        tags  = map(string)
    }) 
    default     = {
        "tags"  = {
            "Name" = "eks_natgateway"
        }
    }
}

variable "keypair" {
    type    =  string
    default = "ohio-keypair"
}

variable "eks" {
    type    = map(string)
    default = {
        "clusterName" = "eks_awx_cluster"
    }
}

/*variable "private_key" {
    type    = string
    default = "/home/ec2-user/.ssh/id_rsa"
}

variable "public_key" {
    type     = string
    default  = "/home/ec2-user/.ssh/id_rsa.pub"
}

variable "aws_region" {
    type    = string
    default = "us-west-2"
}*/

