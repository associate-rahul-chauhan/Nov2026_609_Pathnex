# output.tf: values printed after "terraform apply" (also readable with "terraform output")

output "instance_id" {                       # Output name
  value = aws_instance.learning_ec2.id       # AWS instance ID, e.g. i-0abc123...
}

output "public_ip" {                         # Output name
  value = aws_instance.learning_ec2.public_ip   # Public IPv4 address, use it to SSH in
}

output "public_dns" {                        # Output name
  value = aws_instance.learning_ec2.public_dns  # Public DNS hostname of the instance
}
