locals {
  dockerfile = file("${path.module}/../../intern-task-app/Dockerfile")
  app_py     = file("${path.module}/../../intern-task-app/app/app.py")

  # read the port from the Dockerfile EXPOSE line so it can never drift
  app_port = tonumber(regex("(?m)^EXPOSE\\s+(\\d+)", local.dockerfile)[0])
}

# ---------- network ----------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = { Name = "intern-task" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "intern-task" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true

  tags = { Name = "intern-task-public" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = { Name = "intern-task-public" }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ---------- security group ----------

resource "aws_security_group" "app" {
  name        = "intern-task-app"
  description = "SSH from one CIDR, app port from anywhere"
  vpc_id      = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.app.id
  description       = "SSH from the admin CIDR only"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.ssh_cidr
}

resource "aws_vpc_security_group_ingress_rule" "app" {
  security_group_id = aws_security_group.app.id
  description       = "App port from anywhere"
  ip_protocol       = "tcp"
  from_port         = local.app_port
  to_port           = local.app_port
  cidr_ipv4         = "0.0.0.0/0"
}

# without this the instance cant reach the internet to install docker
resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.app.id
  description       = "Outbound for package installs"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# ---------- instance ----------

resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
    admin_user          = var.admin_user
    ssh_authorized_keys = var.ssh_authorized_keys
    ssh_cidr            = var.ssh_cidr
    app_port            = local.app_port
    dockerfile_b64      = base64encode(local.dockerfile)
    app_py_b64          = base64encode(local.app_py)
  })

  lifecycle {
    ignore_changes = [user_data]
  }

  tags = { Name = "intern-task-app" }
}
