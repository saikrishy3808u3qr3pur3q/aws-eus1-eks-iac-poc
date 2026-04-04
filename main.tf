# Purpose of an SLR - It's used or provided to service "Princpial = {Service = "ec2.amazonaws.com" } - thats basically a service linked role
# it's different from a normal role - since aws has a different api endpoint to create this over an normal IAM role
# Since it gets automatically created - we wouldn't be able to update it.

# --- VPC ---
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, { Name = var.vpc_name_tag })
}

# --- Public Subnets ---
# EKS requires the kubernetes.io/role/elb tag on public subnets for external load balancers
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zones.a
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name                     = var.public_subnet_name_tag
    #Purpose 
    # when you have a aws load balencer controller - it needs this tag (the controller scans for this tag) in the provided subnets
    "kubernetes.io/role/elb" = "1" # not required if explict annotations are passed
    # "kubernetes.io/cluster/<cluster-name>" = "shared" - this is a more general ownership marker
    # if multiple clusters exists - this tag is required as well
    # this is basically for the alb controller to know which subnets to use when multiple clusters exist
    # more like 1st - can i have elb / internal-elb here - if ok - then check can my cluster have resources here - is the condition
  })
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr2
  availability_zone       = var.availability_zones.b
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name                     = var.public_subnet_2_name_tag
    "kubernetes.io/role/elb" = "1"
  })
}

# --- Private Subnets (EKS Nodes) ---
# EKS requires the kubernetes.io/role/internal-elb tag on private subnets for internal load balancers
resource "aws_subnet" "private_eks" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs
  availability_zone = var.availability_zones.a

  tags = merge(local.common_tags, {
    Name                              = var.private_eks_name_tag
    #"kubernetes.io/role/internal-elb" = "1"
  })
}

resource "aws_subnet" "private_eks_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs4
  availability_zone = var.availability_zones.b

  tags = merge(local.common_tags, {
    Name                              = var.private_eks_2_name_tag
    #"kubernetes.io/role/internal-elb" = "1"
  })
}

# --- Internet Gateway ---
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, { Name = var.internet_gateway_name_tag })
}

# --- NAT Gateway ---
resource "aws_eip" "nat_gateway_eip" {
  domain = "vpc"

  tags = merge(local.common_tags, { Name = var.nat_gateway_eip_name_tag })
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  depends_on = [aws_internet_gateway.main]

  tags = merge(local.common_tags, { Name = var.nat_gateway_name_tag })
}

# --- Route Tables ---
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.common_tags, { Name = var.public_route_table_name_tag })
}

resource "aws_route_table" "private_rt_eks" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = merge(local.common_tags, { Name = var.private_eks_route_table_name_tag })
}

# --- Route Table Associations ---
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_eks.id
  route_table_id = aws_route_table.private_rt_eks.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_eks_2.id
  route_table_id = aws_route_table.private_rt_eks.id
}
# --- Security Group (EKS Nodes) ---
resource "aws_security_group" "eks_nodes_sg" {
  vpc_id      = aws_vpc.main.id
  description = "Security group for EKS worker nodes"

  # ALB receives HTTPS on 443
  # AWS LBC creates a TargetGroup pointing at your nodes on a NodePort (e.g. 31234)
  # ALB forwards the request to node-ip:31234
  # kube-proxy on that node intercepts it, translates to the ClusterIP
  # ClusterIP routes to a healthy pod on port 3000 or 8080
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Control plane to node (webhooks)"
  }

  ingress {
    # any communication from the control plane - since kube api server talks to kubelt using this port
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Control plane to kubelet (logs, exec, probes)"
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow ALB to reach NodePort range (traffic + health checks)"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = var.eks_nodes_sg_name_tag })
}

# --- ECR Repository ---
resource "aws_ecr_repository" "backend_non_prod_fe_repo" {
  name                 = var.backend_repo_non_prod_fe_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.common_tags, { Name = var.backend_repo_non_prod_fe_name })
}

resource "aws_ecr_lifecycle_policy" "frontend_non_prod_repo_policy" {
  repository = aws_ecr_repository.backend_non_prod_fe_repo.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# --- Secrets Manager ---
resource "aws_secretsmanager_secret" "secrets_non_prod" {
  name        = var.secretsmanager_non_prod_name
  description = "App secrets for non-prod EKS workloads"

  tags = merge(local.common_tags, { Name = var.secretsmanager_non_prod_name })
}

# --- IAM Role: EKS Cluster ---
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.project}-${var.environment}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
# ec2 describe, elb (create / manage), cloudwatch, IAM, Auto Scaling, KMS (describe - if secret encrytion enabled later to get it)
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  # required when the pods - ENIs + security groups specific for the pods traffic over the nodes
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

# --- IAM Role: EKS Node Group ---
resource "aws_iam_role" "eks_node_role" {
  name = "${var.project}-${var.environment}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  # EC2 Describle (so that node can fetch the cluster config, so that it can register itself onto cluster as it starts)
  # eks-auth:AssumeRoleForPodIdentity
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  # EC2 : Describe (list all resources)
  # EC2 - Create Network Interface and Attach IPs 
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_ecr_read_policy" {
  # ECR - to pull images (readonly access)
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# --- EKS Cluster ---
resource "aws_eks_cluster" "main" {
  # Name of the cluster, role, EKS cluster version (just get the latest version - since each version gets only 14 months of )
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.eks_cluster_version

  vpc_config {
    # 2 Subnets for availabilty and security groups
    subnet_ids              = [aws_subnet.private_eks.id, aws_subnet.private_eks_2.id]
    security_group_ids      = [aws_security_group.eks_nodes_sg.id]
    
    # This means the endpoint is accessible from within the VPC (only from within the VPC) (don't need to hit internet for reaching API server for resources in vpc)
    endpoint_private_access = true
    
    # This means the endpoint is accessible from internet (not just from VPC) (argo CD could hit from public)
    endpoint_public_access  = true
  }

  depends_on = [
    # waits untilll the other associated roles are created
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller,
    aws_eks_node_group.main,
  ]

  tags = merge(local.common_tags, { Name = var.eks_cluster_name })
}

# --- EKS Managed Node Group ---
resource "aws_eks_node_group" "main" {
  # attach to cluster, name the node group, node role, subnets with availabilty
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.eks_cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [aws_subnet.private_eks.id, aws_subnet.private_eks_2.id]

  # instance type, AMI Image, Disk size
  instance_types = var.eks_node_instance_types
  ami_type       = "AL2_x86_64"
  disk_size      = 20

  # Scaling configurations
  scaling_config {
    desired_size = var.eks_node_desired_size
    min_size     = var.eks_node_min_size
    max_size     = var.eks_node_max_size
  }

  # During an Update - some config changes - only one node can be unavailable
  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_read_policy,
  ]

  tags = merge(local.common_tags, { Name = "${var.eks_cluster_name}-node-group" })
}
