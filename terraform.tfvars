# General
aws_region  = "us-east-1"
environment = "non-prod"
project     = "my-eks-project"
owner       = "platform-team"

# VPC
vpc_cidr     = "10.0.0.0/16"
vpc_name_tag = "eks-non-prod-vpc"

# Availability Zones
availability_zones = {
  a = "us-east-1a"
  b = "us-east-1b"
}

# Public Subnets
public_subnet_cidr       = "10.0.1.0/24"
public_subnet_cidr2      = "10.0.2.0/24"
public_subnet_name_tag   = "eks-non-prod-public-subnet-a"
public_subnet_2_name_tag = "eks-non-prod-public-subnet-b"

# Private Subnets (EKS nodes)
private_subnet_cidrs    = "10.0.10.0/24"
private_subnet_cidrs4   = "10.0.11.0/24"
private_eks_name_tag    = "eks-non-prod-private-subnet-a"
private_eks_2_name_tag  = "eks-non-prod-private-subnet-b"

# Gateways & Route Tables
internet_gateway_name_tag         = "eks-non-prod-igw"
nat_gateway_eip_name_tag          = "eks-non-prod-nat-eip"
nat_gateway_name_tag              = "eks-non-prod-nat-gw"
public_route_table_name_tag       = "eks-non-prod-public-rt"
private_eks_route_table_name_tag  = "eks-non-prod-private-rt"

# Security Groups
eks_nodes_sg_name_tag = "eks-non-prod-nodes-sg"

# ECR
backend_repo_non_prod_fe_name = "eks-non-prod-frontend"

# Secrets Manager
secretsmanager_non_prod_name = "eks-non-prod/app-secrets-eus1"

# EKS Cluster
eks_cluster_name        = "eks-non-prod"
eks_cluster_version     = "1.32"
eks_node_instance_types = ["t3.medium"]
eks_node_desired_size   = 1
eks_node_min_size       = 1
eks_node_max_size       = 1
