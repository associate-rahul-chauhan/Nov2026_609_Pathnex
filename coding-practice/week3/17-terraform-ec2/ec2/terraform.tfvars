# terraform.tfvars: actual values for the variables. Terraform loads this file automatically and it overrides defaults

aws_region    = "ap-southeast-2"             # Create everything in Sydney
instance_type = "t3.micro"                   # Size of the virtual machine
instance_name = "my-first-terraform-ec2"     # Name tag shown in the AWS console
