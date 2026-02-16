data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # from Canonical provider
}

#PUBLIC INSTANCES

resource "aws_instance" "public_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id = var.public_subnet_1_id
  key_name = "terraform"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  user_data_replace_on_change = true
  user_data = <<-EOF
                                #!/bin/bash
                                apt update -y && apt upgrade -y
                                apt install -y nginx
                                systemctl enable --now nginx
                                echo "Hello World from $(hostname -f)" > /var/www/html/index.html
                                echo "<h1>THIS IS MY PUBLIC INSTANCE_1</h1>" >> /var/www/html/index.html
                              EOF
  tags = {
    Name = "public_instance"
  }
}

resource "aws_eip" "public_inst_eip" {
  instance = aws_instance.public_instance.id
  domain   = "vpc"
}

resource "aws_instance" "public_instance_1" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id = var.public_subnet_2_id
  key_name = "terraform"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  user_data_replace_on_change = true
  user_data = <<-EOF
                                #!/bin/bash
                                apt update -y && apt upgrade -y
                                apt install -y nginx
                                systemctl enable --now nginx
                                echo "Hello World from $(hostname -f)" > /var/www/html/index.html
                                echo "<h1>THIS IS MY PUBLIC INSTANCE_2</h1>" >> /var/www/html/index.html
                              EOF
  tags = {
    Name = "public_instance"
  }
}

resource "aws_eip" "public_inst_eip_1" {
  instance = aws_instance.public_instance_1.id
  domain   = "vpc"
}

#PUBLIC SG

resource "aws_security_group" "ec2_sg" {
  name        = "https_ec2"
  description = "https from my IP"
  vpc_id      = var.vpc_id

  tags = {
    Name = "https from ip"
  }
}

resource "aws_vpc_security_group_ingress_rule" "https_in" {
  security_group_id = aws_security_group.ec2_sg.id
  cidr_ipv4         = var.my_ip
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "http_in" {
  security_group_id = aws_security_group.ec2_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.ec2_sg.id
  cidr_ipv4         = var.my_ip
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "inclusive_ipv4" {
  security_group_id = aws_security_group.ec2_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


#PRIVATE INSTANCE

resource "aws_instance" "private_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name = "terraform"
  vpc_security_group_ids = [aws_security_group.ec2_sg_priv.id]
  subnet_id = var.private_subnet_1_id
  tags = {
    Name = "private_instance"
  }
}



#PRIVATE SG

resource "aws_security_group" "ec2_sg_priv" {
  name        = "allow access only from public EC2"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "allow_internal access (sg_priv)"
  }
}

# resource "aws_vpc_security_group_ingress_rule" "priv_http" {
#   security_group_id = aws_security_group.ec2_sg_priv.id

#   cidr_ipv4         = 
#   from_port         = 80
#   ip_protocol       = "tcp"
#   to_port           = 80
# }

resource "aws_vpc_security_group_ingress_rule" "priv_ssh" {
  security_group_id = aws_security_group.ec2_sg_priv.id
  referenced_security_group_id = aws_security_group.ec2_sg.id
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.ec2_sg_priv.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}