provider "aws" {
    region = var.aws_region
}

# use default VPC
data "aws_vpc" "default" {
    default = true
}

data "aws_subnets" "default" {
    filter {
        name = "vpc-id"
        value = [data.aws_vpc.default.id]
    }
}

data "aws_ami" "al2023" {
 most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

data "aws_security_group" "web-sg" {
    name        = "pathnex-nov-tf-sg"
  description = "Allow HTTP only"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = "terraform-class"
    Name    = "pathnex-feb-tf-sg"
  }
}

resource "aws_instance" "feb-tf" {
    ami           = data.aws_ami.al2023.id
    instance_type = var.instance_type
    subnet_id     = data.aws_subnets.default.ids[0]
    vpc_security_group_ids = [data.aws_security_group.web-sg.id]
    tags = merge(var.tags, {
        Name = "${var.name_prefix}-feb-tf"
    })
    user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y httpd
              systemctl enable httpd
              systemctl start httpd
              echo "<h1>Hello All, Today is 18 Feb 2026 and ec2 creation with the help of terraform is successful </h1>" > /var/www/html/index.html
              EOF


            tags = {
            Project = "terraform-class-for-ec2"
            Name    = "pathnex-feb-tf-instance"
            batch   = var.name_prefix
        }
}