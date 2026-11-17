# main.tf: the actual infrastructure. Creates a security group and an EC2 instance in the default VPC

# Data source: reads an existing object, does not create anything
data "aws_vpc" "default" {                   # Look up the default VPC of the account/region
  default = true                             # Select the VPC flagged as default
}

# Data source: list subnets that belong to the default VPC
data "aws_subnets" "default" {
  filter {                                   # (fixed: was misspelled "fileter", which made Terraform fail)
    name   = "vpc-id"                        # Filter on the subnet's VPC id
    values = [data.aws_vpc.default.id]       # Only subnets inside the default VPC
  }
}

# Data source: find the newest Amazon Linux 2023 image
data "aws_ami" "amazon_linux" {
  most_recent = true                         # If several match, pick the newest
  owners      = ["amazon"]                   # Only images published by Amazon (trusted)

  filter {
    name   = "name"                          # Match on the AMI name
    values = ["al2023-ami-2023.*-x86_64"]    # Amazon Linux 2023, 64-bit x86 (excludes "minimal" images)
  }

  filter {
    name   = "architecture"                  # Match on CPU architecture
    values = ["x86_64"]                      # Must fit t3 instances (Intel/AMD)
  }
}

# Resource: firewall for the instance
resource "aws_security_group" "ec2_sg" {
  name        = "t-sg"                       # Name of the group in AWS
  description = "sg"                         # Required description
  vpc_id      = data.aws_vpc.default.id      # Attach to the default VPC

  ingress {                                  # Inbound rule
    description = "SSH access"               # Why this rule exists
    from_port   = 22                         # Start of port range (SSH)
    to_port     = 22                         # End of port range
    protocol    = "tcp"                      # SSH uses TCP
    cidr_blocks = ["0.0.0.0/0"]              # Allowed from anywhere. OK for learning; restrict to your IP (x.x.x.x/32) for real use
  }

  egress {                                   # Outbound rule
    from_port   = 0                          # All ports
    to_port     = 0                          # All ports
    protocol    = "-1"                       # All protocols
    cidr_blocks = ["0.0.0.0/0"]              # To anywhere (instance can reach the internet)
  }
}

# Resource: the virtual machine
resource "aws_instance" "learning_ec2" {
  ami           = data.aws_ami.amazon_linux.id   # Image found above
  instance_type = var.instance_type              # Size, from variable (t3.micro)

  subnet_id = data.aws_subnets.default.ids[0]    # Place in the first default subnet

  associate_public_ip_address = true             # (added) Guarantees a public IP so the public_ip/public_dns outputs are filled

  vpc_security_group_ids = [                     # Attach firewall(s)
    aws_security_group.ec2_sg.id                 # The security group created above
  ]

  tags = {                                       # Labels shown in AWS console
    Name        = var.instance_name              # Display name, from variable
    Environment = "Learning"                     # Free-form label
    ManagedBy   = "Terraform"                    # Shows it is managed by Terraform
  }
}
