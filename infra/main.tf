

# Establish target AWS region
provider "aws" {
  region = "eu-north-1"
}

# Dynamically fetch the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# Create a Security Group granting access
resource "aws_security_group" "newsapp_sg" {
  name        = "newsapp-security-group"
  description = "Allow inbound traffic on port 8080 for frontend and 22 for SSH"

  ingress {
    description = "Allow SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Frontend Web Traffic"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Provision the EC2 Instance
resource "aws_instance" "newsapp_server" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro" # Free tier eligible

  vpc_security_group_ids = [aws_security_group.newsapp_sg.id]
  
  # Optional: If you have an SSH Key Pair, uncomment the line below and insert its name 
  # key_name = "my-aws-key-name"

  # User data script executes completely autonomously during instance startup
  user_data = <<-EOF
              #!/bin/bash
              # Update packages and install Docker
              dnf update -y
              dnf install -y docker

              # Start and enable Docker service to run on boot
              systemctl start docker
              systemctl enable docker

              # Create internal Docker network
              docker network create newsapp-network

              # Pull and confidently run the backend container
              docker run -d \
                --name backend \
                --network newsapp-network \
                --restart always \
                -e PORT=5000 \
                krishsoh/newsapp-backend:latest

              # Pull and confidently run the frontend container
              docker run -d \
                -p 8080:8080 \
                --name frontend \
                --network newsapp-network \
                --restart always \
                krishsoh/newsapp-frontend:latest
              EOF

  tags = {
    Name = "Newsapp-Production-Server"
  }
}

# Outputs dynamically print out to the console upon completion
output "public_ip" {
  description = "The public IP of the EC2 instance"
  value       = aws_instance.newsapp_server.public_ip
}

output "application_url" {
  description = "The URL to access your live application"
  value       = "http://${aws_instance.newsapp_server.public_ip}:8080"
}
