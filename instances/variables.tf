variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for the public subnet"
  type        = string
  default     = "us-west-2b"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t4g.micro"
}

variable "ssh_public_key_path" {
  description = "Path to your local SSH public key file"
  type        = string
  default     = "~/.ssh/id_ed25519_tf_site.pub"
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed SSH into instance"
  type        = string
  sensitive   = true
}
