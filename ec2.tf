resource "aws_security_group" "instance_sg" {
  name        = "allow ssh"
  description = "ec2 instance ssh security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "ssh instance"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_instance" "bastion" {
  ami                     = var.instance["ami"]
  instance_type           = var.instance["type"]
  subnet_id               = aws_subnet.private_subnet1.id
  vpc_security_group_ids  = [aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id, aws_security_group.instance_sg.id]
  iam_instance_profile    = aws_iam_instance_profile.instanceprofile.name
  key_name                = data.aws_key_pair.ec2-ssh-keypair.key_name
  user_data               = <<EOF
  #!/bin/bash
  curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.21.2/2021-07-05/bin/linux/amd64/kubectl
  chmod +x ./kubectl
  mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
EOF
  ebs_block_device{
      delete_on_termination = true
      device_name           = "/dev/sdh"
      volume_type           = "io1"
      iops                  = "1000"
      volume_size           = 20
  }
  
  tags =  var.instance["tags"]
  
}