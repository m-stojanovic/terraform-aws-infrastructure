resource "aws_instance" "gateway" {
  ami                         = "ami-04f7efe62f419d9f5"
  instance_type               = "t3.small"
  subnet_id                   = module.vpc_ci.public_subnets[0]
  key_name                    = aws_key_pair.gateway.key_name
  vpc_security_group_ids      = [aws_security_group.security_group_gateway.id]
  associate_public_ip_address = true
  tags                        = merge(tomap({ "Name" = "devops-gateway-server" }), var.tags)

  root_block_device {
    volume_size           = 10
    volume_type           = "gp3"
    delete_on_termination = false
    encrypted             = true
  }
}

resource "aws_key_pair" "gateway" {
  key_name   = "devops-gateway-server"
  public_key = "ssh-ed25519 xxxx"
}

resource "aws_eip" "gateway" {
  instance = aws_instance.gateway.id
  vpc      = true
  tags     = var.tags
}

resource "aws_security_group" "security_group_gateway" {
  name        = "${var.environment}-gateway-server-sg"
  description = "Security group to allow access to Gateway server."
  vpc_id      = module.vpc_ci.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "allow access from the vpn server on port 22"
    cidr_blocks = var.openvpn_server_cidr
  }

  ingress {
    from_port   = 9520
    to_port     = 9520
    protocol    = "tcp"
    description = "allow access from the office on port 22"
    cidr_blocks = var.office_private_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    description = "allow external access to everywhere"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(tomap({ "Name" = "${var.environment}-gateway-server-sg" }), var.tags)

}