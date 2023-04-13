terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.region
}

#ec2
resource "aws_instance" "stage_instance" {
  ami           = "ami-07b14488da8ea02a0"
  instance_type = "t2.micro"
  subnet_id      = aws_subnet.stage_public_subnet.id
  security_groups             = ["${aws_security_group.ssh-security-group.id}"]

  provisioner "file" {
source      = "./${var.key_name}.pem"
destination = "/home/ec2-user/${var.key_name}.pem"
connection {
type        = "ssh"
user        = "ec2-user"
private_key = file("${var.key_name}.pem")
host        = self.public_ip
}
}
  tags = {
    Name = var.env

  }
}
#VPC
resource "aws_vpc" "stage_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.env}_vpc"
  }
}

