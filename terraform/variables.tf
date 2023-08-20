# This code defines infrastructure resources for deploying a Rocket-app VPC with security group, subnet, and EC2 instances in AWS using Terraform

# VPC resource
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "Rocket-app-vpc"
  }
}

# Security group resource

resource "aws_security_group" "rockatapp" {
  name        = "rockatapp"
  description = "Allow SSH access"
  
 # Allow all incoming TCP traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
   ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow all outgoing TCP traffic
  
   egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}

# EC2 instance resource
resource "aws_instance" "rockatapp" {
  count = 3
  ami           = "ami-086df58ea1b1ad56a"
  instance_type = "t3.small"
  key_name      = "RjeKeys"
  
  # Attach the security group to the instances
  vpc_security_group_ids = [aws_security_group.rockatapp.id]
  
    tags = {
    Name = "RockatApp"
  }
 
}


# Subnet resource
resource "aws_subnet" "this" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.subnet_cidr_block
  map_public_ip_on_launch = true

  tags = {
    Name = "rockat-app-subnet"
  }
 
}

# Output resource for instance IP addresses

 output "ip_address" {
  #value = aws_instance.rockatapp.public_ip
  value = {
    server_1 = aws_instance.rockatapp[0].public_ip
    server_2 = aws_instance.rockatapp[1].public_ip
    server_3 = aws_instance.rockatapp[2].public_ip
  }
 
}

# DNS resources

# data "aws_route53_zone" "rockatapp" {
#   name         = "jedder.net."
#   private_zone = false
# }

# resource "aws_route53_record" "rockatapp" {
#   zone_id = data.aws_route53_zone.rockatapp.zone_id
#   name    = "jedder.net."
#   type    = "A"
#   ttl     = "300"
#   records = [aws_instance.rockatapp[0].public_ip]

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_route53_record" "www_rockatapp" {
#   zone_id = data.aws_route53_zone.rockatapp.zone_id
#   name    = "www.jedder.net."
#   type    = "A"
#   ttl     = "300"
#   records = [aws_instance.rockatapp[0].public_ip]

#   lifecycle {
#     create_before_destroy = true
#   }
# }
 
