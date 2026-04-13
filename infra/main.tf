

# Establish target AWS region
provider "aws" {
  region = "eu-north-1"
}
resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.0.0/16"
}
resource "aws_subnet" "subnet1" {
  count = 2
  vpc_id = aws_vpc.vpc1.id
  cidr_block = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  availability_zone = count.index==0 ? "eu-north-1b" : "eu-north-1a"
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
  vpc_id = aws_vpc.vpc1.id

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
  ingress  {
    description = "Allow Load Balancer Health Checks"
    from_port   = 80
    to_port     = 80
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

resource "aws_lb" "newsapp_lb" {
  name               = "newsapp-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.newsapp_sg.id]
  subnets            = aws_subnet.subnet1[*].id

  tags = {
    Name = "Newsapp-Load-Balancer"
  }
}
resource "aws_lb_target_group" "newsapp_tg" {
  name     = "newsapp-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc1.id

  health_check {
    path                = "/"
    port="traffic-port"
  }

  tags = {
    Name = "Newsapp-Target-Group"
  }
}
# resource "aws_lb_target_group_attachment" "attachment" {
#   count            = 2
#   target_group_arn = aws_lb_target_group.newsapp_tg.arn
#   target_id        = aws_instance.newsapp_server[count.index].id
#   port             = 8080
  
# }
resource "aws_autoscaling_group" "newsapp_asg" {
  name                = "newsapp-asg"
  desired_capacity    = 2      # idle state = 2 instances running
  min_size            = 1      # minimum 1 always running
  max_size            = 3      # never exceed 3

  # Spread instances across both your subnets/AZs
  vpc_zone_identifier = aws_subnet.subnet1[*].id

  # Use launch template instead of direct AMI
  launch_template {
    id      = aws_launch_template.newsapp_lt.id
    version = "$Latest"
  }

  # ✅ Auto replace unhealthy instances using ELB health checks
  health_check_type         = "ELB"       # uses LB health check, not just EC2 status
  health_check_grace_period = 120         # wait 120s before checking (docker needs time to start)

  # Attach to target group so LB routes to ASG instances
  target_group_arns = [aws_lb_target_group.newsapp_tg.arn]

  # When replacing unhealthy instance, launch new one first
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50    # keep at least 50% healthy during refresh
    }
  }

  tag {
    key                 = "Name"
    value               = "Newsapp-ASG-Instance"
    propagate_at_launch = true      # tag applies to every EC2 launched by ASG
  }
}
resource "aws_lb_listener" "name" {
  load_balancer_arn = aws_lb.newsapp_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.newsapp_tg.arn
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc1.id
}
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
resource "aws_route_table_association" "route_table_assoc" {
  count=2
  subnet_id      = aws_subnet.subnet1[count.index].id
  route_table_id = aws_route_table.route_table.id
}
# Provision the EC2 Instance
# 
resource "aws_launch_template" "newsapp_lt" {
  name_prefix   = "newsapp-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"
  key_name      = "mywebserver-key"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.newsapp_sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y docker
              systemctl start docker
              systemctl enable docker
              docker network create newsapp-network
              docker run -d \
                --name backend \
                --network newsapp-network \
                --restart always \
                -e PORT=5000 \
                -e NEWS_API_KEY=0ed714c98a1c44938f58aa38b0a9aab7 \
                krishsoh/newsapp-backend:latest
              docker run -d \
                -p 8080:8080 \
                --name frontend \
                --network newsapp-network \
                --restart always \
                krishsoh/newsapp-frontend:latest
              EOF
  )

  tags = {
    Name = "Newsapp-Launch-Template"
  }
}

# Outputs dynamically print out to the console upon completion


output "application_url" {
  description = "The URL to access your live application"
  value       = aws_lb.newsapp_lb.dns_name
}
