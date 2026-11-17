# variable.tf: declares the inputs of this project. Values come from terraform.tfvars, or from "default" if not set there

variable "aws_region" {                      # Input named aws_region, used as var.aws_region
  description = "AWS region"                 # Human readable explanation
  type        = string                       # Value must be text
  default     = "ap-southeast-2"             # Used if no value is given (Sydney region)
}

variable "instance_type" {                   # Input named instance_type
  description = "EC2 instance type"          # (fixed: was wrongly "Aws Instance type" for both variables)
  type        = string                       # Value must be text
  default     = "t3.micro"                   # Small, cheap, free-tier eligible in many accounts (2 vCPU, 1 GiB RAM)
}

variable "instance_name" {                   # Input named instance_name
  description = "Value of the Name tag for the EC2 instance"  # (fixed: was a copy-paste description)
  type        = string                       # Value must be text
  default     = "terraform-learning-ec2"     # Used if not overridden in terraform.tfvars
}
