output "vpc_id" {
  description = "The ID of the VPC created for EKS."
  value       = aws_vpc.fiap_video_vpc.id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets."
  value       = aws_subnet.subnet_public[*].id
}