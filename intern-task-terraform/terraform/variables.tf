variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "ami_id" {
  description = "Ubuntu AMI. Never actually launched, any plausible id works."
  type        = string
  default     = "ami-0123456789abcdef0"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "ssh_cidr" {
  description = "The one CIDR allowed to SSH in, for example your own IP as x.x.x.x/32. No default on purpose."
  type        = string

  validation {
    condition     = var.ssh_cidr != "0.0.0.0/0"
    error_message = "ssh_cidr must not be 0.0.0.0/0, pick a specific CIDR."
  }
}

variable "admin_user" {
  type    = string
  default = "deploy"
}

variable "ssh_authorized_keys" {
  description = "Public keys for the admin user."
  type        = list(string)
  default     = []
}
