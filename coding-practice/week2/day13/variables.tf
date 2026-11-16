
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "VPC for user"
  type        = string
  default     = "pathnex-nov-learning-vpc"
}