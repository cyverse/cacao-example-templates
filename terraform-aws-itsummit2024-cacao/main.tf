terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region

  # provider optimizations; some might be risky
  skip_metadata_api_check = true
  skip_credentials_validation = true
  skip_region_validation = true
}

resource "aws_vpc" "itsummit_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "itsummit_subnet" {
  vpc_id = aws_vpc.itsummit_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "itsummit_igw" {
  vpc_id = aws_vpc.itsummit_vpc.id
}

resource "aws_route_table" "itsummit_route_table" {
  vpc_id = aws_vpc.itsummit_vpc.id
}

resource "aws_route" "itsummit_default_route" {
  route_table_id = aws_route_table.itsummit_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.itsummit_igw.id
}

resource "aws_route_table_association" "itsummit_rta" {
  subnet_id = aws_subnet.itsummit_subnet.id
  route_table_id = aws_route_table.itsummit_route_table.id
}


resource "aws_security_group" "itsummit_sg" {
  name = "itsummit_sg"
  description = "ssh for itsummit"
  vpc_id = aws_vpc.itsummit_vpc.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

data "aws_ami" "itsummit_ubuntu_2404" {
  most_recent = true
  owners = ["099720109477"] # ami-0aff18ec83b712f05

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_instance" "itsummit_instance" {
  instance_type = "t2.micro"
  ami = data.aws_ami.itsummit_ubuntu_2404.id
  # key_name = aws_key_pair.itsummit_keypair.id
  vpc_security_group_ids = [aws_security_group.itsummit_sg.id]
  subnet_id = aws_subnet.itsummit_subnet.id

  user_data = var.user_data

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = var.instance_name
  }
}
