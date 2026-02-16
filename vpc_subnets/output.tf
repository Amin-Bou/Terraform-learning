output "vpc_id" {
  value = aws_vpc.wordpress_vpc.id
}

output "public_subnet_1_id" {
  value = aws_subnet.public_1_2a.id
}

output "public_subnet_2_id" {
  value = aws_subnet.public_2_2b.id
}

output "private_subnet_1_id" {
  value = aws_subnet.PRIVATE_1_2a.id
}

output "private_subnet_2_id" {
  value = aws_subnet.PRIVATE_2_2b.id
}

output "igw_id" {
  value = aws_internet_gateway.igw_terraform.id
}

output "eip_nat_public_1" {
  value = aws_eip.eip_nat_public_1.id
}

# output "eip_nat_public_2" {
#   value = aws_eip.eip_nat_public_2.id
# }

output "nat_public_1" {
  value = aws_nat_gateway.nat_public_1.id
}

# output "nat_public_2" {
#   value = aws_nat_gateway.nat_public_2.id
# }

output "vpc_cidr" {
  value = aws_vpc.wordpress_vpc.cidr_block
}