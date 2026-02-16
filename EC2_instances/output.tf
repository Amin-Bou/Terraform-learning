output "public_instance_id" {
  value = aws_instance.public_instance.id
}

output "public_instance_2_id" {
  value = aws_instance.public_instance_1.id
}