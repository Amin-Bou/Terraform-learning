resource "aws_vpc" "wordpress_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true 
  enable_dns_hostnames = true 

  tags = {
    Name = "main-vpc"
  }
}


#                 PUBLIC SUBNETS 

resource "aws_subnet" "public_1_2a" {
  vpc_id     = aws_vpc.wordpress_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "public-1"
  }
}

resource "aws_subnet" "public_2_2b" {
  vpc_id     = aws_vpc.wordpress_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "public-2"
  }
}


#PRIVATE SUBNETS

resource "aws_subnet" "PRIVATE_1_2a" {
  vpc_id     = aws_vpc.wordpress_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "private-1"
  }
}

resource "aws_subnet" "PRIVATE_2_2b" {
  vpc_id     = aws_vpc.wordpress_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "private-2"
  }
}




#    INTERNET GATEWAY   

resource "aws_internet_gateway" "igw_terraform" {
  vpc_id = aws_vpc.wordpress_vpc.id

  tags = {
    Name = "igw"
  }
}



# PUBLIC SUBNET ROUTE TABLE -> INTERNET GATEWAT

resource "aws_route_table" "public_subs" {
  vpc_id = aws_vpc.wordpress_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_terraform.id
  }

  tags = {
    Name = "public subnets to igw"
  }
}

resource "aws_route_table_association" "rt_assoc_public_1" {
  subnet_id      = aws_subnet.public_1_2a.id
  route_table_id = aws_route_table.public_subs.id
}

resource "aws_route_table_association" "rt_assoc_public_2" {
  subnet_id      = aws_subnet.public_2_2b.id
  route_table_id = aws_route_table.public_subs.id
}



#PRIVATE SUBNET (PRIVATE_1) ROUTETABLE TO NATGW

resource "aws_route_table" "private_subs_PRIVATE_1" {
  vpc_id = aws_vpc.wordpress_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_public_1.id
  }
}

resource "aws_route_table_association" "private_assoc_1" {
  subnet_id      = aws_subnet.PRIVATE_1_2a.id
  route_table_id = aws_route_table.private_subs_PRIVATE_1.id
}


#PRIVATE SUBNET (PRIVATE_2) ROUTETABLE TO NATGW

resource "aws_route_table" "private_subs_PRIVATE_2" {
  vpc_id = aws_vpc.wordpress_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_public_1.id
  }
}

resource "aws_route_table_association" "private_assoc_2" {
  subnet_id      = aws_subnet.PRIVATE_2_2b.id
  route_table_id = aws_route_table.private_subs_PRIVATE_2.id
}


# X2 EIP _ X2 NAT GATEWAYS

resource "aws_eip" "eip_nat_public_1" {
  domain   = "vpc"
}

# resource "aws_eip" "eip_nat_public_2" {
#   domain   = "vpc"
# }

# X2 NAT GATEWAYS
resource "aws_nat_gateway" "nat_public_1" {
  allocation_id = aws_eip.eip_nat_public_1.id
  subnet_id     = aws_subnet.public_1_2a.id

  tags = {
    Name = "public 1 NAT"
  }

  depends_on = [aws_internet_gateway.igw_terraform]
}

# resource "aws_nat_gateway" "nat_public_2" {
#   allocation_id = aws_eip.eip_nat_public_2.id
#   subnet_id     = aws_subnet.public_2_2b.id

#   tags = {
#     Name = "public 2 NAT"
#   }

#   depends_on = [aws_internet_gateway.igw_terraform]
# }

