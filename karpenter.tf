resource "aws_iam_instance_profile" "karpenterinstanceprofile" {
  name = "karpenter_instance_profile"
  role = aws_iam_role.instancerole.name
}

resource "aws_iam_role" "karpenterinstancerole" {
  name = "karpenter_instance_role"
  path = "/"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": "karpenterroles"
        }
    ]
}
EOF
}

/*resource "aws_iam_role" "karpentercontroller" {
    name  = "karpenter_controller_role"
    path  = "/"
    assume_role_policy = <<EOF
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": ${aws_iam_openid_connect_provider.eks_oidc.arn}
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "${}:aud": "sts.amazonaws.com",
                    "${}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
                }
            }
        }
    ]
}
EOF
}
*/

resource "aws_iam_role_policy_attachment" "KarpenterAmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.karpenterinstancerole.name
}


resource "aws_iam_role_policy_attachment" "KarpenterAmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.karpenterinstancerole.name
}

resource "aws_iam_role_policy_attachment" "KarpenterAmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.karpenterinstancerole.name
}

resource "aws_iam_role_policy_attachment" "KarpenterAmazonSSMManagedInstanceCore" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    role       = aws_iam_role.karpenterinstancerole.name
}

resource "aws_iam_role_policy_attachment" "KarpenterCloudWatchAgentServerPolicy" {
  policy_arn  = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role        = aws_iam_role.karpenterinstancerole.name
}
