# General
variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. dev, staging, prod)"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
}

# VPC
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name_tag" {
  description = "Name tag for the VPC"
  type        = string
}

# Availability Zones
variable "availability_zones" {
  description = "Map of availability zones"
  type        = map(string)
}

# Public Subnets
variable "public_subnet_cidr" {
  description = "CIDR for public subnet A"
  type        = string
}

variable "public_subnet_cidr2" {
  description = "CIDR for public subnet B"
  type        = string
}

variable "public_subnet_name_tag" {
  description = "Name tag for public subnet A"
  type        = string
}

variable "public_subnet_2_name_tag" {
  description = "Name tag for public subnet B"
  type        = string
}

# Private Subnets (EKS nodes)
variable "private_subnet_cidrs" {
  description = "CIDR for private EKS subnet A"
  type        = string
}

variable "private_subnet_cidrs4" {
  description = "CIDR for private EKS subnet B"
  type        = string
}

variable "private_eks_name_tag" {
  description = "Name tag for private EKS subnet A"
  type        = string
}

variable "private_eks_2_name_tag" {
  description = "Name tag for private EKS subnet B"
  type        = string
}

# Gateways & Route Tables
variable "internet_gateway_name_tag" {
  description = "Name tag for the Internet Gateway"
  type        = string
}

variable "nat_gateway_eip_name_tag" {
  description = "Name tag for the NAT Gateway EIP"
  type        = string
}

variable "nat_gateway_name_tag" {
  description = "Name tag for the NAT Gateway"
  type        = string
}

variable "public_route_table_name_tag" {
  description = "Name tag for the public route table"
  type        = string
}

variable "private_eks_route_table_name_tag" {
  description = "Name tag for the private EKS route table"
  type        = string
}

# Security Groups
variable "eks_nodes_sg_name_tag" {
  description = "Name tag for the EKS nodes security group"
  type        = string
}

# ECR
variable "backend_repo_non_prod_fe_name" {
  description = "Name of the ECR repository"
  type        = string
}

# Secrets Manager
variable "secretsmanager_non_prod_name" {
  description = "Name of the Secrets Manager secret"
  type        = string
}

# EKS Cluster
variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "eks_cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.32"
}

variable "eks_node_instance_types" {
  description = "EC2 instance types for the EKS node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_node_desired_size" {
  description = "Desired number of nodes"
  type        = number
  default     = 2
}

variable "eks_node_min_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "eks_node_max_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 3
}
