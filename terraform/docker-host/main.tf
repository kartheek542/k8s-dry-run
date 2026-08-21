# 1. SSH Key Pair for GitHub Actions to connect to the EC2 instance
resource "tls_private_key" "build_host_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "docker-build-host-key"
  public_key = tls_private_key.build_host_key.public_key_openssh
}

resource "aws_security_group" "build_host_sg" {
  name        = "docker-build-host-sg"
  description = "Allow SSH for remote Docker daemon access"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2375
    to_port     = 2375
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "build_host" {
  ami                         = var.ami_id
  instance_type               = "c6a.xlarge"
  subnet_id                   = module.vpc.public_subnets[0]
  key_name                    = aws_key_pair.generated_key.key_name
  vpc_security_group_ids      = [aws_security_group.build_host_sg.id]
  associate_public_ip_address = true

  instance_market_options {
    market_type = "spot"
  }

  # EBS Storage sizing
  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = file("./scripts/startup-script.sh")

  tags = {
    Name = "Docker-Build-Host"
  }
}