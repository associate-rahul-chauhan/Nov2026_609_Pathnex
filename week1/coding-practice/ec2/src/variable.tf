variable "aws_region" {
    type  = string
    description ="region where Ec2 will be created"
    default = "us-east-1"
}


variable "instance_type" {
    type = string
    description = "type of EC2 instance"
    default = "t2.micro"
}

variable "name_prefix" {
    type = string
    description = "prefix for the name of the EC2 instance"
    default = "Pathnex-nov-2026"
}

variable "tags" {
    type = map(string)
    description = "tags to apply to the EC2 instance"
    default = {
        project = "learning-terraform"
    }
}