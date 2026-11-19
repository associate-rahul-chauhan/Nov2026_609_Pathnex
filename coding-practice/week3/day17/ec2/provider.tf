# provider.tf: tells Terraform which cloud plugin (provider) to download and how to configure it

terraform {                                  # Terraform settings block (not a resource)
  required_providers {                       # Lists the provider plugins this project needs
    aws = {                                  # Local name we use for the provider
      source  = "hashicorp/aws"              # Where to download it: official HashiCorp AWS provider
      version = "~> 6.0"                     # Allow any 6.x version, but never 7.0 or higher
    }
  }
}

provider "aws" {                             # Configure the AWS provider
  region = var.aws_region                    # Region to create resources in, taken from variable aws_region
}
