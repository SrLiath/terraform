# terraform aws create security group
resource "aws_security_group" "ssh-security-group" {
name        = "SSH Security Group"
description = "Enable SSH access on Port 22"
vpc_id      = aws_vpc.stage_vpc.id
ingress {
description      = "SSH Access"
from_port        = 22
to_port          = 22
protocol         = "tcp"
cidr_blocks      = ["${var.publickey}"]
}
egress {
from_port        = 0
to_port          = 0
protocol         = "-1"
cidr_blocks      = ["0.0.0.0/0"]
}
tags   = {
Name = "SSH Security Group"
}
}

# Generate the SSH keypair
resource "tls_private_key" "key" {
algorithm = "RSA"
}
resource "local_file" "private_key" {
filename          = "${var.env}_aws_ssh.pem"
sensitive_content = tls_private_key.key.private_key_pem
file_permission   = "0400"
}
resource "aws_key_pair" "key_pair" {
key_name   = "${var.env}_aws_ssh"
public_key = tls_private_key.key.public_key_openssh
}