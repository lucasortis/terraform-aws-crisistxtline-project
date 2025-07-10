################################################################################
# VPC
################################################################################
output "vpc_id" {
  description = "The ID of the VPC"
  value       = try(aws_vpc.this[0].id, null)
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = try(aws_vpc.this[0].arn, null)
}

output "public_subnet_1a" {
  description = "Public subnet ID for availability zone 1a"
  value       = try(aws_subnet.public_1a.id, null)
}

output "public_subnet_1b" {
  description = "Public subnet ID for availability zone 1b"
  value       = try(aws_subnet.public_1b.id, null)
}
output "private_subnet_1a" {
  description = "Private subnet ID for availability zone 1a"
  value       = try(aws_subnet.private_1a.id, null)
}

output "private_subnet_1b" {
  description = "Private subnet ID for availability zone 1b"
  value       = try(aws_subnet.private_1b.id, null)
}


