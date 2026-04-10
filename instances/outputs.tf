output "elastic_ip" {
  description = "The Elastic IP address"
  value       = aws_eip.main.public_ip
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.main.id
}
