# VPC
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

# Public Subnets
output "public_subnet_a_id" {
  description = "Public subnet A ID"
  value       = aws_subnet.public_subnet.id
}

output "public_subnet_b_id" {
  description = "Public subnet B ID"
  value       = aws_subnet.public_subnet_2.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_2.id]
}

# Private Subnets
output "private_subnet_a_id" {
  description = "Private subnet A ID (EKS nodes)"
  value       = aws_subnet.private_eks.id
}

output "private_subnet_b_id" {
  description = "Private subnet B ID (EKS nodes)"
  value       = aws_subnet.private_eks_2.id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs (used by EKS node groups)"
  value       = [aws_subnet.private_eks.id, aws_subnet.private_eks_2.id]
}

# NAT Gateway
output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = aws_nat_gateway.main.id
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT Gateway"
  value       = aws_eip.nat_gateway_eip.public_ip
}

# Security Group
output "eks_nodes_sg_id" {
  description = "Security group ID for EKS worker nodes"
  value       = aws_security_group.eks_nodes_sg.id
}

# ECR
output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.backend_non_prod_fe_repo.repository_url
}

# Secrets Manager
output "secrets_arn" {
  description = "ARN of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.secrets_non_prod.arn
}

# EKS Cluster
output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "eks_cluster_version" {
  description = "Kubernetes version of the EKS cluster"
  value       = aws_eks_cluster.main.version
}

output "eks_cluster_ca_certificate" {
  description = "Base64 encoded cluster CA certificate"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "eks_node_group_role_arn" {
  description = "IAM role ARN for EKS node group"
  value       = aws_iam_role.eks_node_role.arn
}

# # AWS Load Balancer Controller
# output "aws_lbc_role_arn" {
#   description = "IAM role ARN for AWS Load Balancer Controller"
#   value       = aws_iam_role.aws_lbc_role.arn
# }
