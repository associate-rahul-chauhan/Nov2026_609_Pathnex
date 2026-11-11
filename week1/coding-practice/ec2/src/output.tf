output "instance_id" {
    value = aws_instance.example.id
}

output "public_ip" {
    value = aws_instance.example.public_ip
}

output "web_url" {
    value = "http://${aws_instance.example.public_ip}   "
}