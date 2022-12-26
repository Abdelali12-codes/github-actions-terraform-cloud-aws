data "aws_key_pair" "ec2-ssh-keypair" {
  key_name           = var.keypair
  include_public_key = true
}