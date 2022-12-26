output "vpc_cidr" {
    description = "the vpc cidr block"
    value       = aws_vpc.main.id
}



output "aws_worker_role_arn" {
    value         = aws_iam_role.root_account_role.arn
    description   = "kubectl access role arn"
}

output "update_config_file" {
    value        = "aws eks update-kubeconfig --name eks-cluster --region us-east-2 --role-arn ${aws_iam_role.root_account_role.arn}"
    description  = "run the command on the bastion to upload the .kube/config file"
}