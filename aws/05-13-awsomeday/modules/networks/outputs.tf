output "main_vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "app_public_subnet_id" {
  value = aws_subnet.app_public.id
}

output "app_private_subnet0_id" {
  value = aws_subnet.app_private0.id
}

output "app_private_subnet1_id" {
  value = aws_subnet.app_private1.id
}
