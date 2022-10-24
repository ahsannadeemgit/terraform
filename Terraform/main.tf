terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.35.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
  access_key = ""
  secret_key = ""
}

resource "aws_vpc" "terraform_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "Terraform"
  }
}

resource "aws_internet_gateway" "terraform_igw" {
  vpc_id = aws_vpc.terraform_vpc.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "terraform_rt" {
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform_igw.id
  }

  tags = {
    Name = "main"
  }
}

resource "aws_route_table_association" "terraform_rta" {
  subnet_id      = aws_subnet.terraform_subnet.id
  route_table_id = aws_route_table.terraform_rt.id
}

resource "aws_subnet" "terraform_subnet" {
  vpc_id = aws_vpc.terraform_vpc.id
  cidr_block = "172.16.10.0/24"
  availability_zone = "us-east-1a"
  
  tags = {
    Name = "Terraform"
  }
}

resource "aws_security_group" "terraform_sg" {
  name = "terraform_sg"
  vpc_id = aws_vpc.terraform_vpc.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "test" {
  ami = "ami-026b57f3c383c2eec"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.terraform_subnet.id
  vpc_security_group_ids = [ aws_security_group.terraform_sg.id ]
  key_name = "terraform-session-ke"
  associate_public_ip_address = "true"
  user_data = "${file("install_apache.sh")}"
  user_data_replace_on_change = true
  depends_on = [aws_internet_gateway.terraform_igw]
  tags = {
    Name = "Terraform"
  }
}
